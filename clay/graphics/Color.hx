package clay.graphics;

import clay.utils.Math;

abstract Color(Int) from kha.Color to kha.Color {

	static public function random(?includeAlpha:Bool = false):Color {
		return new Color(Math.random(), Math.random(), Math.random(), includeAlpha ? Math.random() : 1.0 );
	}

	static public inline var TRANSPARENT:Color = 0x00000000;
	static public inline var BLACK:Color = 0xff000000;
	static public inline var WHITE:Color = 0xffffffff;
	static public inline var RED:Color = 0xffff0000;
	static public inline var BLUE:Color = 0xff0000ff;
	static public inline var GREEN:Color = 0xff00ff00;
	static public inline var MAGENTA:Color = 0xffff00ff;
	static public inline var YELLOW:Color = 0xffffff00;
	static public inline var CYAN:Color = 0xff00ffff;
	static public inline var PURPLE:Color = 0xff800080;
	static public inline var PINK:Color = 0xffffc0cb;
	static public inline var ORANGE:Color = 0xffffa500;

	static inline var invMaxChannelValue: Float = 1 / 255;

	public var r(get, set):Float;
	public var g(get, set):Float;
	public var b(get, set):Float;
	public var a(get, set):Float;

	public var rB(get, set):Int;
	public var gB(get, set):Int;
	public var bB(get, set):Int;
	public var aB(get, set):Int;

	public var value(get, set):Int;

	public inline function new(r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1) {
		this = (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
	}

	public inline function set(r:Float, g:Float, b:Float, a:Float):Color {
		set_r(r);
		set_g(g);
		set_b(b);
		set_a(a);

		return this;
	}

	public inline function setBytes(r:Int, g:Int, b:Int, a:Int):Color {
		set_rB(r);
		set_gB(g);
		set_bB(b);
		set_aB(a);
		
		return this;
	}

	public inline function lerp(to:Color, t:Float):Color {
		t = Math.clamp(t, 0, 1);

		set_r(r + t * (to.r - r));
		set_g(g + t * (to.g - g));
		set_b(b + t * (to.b - b));
		set_a(a + t * (to.a - a));

		return this;
	}

	public inline function setHSB(hue:Float, saturation:Float, brightness:Float):Color {
		var chroma = brightness * saturation;
		var match = brightness - chroma;
		return setHCM(hue, chroma, match);
	}

    public inline function setHSL(hue:Float, saturation:Float, lightness:Float):Color {
        var chroma = (1 - Math.abs(2 * lightness - 1)) * saturation;
        var match = lightness - chroma / 2;
        return setHCM(hue, chroma, match);
    }

	inline function setHCM(hue:Float, chroma:Float, match:Float):Color {
		hue %= 360;
		var hueD = hue / 60;
		var mid = chroma * (1 - Math.abs(hueD % 2 - 1)) + match;
		chroma += match;

		switch (Std.int(hueD)) {
			case 0: setRGB(chroma, mid, match);
			case 1: setRGB(mid, chroma, match);
			case 2: setRGB(match, chroma, mid);
			case 3: setRGB(match, mid, chroma);
			case 4: setRGB(mid, match, chroma);
			case 5: setRGB(chroma, match, mid);
		}

		return this;
	}

	inline function setRGB(r:Float, g:Float, b:Float) {
		set_r(r);
		set_g(g);
		set_b(b);
	}

	inline function get_r():Float {
		return get_rB() * invMaxChannelValue;
	}

	inline function get_g():Float {
		return get_gB() * invMaxChannelValue;
	}

	inline function get_b():Float {
		return get_bB() * invMaxChannelValue;
	}

	inline function get_a():Float {
		return get_aB() * invMaxChannelValue;
	}

	inline function set_r(f:Float):Float {
		this = (Std.int(a * 255) << 24) | (Std.int(f * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
		return f;
	}

	inline function set_g(f:Float):Float {
		this = (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(f * 255) << 8) | Std.int(b * 255);
		return f;
	}

	inline function set_b(f:Float):Float {
		this = (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(f * 255);
		return f;
	}

	inline function set_a(f:Float):Float {
		this = (Std.int(f * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
		return f;
	}

	inline function get_rB():Int {
		return (this & 0x00ff0000) >>> 16;
	}

	inline function get_gB():Int {
		return (this & 0x0000ff00) >>> 8;
	}

	inline function get_bB():Int {
		return this & 0x000000ff;
	}

	inline function get_aB():Int {
		return this >>> 24;
	}

	inline function set_rB(i:Int):Int {
		this = (aB << 24) | (i << 16) | (gB << 8) | bB;
		return i;
	}

	inline function set_gB(i:Int):Int {
		this = (aB << 24) | (rB << 16) | (i << 8) | bB;
		return i;
	}

	inline function set_bB(i:Int):Int {
		this = (aB << 24) | (rB << 16) | (gB << 8) | i;
		return i;
	}

	inline function set_aB(i:Int):Int {
		this = (i << 24) | (rB << 16) | (gB << 8) | bB;
		return i;
	}

	inline function get_value():Int {
		return this;
	}

	inline function set_value(value:Int):Int {
		this = value;
		return this;
	}
	
}