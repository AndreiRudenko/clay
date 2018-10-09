package clay.render;


import clay.utils.Bits;
import clay.math.Mathf;

@:access(clay.render.Renderer)
abstract GeometrySortKey(UInt) from UInt to UInt {


	@:op(A > B) private static function gt(lhs:GeometrySortKey, rhs:GeometrySortKey):Bool;
	@:op(A >= B) private static function gte(lhs:GeometrySortKey, rhs:GeometrySortKey):Bool;
	@:op(A < B) private static function lt(lhs:GeometrySortKey, rhs:GeometrySortKey):Bool;
	@:op(A <= B) private static function lte(lhs:GeometrySortKey, rhs:GeometrySortKey):Bool;


	public var order(get, set):UInt;
	public var texture(get, set):UInt;
	public var shader(get, set):UInt;
	public var geometry_type(get, set):UInt;
	public var clip(get, set):Bool;


	public inline function new(_v:UInt) {
	    
		this = _v;

	}

	inline function get_shader():UInt {

		return get_sort_key(Clay.renderer.shader_bits, Clay.renderer.shader_offset);

	}

	inline function set_shader(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.shader_max);
		set_sort_key(id, Clay.renderer.shader_bits, Clay.renderer.shader_offset);

		return id;

	}

	inline function get_texture():UInt {

		return get_sort_key(Clay.renderer.texture_bits, Clay.renderer.texture_offset);

	}
	
	inline function set_texture(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.texture_max);
		set_sort_key(id, Clay.renderer.texture_bits, Clay.renderer.texture_offset);

		return id;

	}

	inline function get_geometry_type():UInt {

		return get_sort_key(Clay.renderer.geomtype_bits, Clay.renderer.geomtype_offset);

	}

	inline function set_geometry_type(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.geomtype_max);
		set_sort_key(id, Clay.renderer.geomtype_bits, Clay.renderer.geomtype_offset);

		return id;

	}

	inline function get_order():UInt {

		return get_sort_key(Clay.renderer.order_bits, Clay.renderer.order_offset);

	}

	inline function set_order(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.order_max);
		set_sort_key(id, Clay.renderer.order_bits, Clay.renderer.order_offset);

		return id;

	}

	inline function get_clip():Bool {

		return get_sort_key(Clay.renderer.clip_bits, Clay.renderer.clip_offset) == 1;

	}

	inline function set_clip(v:Bool):Bool {

		set_sort_key(v ? 1 : 0, Clay.renderer.clip_bits, Clay.renderer.clip_offset);

		return v;

	}

	inline function set_sort_key(val:UInt, bnum:Int, offset:Int) {
		
		this = Bits.clear_range(this, offset+1, offset+bnum);
		this = Bits.set_to_pos(this, val, offset);

	}

	inline function get_sort_key(bnum:Int, offset:Int):Int {
		
		return Bits.extract_range(this, offset+1, bnum);

	}


}