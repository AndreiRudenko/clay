package clay.components;


import clay.render.Vertex;
import clay.render.Shader;
import clay.render.GeometrySortKey;
import clay.math.Vector;
import clay.math.Matrix;
import clay.data.Color;

// import clay.components.Transform;
import clay.utils.Log.*;
import clay.utils.Bits;


@:access(clay.render.Renderer)
class Geometry {


	public var sort_key(default, null):GeometrySortKey;

	public var visible:Bool;

	public var vertices	(default, set):Array<Vertex>;
	public var shader   (default, set):Shader;
	public var texture  (get, set):Texture;
	public var color   	(default, set):Color;

	public var geometry_type(default, set):GeometryType;

	public var indices:Array<UInt>;
	public var layer(get, set):Int;
	public var order(default, set):UInt;

	public var transform_matrix(default, null):Matrix;

	public var added(default, null):Bool = false;
	
	public var dirty:Bool = false;

	var _layer:Int = 0;
	var _texture:Texture;
	
	var next:Geometry;
	var prev:Geometry;


	public function new(_options:GeometryOptions) {

		sort_key = 0;

		geometry_type = GeometryType.polygon;

		transform_matrix = new Matrix();

		visible = def(_options.visible, true);
		indices = def(_options.indices, []);
		vertices = def(_options.vertices, []);
		color = def(_options.color, new Color());
		_layer = def(_options.layer, 0);
		order = def(_options.order, 0);
		texture = def(_options.texture, texture);

	}

	public function init() {}
	public function destroy() {}

	public function add(v:Vertex):Geometry {

		vertices.push(v);

		return this;

	}

	public function remove(v:Vertex):Geometry {

		vertices.remove(v);

		return this;

	}

	public function set_indices(v:Array<UInt>):Geometry {

		indices = v;

		return this;

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

	inline function get_layer():Int {

		return _layer;

	}

	function set_layer(v:Int):Int {

		if(added) {
			var lr = Clay.renderer.layers.get(_layer);
			if(lr != null) {
				lr.remove(this);
			}

			lr = Clay.renderer.layers.get(v);
			if(lr != null) {
				lr.add(this);
			} else {
				log('Error adding geometry to layer ${v}');
			}
		}

		return _layer = v;

	}

	function set_shader(v:Shader):Shader {

		sort_key.shader = v.id;

		update_order();

		return shader = v;

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

		update_order();

		return _texture = v;

	}

	function set_geometry_type(v:GeometryType):GeometryType {

		sort_key.geometry_type = v;

		update_order();

		return geometry_type = v;

	}

	function set_order(v:UInt):UInt {

		sort_key.order = v;

		update_order();

		return order = v;

	}

	inline function update_order() {

		if(added) {
			var lr = Clay.renderer.layers.get(layer);
			if(lr != null && lr.ordered) {
				lr.remove(this);
				lr.add(this);
			}
		}

	}

	inline function set_sort_key(val:UInt, bnum:Int, offset:Int) {
		
		sort_key = Bits.clear_range(sort_key, offset+1, offset+bnum);
		sort_key = Bits.set_to_pos(sort_key, val, offset);

	}


}


@:enum abstract GeometryType(UInt) from UInt to UInt {
	// todo
	var polygon         = 0;
	var quad            = 1;
	var text            = 2;
	var instanced       = 3;
	
	var none            = 4;

}


typedef GeometryOptions = {

	@:optional var texture:Texture;
	@:optional var vertices:Array<Vertex>;
	@:optional var indices:Array<Int>;
	@:optional var visible:Bool;
	@:optional var layer:Int;
	@:optional var shader:Shader;
	@:optional var color:Color;
	@:optional var order:UInt;

}