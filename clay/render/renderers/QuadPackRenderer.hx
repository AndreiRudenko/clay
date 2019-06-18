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


class QuadPackRenderer extends ObjectRenderer {


	var g:Graphics;

	var _quads_total:Int = 0;
	var _quads_draw:Int = 0;
	var _quads_max:Int = 0;
	var _buffer_index:Int = 0;

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
    	_quads_max = Std.int(renderpath.max_vertices / 4);

		_indexbuffer = new IndexBuffer(_quads_max * 6, Usage.StaticUsage);
		var indices = _indexbuffer.lock();
		for (i in 0..._quads_max) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		_indexbuffer.unlock();

		_region_scaled = new Rectangle();

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

		if(_shader != shader 
			|| _texture != geom.texture
			|| !check_blendmode(geom)
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

		_quads_total += Std.int(geom.vertices.length / 4);

		#if !no_debug_console
		renderpath.stats.vertices += geom.vertices.length;
		renderpath.stats.indices += Std.int(geom.vertices.length / 4) * 6;
		#end
		
	}

	function flush() {

		if(_quads_total == 0) {
			_verboser('nothing draw, quads_total == 0');
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

		g.drawIndexedVertices(0, _quads_draw * 6);

		g.setTexture(_texture_loc, null);

		_quads_total -= _quads_draw;
		_quads_draw = 0;
		_buffer_index = 0;

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end

	}

	function upload_buffer() {

		_vertexbuffer = renderpath.get_buffer(_quads_total * 4);
		var vertices = _vertexbuffer.lock();

		var i:Int;
		var len:Int;
		for (geom in _geometry) {
			set_region(geom.region, _texture);
			i = 0;
			len = geom.vertices.length;
			while(i < len) {
				if(_quads_draw + 1 > _quads_max) {
					_vertexbuffer.unlock();
					// _indexbuffer.unlock(_quads_draw * 6);
					draw_buffer();
					_vertexbuffer = renderpath.get_buffer(_quads_total * 4);
					vertices = _vertexbuffer.lock();
				}
				set_quad_vertices(vertices, geom.transform.world.matrix, geom.vertices, i);
				i += 4;
			}	
		}

		_vertexbuffer.unlock();
		// _indexbuffer.unlock(_quads_draw * 6);
		
	}
	
	function set_quad_vertices(data:Float32Array, m:Matrix, verts:Array<Vertex>, offset:Int) {

		var v:Vertex;
		for (i in offset...offset+4) {
			v = verts[i];
			data.set(_buffer_index++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
			data.set(_buffer_index++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

			data.set(_buffer_index++, v.color.r);
			data.set(_buffer_index++, v.color.g);
			data.set(_buffer_index++, v.color.b);
			data.set(_buffer_index++, v.color.a);

			data.set(_buffer_index++, v.tcoord.x * _region_scaled.w + _region_scaled.x);
			data.set(_buffer_index++, v.tcoord.y * _region_scaled.h + _region_scaled.y);
		}

		_quads_draw++;

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