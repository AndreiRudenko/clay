package clay.components.graphics;


import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;

import clay.render.Layer;
import clay.render.Vertex;
import clay.render.Shader;
import clay.render.GeometrySortKey;
import clay.resources.Texture;
import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.math.Mathf;
import clay.data.Color;
import clay.utils.Bits;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


@:access(clay.render.Renderer)
class Geometry {

	static var ID:Int = 0;

	public var name:String;
	public var visible          (default, set):Bool = true;
	public var added        	(default, null):Bool = false;
	public var sort_key     	(default, null):GeometrySortKey;

	public var vertices	    	(default, set):Array<Vertex>;
	public var indices          (default, set):Array<UInt>;
	public var shader       	(get, set):Shader;
	public var color   	    	(default, set):Color;
	public var texture      	(get, set):Texture;

	public var geometry_type	(get, never):GeometryType;

	public var layer            (get, never):Layer;
	public var depth            (default, set):Float;

	public var transform_matrix:Matrix;
	public var clip_rect        (default, set):Rectangle;

	// instanced
	public var instanced        (default, null):Bool = false;
	public var instances        (default, null):Array<InstancedGeometry>;
	public var instances_count  (get, set):Int;

	@:noCompletion public var vertexbuffers:Array<VertexBuffer>;
	@:noCompletion public var indexbuffer:IndexBuffer;

	public var inited(default, null):Bool = false;

	var _layer:Layer;
	var _shader:Shader;
	var _texture:Texture;

	var _custom_shader:Bool = false;
	var _instances_count:Int = 0;
	var _instances_cache_size:Int = 0;
	var _geometry_type:GeometryType;

	var next:Geometry;
	var prev:Geometry;


	public function new(_options:GeometryOptions) {

		sort_key = new GeometrySortKey(0,0);

		transform_matrix = new Matrix();

		name = def(_options.name, 'geometry.${ID++}');
		visible = def(_options.visible, true);
		indices = def(_options.indices, []);
		vertices = def(_options.vertices, []);
		color = def(_options.color, new Color());
		_layer = def(_options.layer, null);
		depth = def(_options.depth, 0);
		texture = def(_options.texture, texture);
		shader = _options.shader;
		if(_options.clip_rect != null) {
			clip_rect = _options.clip_rect;
		}

		set_geometry_type(GeometryType.polygon);

	}

	public function add(v:Vertex):Geometry {

		vertices.push(v);

		return this;

	}

	public function remove(v:Vertex):Geometry {

		vertices.remove(v);

		return this;

	}

	public function drop() {
		
		if(added && _layer != null) {
			_layer._remove_unsafe(this);
		}

	}

	public function set_indices(v:Array<UInt>):Array<UInt> {

		return indices = v;

	}

	public function clone():Geometry {

		return null;
		
	}

	public function setup_instanced(_instances:Int):Geometry {

		if(!instanced) {
			_instances_count = _instances;
			_instances_cache_size = _instances_count;

			vertexbuffers = [];
			instances = [];

			instanced = true;

			if(!_custom_shader) {
				_set_shader(get_default_shader(instanced));
			}

			setup_instanced_buffers(_instances);
		}

		return this;
		
	}

	public function update_instanced():Geometry {
		
		if(instanced) {
			setup_instanced_buffers(_instances_cache_size);
		}

		return this;

	}

	@:noCompletion public function update_instance_buffer(_mat:kha.math.FastMatrix3) {

		if(_instances_count == 0) {
			return;
		}

		_verboser('update_instance_buffer ${_instances_count}');

		var inst:InstancedGeometry;
		var mvp = kha.math.FastMatrix3.identity();
		var data = vertexbuffers[1].lock();
		var n:Int = 0;
		for (i in 0..._instances_count) {
			
			inst = instances[i];
			update_instance_matrix(inst);

			mvp.setFrom(_mat);
			mvp.append_matrix(inst.transform_matrix);

			// transform
			data.set(n++, mvp._00);		
			data.set(n++, mvp._01);		
			data.set(n++, 0);			
			data.set(n++, 0);		
			
			data.set(n++, mvp._10);		
			data.set(n++, mvp._11);		
			data.set(n++, 0);			
			data.set(n++, 0);		
			
			data.set(n++, 0);		
			data.set(n++, 0);		
			data.set(n++, 1);			
			data.set(n++, 0);		
			
			data.set(n++, mvp._20);		
			data.set(n++, mvp._21);		
			data.set(n++, 0);		
			data.set(n++, 1);	

			// color
			data.set(n++, inst.color.r);		
			data.set(n++, inst.color.g);		
			data.set(n++, inst.color.b);		
			data.set(n++, inst.color.a);

			if(_texture != null) {
				data.set(n++, inst.texture_offset.x);		
				data.set(n++, inst.texture_offset.y);	
			}

		}
		vertexbuffers[1].unlock();

	}

	inline function setup_instanced_buffers(inst_count:Int) {

		_debug('setup_instanced_buffers $inst_count');

		instances.splice(0, instances.length);

		for (i in 0...inst_count) {
			instances.push(new InstancedGeometry(this));
		}
		
		// vertex pos, tcoord
		vertexbuffers[0] = new VertexBuffer(
			vertices.length * 2,
			_shader.inputLayout[0],
			Usage.StaticUsage
		);

		var data = vertexbuffers[0].lock();
		var n:Int = 0;
		for (i in 0...vertices.length) {
			data.set(n++, vertices[i].pos.x);		
			data.set(n++, vertices[i].pos.y);
			if(_texture != null) {
				data.set(n++, vertices[i].tcoord.x);
				data.set(n++, vertices[i].tcoord.y);
			}		
		}		
		vertexbuffers[0].unlock();

		// color, transform, texture_offset
		vertexbuffers[1] = new VertexBuffer(
			inst_count,
			_shader.inputLayout[1],
			Usage.StaticUsage
			#if !kha_android
			, 1
			#end
		);

		// indices
		indexbuffer = new IndexBuffer(
			indices.length,
			Usage.StaticUsage
		);
		
		var idata = indexbuffer.lock();
		for (i in 0...idata.length) {
			idata[i] = indices[i];
		}
		indexbuffer.unlock();

		_instances_cache_size = inst_count;

		return this;

	}

	inline function update_instance_matrix(inst:InstancedGeometry) {
		
		inst.transform_matrix.identity()
		.translate(inst.pos.x, inst.pos.y)
		.rotate(Mathf.radians(inst.rotation))
		.scale(inst.size.x*inst.scale.x, inst.size.y*inst.scale.y)
		.apply(-inst.origin.x*(1/inst.size.x), -inst.origin.y*(1/inst.size.y));

	}

	inline function update_depth() {

		if(added && _layer != null && _layer.depth_sort) {
			var l = _layer;
			l._remove_unsafe(this);
			l._add_unsafe(this);
		}

	}

	@:noCompletion public function get_default_shader(_instanced:Bool):Shader {

		if(_instanced) {
			return texture != null ? Clay.renderer.shader_instanced_textured : Clay.renderer.shader_instanced;
		} else {
			return texture != null ? Clay.renderer.shader_textured : Clay.renderer.shader_colored;
		}

	}

	inline function get_geometry_type():GeometryType {

		return _geometry_type;

	}

	function set_geometry_type(v:GeometryType) {

		sort_key.geometry_type = v;

		update_depth();

		_geometry_type = v;

	}

	function set_color(c:Color):Color {

		if(vertices != null) {
			for (v in vertices) {
				v.color = c;
			}
		}

		return color = c;

	}

	function set_vertices(v:Array<Vertex>):Array<Vertex> {

		vertices = v;

		return v;

	}

	inline function get_layer():Layer {

		return _layer;

	}

	inline function get_shader():Shader {

		return _shader;

	}

	function set_shader(v:Shader):Shader {

		_custom_shader = v != null;

		if(!_custom_shader) {
			v = get_default_shader(instanced);
		}

		return _set_shader(v);

	}

	inline function _set_shader(v:Shader) {

		sort_key.shader = v.id;

		update_depth();

		return _shader = v;
	}

	inline function get_texture():Texture {

		return _texture;

	}
	
	function set_texture(v:Texture):Texture {

		var tid:Int = Clay.renderer.texture_max; // for colored sorting

		if(v != null) {
			tid = v.tid;
		}

		sort_key.texture = tid;

		update_depth();

		update_instanced();

		return _texture = v;

	}

	function set_depth(v:Float):Float {

		sort_key.depth = v;

		update_depth();

		return depth = v;

	}

	function set_clip_rect(v:Rectangle):Rectangle {

		sort_key.clip = v != null;

		if(clip_rect == null && v != null || clip_rect != null && v == null) {
			update_depth();
		}

		return clip_rect = v;

	}

	function set_visible(v:Bool):Bool {

		visible = v;

		return visible;

	}

	inline function get_instances_count():Int {
		
		return _instances_count;

	}

	function set_instances_count(v:Int):Int {

		if(!instanced) {
			log('geometry is not instanced');
			return v;
		}

		if(v < 0) {
			log('instances_count must be >= 0');
			return v;
		}

		if(v > _instances_cache_size) {
			setup_instanced_buffers(v);
		}

		return _instances_count = v;
		
	}


}

class InstancedGeometry {


	public var pos:Vector;
	public var size:Vector;
	public var scale:Vector;
	public var origin:Vector;
	public var rotation:Float;

	public var color:Color;

	public var texture_offset:Vector;

	@:noCompletion public var transform_matrix(default, null):Matrix;

	var geom:Geometry;


	public function new(_geom:Geometry) {

		geom = _geom;

		pos = new Vector();
		size = new Vector(32,32);
		scale = new Vector(1,1);
		origin = new Vector();
		rotation = 0;
		color = new Color();
		texture_offset = new Vector();
		transform_matrix = new Matrix();

	}

}


@:enum abstract GeometryType(UInt) from UInt to UInt {
	
	var polygon         = 0;
	var quad            = 1;
	var text            = 2;
	
	var none            = 3;

}


typedef GeometryOptions = {

	@:optional var name:String;
	@:optional var texture:Texture;
	@:optional var vertices:Array<Vertex>;
	@:optional var indices:Array<Int>;
	@:optional var visible:Bool;
	@:optional var layer:Layer;
	@:optional var shader:Shader;
	@:optional var color:Color;
	@:optional var depth:Float;
	@:optional var clip_rect:Rectangle;

}