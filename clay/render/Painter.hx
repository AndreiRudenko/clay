package clay.render;



import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.TextureFormat;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;
import kha.math.FastMatrix3;
import kha.Image;

import clay.math.Vector;
import clay.graphics.Mesh;
import clay.render.Color;
import clay.render.Camera;
import clay.render.RenderStats;
import clay.resources.Texture;
import clay.render.Shader;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.utils.Mathf;
import clay.utils.ArrayTools;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


class Painter {


	public var stats(default, null):RenderStats;
	public var vertices_max(default, null):Int = 0;
	public var indices_max(default, null):Int = 0;

	var g:Graphics;

	var _renderer:Renderer;

	var _verts_draw:Int = 0;
	var _indices_draw:Int = 0;
	var _vertex_idx:Int = 0;

	var _shader:Shader;
	var _texture:Texture;
    var _texture_blank:Texture;
	var _clip_rect:Rectangle;
	var _clip_rect_default:Rectangle;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;

	var _vertices:Float32Array;
	var _indices:Uint32Array;

	var _blend_src:BlendMode;
	var _blend_dst:BlendMode;
	var _blend_op:BlendEquation;

	var _alpha_blend_dst:BlendMode;
	var _alpha_blend_src:BlendMode;
	var _alpha_blend_op:BlendEquation;

	var _projection_matrix:FastMatrix3;


	public function new(renderer:Renderer, batch_size:Int) {

		_renderer = renderer;

		vertices_max = batch_size;
		indices_max = Std.int(vertices_max / 4) * 6; // adjusted for quads

		var shader = _renderer.shaders.get('textured');
		_vertexbuffer = new VertexBuffer(
			vertices_max,
			shader.pipeline.inputLayout[0],
			Usage.DynamicUsage
		);

		_indexbuffer = new IndexBuffer(
			indices_max,
			Usage.DynamicUsage
		);
		
		_vertices = _vertexbuffer.lock();
		_indices = _indexbuffer.lock();

		_clip_rect_default = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);
		_projection_matrix = FastMatrix3.identity();

		_texture_blank = Texture.create(1, 1, TextureFormat.RGBA32, Usage.StaticUsage, true);
		var pixels = _texture_blank.lock();
		pixels.setInt32(0, 0xffffffff);
		_texture_blank.unlock();

		#if !no_debug_console
		stats = new RenderStats();
		#end

	}

	public function begin(graphics:Graphics, clip_rect:Rectangle) {
		
		g = graphics;
		_clip_rect_default = clip_rect;
		
		#if !no_debug_console
		stats.reset();
		#end

	}

	public inline function end() {
		
		flush();

	}

	public function set_projection(matrix:Matrix) {
		
		_projection_matrix.from_matrix(matrix);

	}

	public function clip(rect:Rectangle) {

		// if(_clip_rect != rect && !_clip_rect.equals(rect)) { // check for null
		if(_clip_rect != rect) {
			flush();
		}
		_clip_rect = rect;

	}

	public function set_shader(shader:Shader) {

		if(_shader != shader) {
			flush();
			_shader = shader;
		}
		
	}

	public function set_texture(texture:Texture) {
		
		if(_texture != texture) {
			flush();
			_texture = texture;
		}

	}

	public function set_blendmode(
		blend_src:BlendMode, blend_dst:BlendMode, ?blend_op:BlendEquation, 
		?alpha_blend_src:BlendMode, ?alpha_blend_dst:BlendMode, ?alpha_blend_op:BlendEquation
	) {

		if(_blend_src != blend_src 
			|| _blend_dst != blend_dst 
			|| _blend_op != blend_op
			|| _alpha_blend_src != alpha_blend_src
			|| _alpha_blend_dst != alpha_blend_dst
			|| _alpha_blend_op != alpha_blend_op
		) {
			flush();
			_blend_src = blend_src;
			_blend_dst = blend_dst;
			_blend_op = blend_op;
			_alpha_blend_src = alpha_blend_src;
			_alpha_blend_dst = alpha_blend_dst;
			_alpha_blend_op = alpha_blend_op;
		}

	}

	public function can_batch(verts_count:Int, indices_count:Int):Bool {
		
		return verts_count < vertices_max && indices_count < indices_max;

	}

	public function ensure(verts_count:Int, indices_count:Int) {

		if(_verts_draw + verts_count >= vertices_max || _indices_draw + indices_count >= indices_max) {
			flush();
		}
		
	}

		// adding indices must be before adding vertices
	public inline function add_index(i:Int) {

		_indices[_indices_draw++] = _verts_draw + i;

		#if !no_debug_console
		stats.indices++;
		#end

	}

	public inline function add_vertex(x:Float, y:Float, uvx:Float, uvy:Float, c:Color) {
		
		_vertices.set(_vertex_idx++, x);
		_vertices.set(_vertex_idx++, y);

		_vertices.set(_vertex_idx++, c.r);
		_vertices.set(_vertex_idx++, c.g);
		_vertices.set(_vertex_idx++, c.b);
		_vertices.set(_vertex_idx++, c.a);

		_vertices.set(_vertex_idx++, uvx);
		_vertices.set(_vertex_idx++, uvy);

		_verts_draw++;

		#if !no_debug_console
		stats.vertices++;
		#end

	}

	public function draw_from_buffers(vertexbuffer:VertexBuffer, indexbuffer:IndexBuffer, count:Int = 0) {

		flush();

		if(count <= 0) {
			count = indexbuffer.count();
		}

		#if !no_debug_console
		stats.vertices += Math.floor(vertexbuffer.count() / 8);
		stats.indices += count;
		#end
		
		draw(vertexbuffer, indexbuffer, count);

	}

	public function flush() {
		
		if(_verts_draw == 0) {
			_verboser('nothing to draw, vertices == 0');
			return;
		}

		_vertexbuffer.unlock(_verts_draw);
		_indexbuffer.unlock(_indices_draw);
		// _indexbuffer.unlock();

		draw(_vertexbuffer, _indexbuffer, _indices_draw);

		_vertices = _vertexbuffer.lock();
		_indices = _indexbuffer.lock();

		_vertex_idx = 0;

		_verts_draw = 0;
		_indices_draw = 0;

	}

	inline function draw(vertexbuffer:VertexBuffer, indexbuffer:IndexBuffer, count:Int) {

		if(_clip_rect != null) {
			g.scissor(Std.int(_clip_rect.x), Std.int(_clip_rect.y), Std.int(_clip_rect.w), Std.int(_clip_rect.h));
		} else {
			g.scissor(Std.int(_clip_rect_default.x), Std.int(_clip_rect_default.y), Std.int(_clip_rect_default.w), Std.int(_clip_rect_default.h));
		}

		if(_texture == null) {
			_texture = _texture_blank;
		}

		var texture_loc = _shader.set_texture('tex', _texture).location;
		_shader.set_matrix3('mvpMatrix', _projection_matrix);

		_shader.set_blendmode(
			_blend_src, _blend_dst, _blend_op, 
			_alpha_blend_src, _alpha_blend_dst, _alpha_blend_op
		);

		_shader.use(g);
		_shader.apply(g);

		g.setVertexBuffer(vertexbuffer);
		g.setIndexBuffer(indexbuffer);

		g.drawIndexedVertices(0, count);

		g.setTexture(texture_loc, null);

		#if !no_debug_console
		stats.draw_calls++;
		#end

	}


}