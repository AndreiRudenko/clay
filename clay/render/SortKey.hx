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

	private static inline function compare(a:SortKey, b:SortKey):Float {
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

	public inline function new(depth:Float, other:UInt) {
		this = new __SortKey(depth, other);
	}

	inline function setSortKey(val:UInt, bnum:Int, offset:Int) {
		this.other = Bits.clearRange(this.other, offset+1, offset+bnum);
		this.other = Bits.setToPos(this.other, val, offset);
	}

	inline function getSortKey(bnum:Int, offset:Int):Int {
		return Bits.extractRange(this.other, offset+1, bnum);
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
		return getSortKey(Clay.renderer.sortOptions.shaderBits, Clay.renderer.sortOptions.shaderOffset);
	}

	inline function set_shader(id:UInt):UInt {
		id = Mathf.clampi(id, 0, Clay.renderer.sortOptions.shaderMax);
		setSortKey(id, Clay.renderer.sortOptions.shaderBits, Clay.renderer.sortOptions.shaderOffset);

		return id;
	}

	inline function get_texture():UInt {
		return getSortKey(Clay.renderer.sortOptions.textureBits, Clay.renderer.sortOptions.textureOffset);
	}
	
	inline function set_texture(id:UInt):UInt {
		id = Mathf.clampi(id, 0, Clay.renderer.sortOptions.textureMax);
		setSortKey(id, Clay.renderer.sortOptions.textureBits, Clay.renderer.sortOptions.textureOffset);

		return id;
	}

	inline function get_clip():Bool {
		return getSortKey(Clay.renderer.sortOptions.clipBits, Clay.renderer.sortOptions.clipOffset) == 1;
	}

	inline function set_clip(v:Bool):Bool {
		setSortKey(v ? 1 : 0, Clay.renderer.sortOptions.clipBits, Clay.renderer.sortOptions.clipOffset);
		return v;
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

	public var clipBits(default, null):Int;
	public var textureBits(default, null):Int;
	public var shaderBits(default, null):Int;

	public var clipOffset(default, null):Int;
	public var textureOffset(default, null):Int;
	public var shaderOffset(default, null):Int;

	public var textureMax(default, null):Int;
	public var shaderMax(default, null):Int;

	public function new(shaderBits:Int = 10, textureBits:Int = 19) {
		this.shaderBits = shaderBits;
		this.textureBits = textureBits;
		clipBits = 1;

		clipOffset = 0;
		textureOffset = clipBits;
		shaderOffset = clipBits + this.textureBits;

		textureMax = Bits.countSinged(this.textureBits);
		shaderMax = Bits.countSinged(this.shaderBits);
	}

}
