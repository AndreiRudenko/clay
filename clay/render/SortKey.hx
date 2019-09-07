package clay.render;


import clay.utils.Bits;
import clay.utils.Mathf;

// @:keep
@:access(clay.render.Renderer)
abstract SortKey(__SortKey) from __SortKey to __SortKey {
	

	// geometry sorting, 32bit float ( depth ) + 32bit uint ( texture | shader | renderer | clip )


	@:op(A > B) private static inline function gt(a:SortKey, b:SortKey):Bool {
		return compare(a, b) > 0;
	}

	@:op(A >= B) private static inline function gte(a:SortKey, b:SortKey):Bool {
		return compare(a, b) >= 0;
	}

	@:op(A < B) private static inline function lt(a:SortKey, b:SortKey):Bool {
		return compare(a, b) < 0;
	}

	@:op(A <= B) private static inline function lte(a:SortKey, b:SortKey):Bool {
		return compare(a, b) <= 0;
	}

	private static inline function compare( a : SortKey, b : SortKey ) : Float {

		var v:Float = a.depth - b.depth;

		if(v == 0) {
			v = a.other - b.other;
		}

		return v;

	}

	public var depth(get, set):Float;
	public var texture(get, set):UInt;
	public var shader(get, set):UInt;
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

		return get_sort_key(Clay.renderer.sort_options.shader_bits, Clay.renderer.sort_options.shader_offset);

	}

	inline function set_shader(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.sort_options.shader_max);
		set_sort_key(id, Clay.renderer.sort_options.shader_bits, Clay.renderer.sort_options.shader_offset);

		return id;

	}

	inline function get_texture():UInt {

		return get_sort_key(Clay.renderer.sort_options.texture_bits, Clay.renderer.sort_options.texture_offset);

	}
	
	inline function set_texture(id:UInt):UInt {

		id = Mathf.clampi(id, 0, Clay.renderer.sort_options.texture_max);
		set_sort_key(id, Clay.renderer.sort_options.texture_bits, Clay.renderer.sort_options.texture_offset);

		return id;

	}

	inline function get_clip():Bool {

		return get_sort_key(Clay.renderer.sort_options.clip_bits, Clay.renderer.sort_options.clip_offset) == 1;

	}

	inline function set_clip(v:Bool):Bool {

		set_sort_key(v ? 1 : 0, Clay.renderer.sort_options.clip_bits, Clay.renderer.sort_options.clip_offset);

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

		return '{depth: ${depth}, shader: ${shader}, texture: ${texture}, clip: ${clip}}';

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


class SortOptions {


	public var clip_bits      	(default, null):Int;
	public var texture_bits   	(default, null):Int;
	public var shader_bits    	(default, null):Int;

	public var clip_offset    	(default, null):Int;
	public var texture_offset 	(default, null):Int;
	public var shader_offset  	(default, null):Int;

	public var texture_max    	(default, null):Int;
	public var shader_max     	(default, null):Int;


	public function new(_shader_bits:Int = 10, _texture_bits:Int = 19) {
		
		shader_bits = _shader_bits;
		texture_bits = _texture_bits;
		clip_bits = 1;

		clip_offset = 0;
		texture_offset = clip_bits;
		shader_offset = clip_bits + texture_bits;

		texture_max = Bits.count_singed(texture_bits);
		shader_max = Bits.count_singed(shader_bits);

	}


}
