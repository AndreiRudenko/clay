package clay.render.renderers;


import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;


import clay.graphics.Mesh;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.utils.ArrayTools;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.math.Vector;


class MeshRenderer extends ObjectRenderer {

	var g:Graphics;

	var _verts_draw:Int = 0;
	var _indices_draw:Int = 0;

	var _geometry:Array<Mesh>;

	var _shader:Shader;
	var _texture:Texture;
	var _clip_rect:Rectangle;
	var _region_scaled:Rectangle;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;

	var _texture_loc:TextureUnit;

	var _blend_src:BlendMode;
	var _blend_dst:BlendMode;
	var _blend_op:BlendEquation;

	var _alpha_blend_dst:BlendMode;
	var _alpha_blend_src:BlendMode;
	var _alpha_blend_op:BlendEquation;


	public function new(renderpath:RenderPath) {

		super(renderpath);

    	_geometry = [];

		_region_scaled = new Rectangle();
		set_region(null, null);

	}

	override function start() {
		
		_shader = null;
		_texture = null;
		_clip_rect = null;
		g = renderpath.g;

	}

	override function end() {

		flush();
		
	}

	public function render(geom:Mesh) {

		if(geom.vertices.length == 0) {
			return;
		}
		
		var shader = geom.shader != null ? geom.shader : geom.shader_default;
		
		if(geom.vertices.length > renderpath.max_vertices || geom.indices.length > renderpath.max_indices) {
			log('WARNING: can`t batch a geometry `${geom.name}` 
			verts: (${geom.vertices.length} vs max vertices: ${renderpath.max_vertices}), 
			indices: (${geom.indices.length} vs max indices: ${renderpath.max_indices}),
			set it to locked');
			return;
		}

		if(_shader != shader 
			|| _texture != geom.texture
			|| !check_blendmode(geom)
			|| _verts_draw + geom.vertices.length > renderpath.max_vertices
			|| _indices_draw + geom.indices.length > renderpath.max_indices
			|| _clip_rect != null && !_clip_rect.equals(geom.clip_rect)
		) {
			flush();
		}

		_geometry.push(geom);

		_shader = shader;
		_texture = geom.texture;
		_clip_rect = geom.clip_rect;

		_blend_src = geom.blend_src; 
		_blend_dst = geom.blend_dst; 
		_blend_op = geom.blend_op;

		_alpha_blend_src = geom.alpha_blend_src;
		_alpha_blend_dst = geom.alpha_blend_dst;
		_alpha_blend_op = geom.alpha_blend_op;

		_verts_draw += geom.vertices.length;
		_indices_draw += geom.indices.length;

		#if !no_debug_console
		renderpath.stats.vertices += geom.vertices.length;
		renderpath.stats.indices += geom.indices.length;
		#end

	}

	function flush() {

		if(_verts_draw == 0) {
			_verboser('nothing draw, verts_draw == 0');
			return;
		}

		upload_buffer();
		draw_buffer();

		ArrayTools.clear(_geometry);

	}

	function draw_buffer() {

		renderpath.clip(_clip_rect);

		if(_texture == null) {
			_texture = renderpath.texture_blank;
		}

		_texture_loc = _shader.set_texture('tex', _texture).location;
		_shader.set_matrix3('mvpMatrix', renderpath.camera.projection_matrix);

		_shader.set_blendmode(
			_blend_src, _blend_dst, _blend_op, 
			_alpha_blend_src, _alpha_blend_dst, _alpha_blend_op
		);

		_shader.use(g);
		_shader.apply(g);

		g.setVertexBuffer(_vertexbuffer);
		g.setIndexBuffer(_indexbuffer);

		g.drawIndexedVertices(0, _indices_draw);

		g.setTexture(_texture_loc, null);

		_indices_draw = 0;
		_verts_draw = 0;

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end

	}

	function upload_buffer() {

		_vertexbuffer = renderpath.get_vertexbuffer(_verts_draw);
		_indexbuffer = renderpath.get_indexbuffer(_indices_draw);
		var vertices = _vertexbuffer.lock();
		var indices = _indexbuffer.lock();

		var idx:Int = 0;
		var n:Int = 0;
		var offset:Int = 0;
		var m:Matrix;
		var v:Vertex;
		var x:Float;
		var y:Float;
		var round_pixels:Bool = renderpath.camera.round_pixels;
		
		for (geom in _geometry) {
			set_region(geom.region, _texture);
			m = geom.transform.world.matrix;
			for (i in 0...geom.vertices.length) {
				v = geom.vertices[i];

				x = m.a * v.pos.x + m.c * v.pos.y + m.tx;
				y = m.b * v.pos.x + m.d * v.pos.y + m.ty;
				
				if(round_pixels) {
					x = Math.round(x);
					y = Math.round(y);
				}

				vertices.set(n++, x);
				vertices.set(n++, y);

				vertices.set(n++, v.color.r);
				vertices.set(n++, v.color.g);
				vertices.set(n++, v.color.b);
				vertices.set(n++, v.color.a);

				vertices.set(n++, v.tcoord.x * _region_scaled.w + _region_scaled.x);
				vertices.set(n++, v.tcoord.y * _region_scaled.h + _region_scaled.y);
			}
			for (ind in geom.indices) {
				indices[idx++] = ind + offset;
			}
			offset += geom.vertices.length;
		}

		_vertexbuffer.unlock();
		_indexbuffer.unlock();
		
	}

	inline function check_blendmode(geom:Mesh):Bool {

		return geom.blend_src == _blend_src 
			&& geom.blend_dst == _blend_dst 
			&& geom.blend_op == _blend_op
			&& geom.alpha_blend_src == _alpha_blend_src
			&& geom.alpha_blend_dst == _alpha_blend_dst
			&& geom.alpha_blend_op == _alpha_blend_op;

	}
	
	inline function set_region(region:Rectangle, texture:Texture) {
		
		if(region == null || texture == null) {
			_region_scaled.set(0, 0, 1, 1);
		} else {
			_region_scaled.set(
				_region_scaled.x = region.x / texture.width_actual,
				_region_scaled.y = region.y / texture.height_actual,
				_region_scaled.w = region.w / texture.width_actual,
				_region_scaled.h = region.h / texture.height_actual
			);
		}

	}

}