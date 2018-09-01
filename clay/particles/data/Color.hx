package sparkler.data;


class Color {


	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;


	public function new( _r:Float = 1, _g:Float = 1, _b:Float = 1, _a:Float = 1 ) {

		r = _r;
		g = _g;
		b = _b;
		a = _a;
		
	}

	public inline function to_json() {

		return {r:r, g:g, b:b, a:a};
		
	}

	public inline function from_json(d:Dynamic) {

		r = d.r;
		g = d.g;
		b = d.b;
		a = d.a;
	    
	}
	

}

