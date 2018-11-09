package clay.render;


import clay.utils.Bits;
import clay.math.Mathf;

@:access(clay.render.Renderer)
abstract GeometrySortKey(__SortKey) from __SortKey to __SortKey {


	@:op(A > B) private static inline function gt(a:GeometrySortKey, b:GeometrySortKey):Bool {
		return compare(a, b) > 0;
	}

	@:op(A >= B) private static inline function gte(a:GeometrySortKey, b:GeometrySortKey):Bool {
		return compare(a, b) >= 0;
	}

	@:op(A < B) private static inline function lt(a:GeometrySortKey, b:GeometrySortKey):Bool {
		return compare(a, b) < 0;
	}

	@:op(A <= B) private static inline function lte(a:GeometrySortKey, b:GeometrySortKey):Bool {
		return compare(a, b) <= 0;
	}

	private static inline function compare( a : GeometrySortKey, b : GeometrySortKey ) : Float {

		var v:Float = a.depth - b.depth;

		if(v == 0) {
			v = a.other - b.other;
		}

		return v;

	}

	public var depth(get, set):Float;
	public var texture(get, set):UInt;
	public var shader(get, set):UInt;
	public var geometry_type(get, set):UInt;
	public var clip(get, set):Bool;

	@:noCompletion public var other(get, set):UInt;


	public inline function new(_depth:Float, _other:UInt) {

		this = new __SortKey(_depth, _other);

	}

	inline function get_depth():Float {

		return this.depth;

	}

	inline function set_depth(v:Float):Float {

		return this.depth = v;

	}

	inline function get_other():UInt {

		return this.other;

	}

	inline function set_other(v:UInt):UInt {

		return this.other = v;

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

	inline function get_clip():Bool {

		return get_sort_key(Clay.renderer.clip_bits, Clay.renderer.clip_offset) == 1;

	}

	inline function set_clip(v:Bool):Bool {

		set_sort_key(v ? 1 : 0, Clay.renderer.clip_bits, Clay.renderer.clip_offset);

		return v;

	}

	inline function set_sort_key(val:UInt, bnum:Int, offset:Int) {
		
		this.other = Bits.clear_range(this.other, offset+1, offset+bnum);
		this.other = Bits.set_to_pos(this.other, val, offset);

	}

	inline function get_sort_key(bnum:Int, offset:Int):Int {
		
		return Bits.extract_range(this.other, offset+1, bnum);

	}

	public function toString() : String {

		return '{depth: ${depth}, shader: ${shader}, texture: ${texture}, geometry_type: ${geometry_type}, clip: ${clip}}';

	}

}


private class __SortKey {


	public var depth:Float;
	public var other:UInt;


	public function new(_depth:Float, _other:UInt) {
		
		depth = _depth;
		other = _other;

	}


}