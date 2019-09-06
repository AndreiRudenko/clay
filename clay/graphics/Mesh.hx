package clay.graphics;



import kha.arrays.Float32Array;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.render.Color;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Vertex;
import clay.render.DisplayObject;
import clay.render.Painter;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.utils.Log.*;


class Mesh extends DisplayObject {


	public var locked(default, set):Bool;

	public var color(default, set):Color;
	public var texture(get, set):Texture;
	public var region:Rectangle;

	public var vertices:Array<Vertex>;
	public var indices:Array<Int>;

	public var blend_disabled:Bool = false;

	public var blend_src:BlendMode;
	public var blend_dst:BlendMode;
	public var blend_op:BlendEquation;

	public var alpha_blend_dst:BlendMode;
	public var alpha_blend_src:BlendMode;
	public var alpha_blend_op:BlendEquation;

	var _texture:Texture;
	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;
	var _region_scaled:Rectangle;


	public function new(?vertices:Array<Vertex>, ?indices:Array<Int>, ?texture:Texture) {
		
		super();

		locked = false;

    	this.vertices = vertices != null ? vertices : [];
		this.indices = indices != null ? indices : [];
		this.texture = texture;
		_region_scaled = new Rectangle();

		color = new Color();

		set_blendmode(BlendMode.BlendOne, BlendMode.InverseSourceAlpha, BlendEquation.Add);

	}

	public function add(v:Vertex) {

		vertices.push(v);

	}

	public function remove(v:Vertex):Bool {

		return vertices.remove(v);

	}

	override function render(p:Painter) {

		if(locked || p.can_batch(vertices.length, indices.length)) {
			p.ensure(vertices.length, indices.length);
			
			p.set_shader(shader != null ? shader : shader_default);
			p.clip(clip_rect);
			p.set_texture(texture);

			if(blend_disabled) {
				var sh = shader != null ? shader : shader_default;
				p.set_blendmode(
					sh._blend_src_default, sh._blend_dst_default, sh._blend_op_default, 
					sh._alpha_blend_src_default, sh._alpha_blend_dst_default, sh._alpha_blend_op_default
				);
			} else {
				p.set_blendmode(blend_src, blend_dst, blend_op, alpha_blend_src, alpha_blend_dst, alpha_blend_op);
			}

			if(locked) {
				#if !no_debug_console
				p.stats.locked++;
				#end
				p.draw_from_buffers(_vertexbuffer, _indexbuffer);
			} else {
				update_region_scaled();

				for (index in indices) {
					p.add_index(index);
				}

				var m = transform.world.matrix;
				for (v in vertices) {
					p.add_vertex(
						m.a * v.pos.x + m.c * v.pos.y + m.tx, 
						m.b * v.pos.x + m.d * v.pos.y + m.ty, 
						v.tcoord.x * _region_scaled.w + _region_scaled.x,
						v.tcoord.y * _region_scaled.h + _region_scaled.y,
						v.color
					);
				}
			}

		} else {
			log('WARNING: can`t batch a geometry, vertices: ${vertices.length} vs max ${p.vertices_max}, indices: ${indices.length} vs max ${p.indices_max}');
		}

	}

	public function update_locked() {

		if(locked) {
			if(_vertexbuffer.count() != vertices.length * 8) {
				clear_buffers();
				setup_locked_buffers();
			}

			update_locked_buffer();
		}
		
	}

	public function set_blendmode(blend_src:BlendMode, blend_dst:BlendMode, ?blend_op:BlendEquation, ?alpha_blend_src:BlendMode, ?alpha_blend_dst:BlendMode, ?alpha_blend_op:BlendEquation) {
		
		this.blend_src = blend_src;
		this.blend_dst = blend_dst;
		this.blend_op = blend_op != null ? blend_op : BlendEquation.Add;	

		this.alpha_blend_src = alpha_blend_src != null ? alpha_blend_src : blend_src;
		this.alpha_blend_dst = alpha_blend_dst != null ? alpha_blend_dst : blend_dst;
		this.alpha_blend_op = alpha_blend_op != null ? alpha_blend_op : blend_op;	

	}

	function setup_locked_buffers() {

		var sh = shader != null ? shader : shader_default;

		_vertexbuffer = new VertexBuffer(
			vertices.length,
			sh.pipeline.inputLayout[0],
			Usage.StaticUsage
		);

		_indexbuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);

	}

	function update_locked_buffer() {

		update_region_scaled();

		transform.update();

		var data = _vertexbuffer.lock();
		var m = transform.world.matrix;
		var n:Int = 0;
		for (v in vertices) {
			data.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
			data.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

			data.set(n++, v.color.r);
			data.set(n++, v.color.g);
			data.set(n++, v.color.b);
			data.set(n++, v.color.a);

			data.set(n++, v.tcoord.x * _region_scaled.w + _region_scaled.x);
			data.set(n++, v.tcoord.y * _region_scaled.h + _region_scaled.y);
		}
		_vertexbuffer.unlock();

		var idata = _indexbuffer.lock();
		for (i in 0...indices.length) {
			idata.set(i, indices[i]);
		}

		_indexbuffer.unlock();

	}

	function clear_buffers() {

		if(_vertexbuffer != null) {
			_vertexbuffer.delete();
			_vertexbuffer = null;
		}

		if(_indexbuffer != null) {
			_indexbuffer.delete();
			_indexbuffer = null;
		}

	}

	inline function update_region_scaled() {
		
		if(region == null || _texture == null) {
			_region_scaled.set(0, 0, 1, 1);
		} else {
			_region_scaled.set(
				_region_scaled.x = region.x / _texture.width_actual,
				_region_scaled.y = region.y / _texture.height_actual,
				_region_scaled.w = region.w / _texture.width_actual,
				_region_scaled.h = region.h / _texture.height_actual
			);
		}

	}

	inline function get_texture():Texture {

		return _texture;

	}

	function set_texture(v:Texture):Texture {

		var tid:Int = Clay.renderer.sort_options.texture_max; // for colored sorting

		if(v != null) {
			tid = v.tid;
		}

		sort_key.texture = tid;

		dirty_sort();

		return _texture = v;

	}

	function set_color(c:Color):Color {

		if(vertices != null) {
			for (v in vertices) {
				v.color = c;
			}
		}

		return color = c;

	}

	function set_locked(v:Bool):Bool {

		if(v) {
			setup_locked_buffers();
			update_locked_buffer();
		} else {
			clear_buffers();
		}

		return locked = v;

	}


}
