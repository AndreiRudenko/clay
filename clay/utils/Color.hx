package clay.utils;

import clay.utils.Mathf;

class Color {

	public static function random(?includeAlpha:Bool = false):Color {
		return new Color(Math.random(), Math.random(), Math.random(), includeAlpha ? Math.random() : 1.0 );
	}

	public static var TRANSPARENT(default, null):Color = new Color(0,0,0,0);
	public static var WHITE(default, null):Color = new Color(1,1,1,1);
	public static var BLACK(default, null):Color = new Color(0,0,0,1);
	public static var RED(default, null):Color = new Color(1,0,0,1);
	public static var GREEN(default, null):Color = new Color(0,1,0,1);
	public static var BLUE(default, null):Color = new Color(0,0,1,1);
	public static var CYAN(default, null):Color = new Color(0,1,1,1);
	public static var MAGENTA(default, null):Color = new Color(1,0,1,1);
	public static var YELLOW(default, null):Color = new Color(1,1,0,1);

	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;

	public function new(r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}

	public function set(?r:Float, ?g:Float, ?b:Float, ?a:Float):Color {
		if(r != null) {
			this.r = r;
		}

		if(g != null) {
			this.g = g;
		}

		if(b != null) {
			this.b = b;
		}

		if(a != null) {
			this.a = a;
		}

		return this;
	}

	public function lerp(to:Color, t:Float):Color {
		t = Mathf.clamp(t, 0, 1);

		r = (r + t * (to.r - r));
		g = (g + t * (to.g - g));
		b = (b + t * (to.b - b));
		a = (a + t * (to.a - a));

		return this;
	}

	public function copyFrom(other:Color):Color {
		r = other.r;
		g = other.g;
		b = other.b;
		a = other.a;

		return this;
	}

	public function fromInt(i:Int):Color {
		// var _a = i >> 24;
		var r1 = i >> 16;
		var g1 = i >> 8 & 0xFF;
		var b1 = i & 0xFF;

		//convert to 0-1
		r = r1 / 255;
		g = g1 / 255;
		b = b1 / 255;

		return this;
	}

	public function clone():Color {
		return new Color(r, g, b, a);
	}

	public function toInt():Int {
		return (Std.int(a * 255) << 24) | (Std.int(r * 255) << 16) | (Std.int(g * 255) << 8) | Std.int(b * 255);
	}
	
}