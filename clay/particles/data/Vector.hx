package sparkler.data;


class Vector {


	public var x:Float;
	public var y:Float;


	public function new( _x:Float = 0, _y:Float = 0 ) {

		x = _x;
		y = _y;
		
	}

	@:arrayAccess
	public inline function get(_k:Int):Float {

		return switch(_k) {
			case 0: x;
			case 1: y;
			case _: throw 'Index ${_k} out of bounds (0-1)!';
		};

	}
	
	@:arrayAccess
	public inline function set( _k:Int, _v:Float ):Float {

		return switch(_k) {
			case 0: x = _v;
			case 1: y = _v;
			case _: throw 'Index ${_k} out of bounds (0-1)!';
		};

	}
	
	public inline function set_xy( _x:Float, _y:Float ) {

		x = _x;
		y = _y;

		return this;
		
	}

	public inline function copy_from( _other:Vector ) {

		x = _other.x;
		y = _other.y;

		return this;
		
	}

	public inline function clone() {

		return new Vector(x, y);
		
	}

	public inline function normalize() {

        return divide_scalar( length() );
		
	}

	public inline function dot( _other:Vector ) {

		return x * _other.x + y * _other.y;

	}

	public inline function length() {

		return Math.sqrt( x * x + y * y );

	}

	public inline function lengthsq() {

		return x * x + y * y;

	}

	public inline function add( _other:Vector ) {

		set_xy(x + _other.x, y + _other.y);

		return this;
		
	}

	public inline function add_xy( _x:Float, _y:Float ) {

		set_xy(x + _x, y + _y);

		return this;
		
	}

	public inline function add_scalar( _v:Float ) {

		set_xy(x + _v, y + _v);

		return this;
		
	}

	public inline function subtract( _other:Vector ) {

		set_xy(x - _other.x, y - _other.y);

		return this;
		
	}

	public inline function subtract_xy( _x:Float, _y:Float ) {

		set_xy(x - _x, y - _y);

		return this;
		
	}

	public inline function subtract_scalar( _v:Float ) {

		set_xy(x - _v, y - _v);

		return this;
		
	}

	public inline function multiply( _other:Vector ) {

		set_xy(x * _other.x, y * _other.y);

		return this;
		
	}

	public inline function multiply_xy( _x:Float, _y:Float ) {

		set_xy(x * _x, y * _y);

		return this;
		
	}

	public inline function multiply_scalar( _v:Float ) {

		set_xy(x * _v, y * _v);

		return this;
		
	}

	public inline function divide( _other:Vector ) {

		set_xy(x / _other.x, y / _other.y);

		return this;
		
	}

	public inline function divide_xy( _x:Float, _y:Float ) {

		set_xy(x / _x, y / _y);

		return this;
		
	}

	public inline function divide_scalar( _v:Float ) {

		set_xy(x / _v, y / _v);

		return this;
		
	}

	public inline function to_json() {

		return {x:x, y:y};
	    
	}

	public inline function from_json(d:Dynamic) {

		x = d.x;
		y = d.y;

		return this;
	    
	}
	

}

