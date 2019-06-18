package clay.graphics;



import kha.arrays.Float32Array;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.render.Color;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.Vertex;
import clay.render.GeometryType;
import clay.render.DisplayObject;
import clay.render.RenderPath;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.utils.Log.*;


class Mesh extends DisplayObject {


	public var locked           (default, set):Bool;

	public var color   	    	(default, set):Color;
	public var texture      	(get, set):Texture;
	public var region:Rectangle;

	public var vertices:Array<Vertex>;
	public var indices:Array<Int>;

	@:noCompletion public var vertexbuffer:VertexBuffer;
	@:noCompletion public var indexbuffer:IndexBuffer;

	public var blend_disabled:Bool = false;

	public var blend_src:BlendMode;
	public var blend_dst:BlendMode;
	public var blend_op:BlendEquation;

	public var alpha_blend_dst:BlendMode;
	public var alpha_blend_src:BlendMode;
	public var alpha_blend_op:BlendEquation;

	var _texture:Texture;


	public function new(?vertices:Array<Vertex>, ?indices:Array<Int>, ?texture:Texture) {
		
		super();

		locked = false;

		this.vertices = vertices != null ? vertices : [];
		this.indices = indices != null ? indices : [];
		this.texture = texture;
		
		color = new Color();

		set_blendmode(BlendMode.BlendOne, BlendMode.InverseSourceAlpha, BlendEquation.Add);

		sort_key.geomtype = GeometryType.mesh;

	}

	public function add(v:Vertex):Mesh {

		vertices.push(v);

		return this;

	}

	public function remove(v:Vertex):Mesh {

		vertices.remove(v);

		return this;

	}

	override function render(r:RenderPath, c:Camera) {


		if(locked) {
			r.set_object_renderer(r.static_renderer);
			r.static_renderer.render(this);
		} else {
			render_geometry(r, c);
		}
		
	}

	public function update_locked() {

		if(locked) {
			if(vertexbuffer.count() != vertices.length * 8) {
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

	function render_geometry(r:RenderPath, c:Camera) {

		r.set_object_renderer(r.mesh_renderer);
		r.mesh_renderer.render(this);

	}

	function setup_locked_buffers() {

		var sh = shader != null ? shader : shader_default;

		vertexbuffer = new VertexBuffer(
			vertices.length * 8,
			sh.pipeline.inputLayout[0],
			Usage.StaticUsage
		);

		indexbuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);

	}

	function update_locked_buffer() {

		var region_scaled_x:Float = 0;
		var region_scaled_y:Float = 0;
		var region_scaled_w:Float = 0;
		var region_scaled_h:Float = 0;

		if(region == null || texture == null) {
			region_scaled_x = region.x / texture.width_actual;
			region_scaled_y = region.y / texture.height_actual;
			region_scaled_w = region.w / texture.width_actual;
			region_scaled_h = region.h / texture.height_actual;
		}

		var data = vertexbuffer.lock();
		var m = transform.world.matrix;
		var n:Int = 0;
		for (v in vertices) {
			data.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
			data.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);

			data.set(n++, v.color.r);
			data.set(n++, v.color.g);
			data.set(n++, v.color.b);
			data.set(n++, v.color.a);

			data.set(n++, v.tcoord.x * region_scaled_w + region_scaled_x);
			data.set(n++, v.tcoord.y * region_scaled_h + region_scaled_y);
		}
		vertexbuffer.unlock();

	}

	function clear_buffers() {

		if(vertexbuffer != null) {
			vertexbuffer.delete();
			vertexbuffer = null;
		}

		if(indexbuffer != null) {
			indexbuffer.delete();
			indexbuffer = null;
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
