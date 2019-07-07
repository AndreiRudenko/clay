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



class QuadRenderer extends ObjectRenderer {


	var g:Graphics;

	var _quads_draw:Int = 0;
	var _quads_max:Int = 0;

	var _geometry:Array<Mesh>;

	var _shader:Shader;
	var _texture:Texture;
	var _clip_rect:Rectangle;
	var _region_scaled:Rectangle;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;
	var _indexbuffers:Array<IndexBuffer>;

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
    	_indexbuffers = [];
    	_quads_max = Std.int(renderpath.max_vertices / 4);
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

		var shader = geom.shader != null ? geom.shader : geom.shader_default;

		if(_shader != shader 
			|| _texture != geom.texture
			|| !check_blendmode(geom)
			|| _quads_draw + 1 > _quads_max
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

		_quads_draw++;

		#if !no_debug_console
		renderpath.stats.vertices += 4;
		renderpath.stats.indices += 6;
		#end

	}

	function flush() {

		if(_quads_draw == 0) {
			_verboser('nothing draw, _quads_draw == 0');
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

		_quads_draw = 0;

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end

	}

	function upload_buffer() {

		_vertexbuffer = renderpath.get_vertexbuffer(_quads_draw * 4);
		_indexbuffer = get_indexbuffer(_quads_draw * 6);
		var vertices = _vertexbuffer.lock();

		var n:Int = 0;
		var m:Matrix;
		var v:Vertex;
		for (geom in _geometry) {
			set_region(geom.region, _texture);
			m = geom.transform.world.matrix;
			for (i in 0...4) {
				v = geom.vertices[i];
				vertices.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
				vertices.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

				vertices.set(n++, v.color.r);
				vertices.set(n++, v.color.g);
				vertices.set(n++, v.color.b);
				vertices.set(n++, v.color.a);

				vertices.set(n++, v.tcoord.x * _region_scaled.w + _region_scaled.x);
				vertices.set(n++, v.tcoord.y * _region_scaled.h + _region_scaled.y);
			}
		}

		_vertexbuffer.unlock();
		// _indexbuffer.unlock(_quads_draw * 6);
		
	}

	function get_indexbuffer(size:Int):IndexBuffer {

		var p2 = clay.utils.Mathf.require_pow2(size);
		var idx = clay.utils.Mathf.log2(p2);
		var buffer = _indexbuffers[idx];

		if(buffer == null) {
			buffer = new IndexBuffer(p2, Usage.StaticUsage);
			var indices = buffer.lock();
			var len = Math.floor(p2/6);
			for (i in 0...len) {
				indices[i * 3 * 2 + 0] = i * 4 + 0;
				indices[i * 3 * 2 + 1] = i * 4 + 1;
				indices[i * 3 * 2 + 2] = i * 4 + 2;
				indices[i * 3 * 2 + 3] = i * 4 + 0;
				indices[i * 3 * 2 + 4] = i * 4 + 2;
				indices[i * 3 * 2 + 5] = i * 4 + 3;
			}
			buffer.unlock();
			_indexbuffers[idx] = buffer;
		}

		return buffer;

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