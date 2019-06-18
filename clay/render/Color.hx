package clay.render;


class Color {


	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;


	public function new(_r:Float = 1, _g:Float = 1, _b:Float = 1, _a:Float = 1) {
		
		r = _r;
		g = _g;
		b = _b;
		a = _a;

	}

	public function set(?_r:Float, ?_g:Float, ?_b:Float, ?_a:Float):Color {

		if(_r != null) {
			r = _r;
		}

		if(_g != null) {
			g = _g;
		}

		if(_b != null) {
			b = _b;
		}

		if(_a != null) {
			a = _a;
		}

		return this;

	}

	public function copy_from(other:Color):Color {

		r = other.r;
		g = other.g;
		b = other.b;
		a = other.a;

		return this;
		
	}

	public function from_int(_i:Int):Color {

		var _r = _i >> 16;
		var _g = _i >> 8 & 0xFF;
		var _b = _i & 0xFF;

			//convert to 0-1
		r = _r / 255;
		g = _g / 255;
		b = _b / 255;

		return this;
		
	}

	public function clone():Color {

		return new Color(r, g, b, a);
		
	}

	public function to_int():Int {

		return (Std.int(r*255) << 16) | (Std.int(g*255) << 8) | Std.int(b*255);
		
	}

	public static function random(?_include_alpha:Bool=false) : Color {

		return new Color(Math.random(), Math.random(), Math.random(), _include_alpha ? Math.random() : 1.0 );
		
	}

	public inline function to_json() {

		return {r:r, g:g, b:b, a:a};
		
	}

	public inline function from_json(d:Dynamic):Color {

		r = d.r;
		g = d.g;
		b = d.b;
		a = d.a;

		return this;
	    
	}

	
}