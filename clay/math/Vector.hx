package clay.math;


class Vector {


	public var x(default, set):Float;
	public var y(default, set):Float;

	public var length(get, set):Float;
	public var lengthSq(get, never):Float;


	public function new(x:Float = 0, y:Float = 0) {

		this.x = x;
		this.y = y;
		
	}

	public inline function set(x:Float, y:Float) {

		this.x = x;
		this.y = y;
		
		return this;
		
	}

	public inline function copyFrom(other:Vector) {

		x = other.x;
		y = other.y;

		return this;
		
	}

	public inline function equals(other:Vector):Bool {

		return x == other.x && y == other.y;
		
	}

	public inline function clone() {

		return new Vector(x, y);
		
	}

	public inline function normalize() {

		return divideScalar(length);
		
	}

	public inline function dot(other:Vector) {

		return x * other.x + y * other.y;

	}

	public inline function distance(other:Vector) {

		return Math.sqrt((other.y - y) * (other.y - y) + (other.x - x) * (other.x - x));

	}

	public inline function invert() {

		set(-x, -y);

		return this;
		
	}

	public inline function add(other:Vector) {

		set(x + other.x, y + other.y);

		return this;
		
	}

	public inline function addXY(x:Float, y:Float) {

		set(this.x + x, this.y + y);

		return this;
		
	}

	public inline function addScalar(v:Float) {

		set(x + v, y + v);

		return this;
		
	}

	public inline function subtract(other:Vector) {

		set(x - other.x, y - other.y);

		return this;
		
	}

	public inline function subtractXY(_x:Float, _y:Float) {

		set(this.x - x, this.y - y);

		return this;
		
	}

	public inline function subtractScalar(v:Float) {

		set(x - v, y - v);

		return this;
		
	}

	public inline function multiply(other:Vector) {

		set(x * other.x, y * other.y);

		return this;
		
	}

	public inline function multiplyXY(_x:Float, _y:Float) {

		set(this.x * x, this.y * y);

		return this;
		
	}

	public inline function multiplyScalar(v:Float) {

		set(x * v, y * v);

		return this;
		
	}

	public inline function divide(other:Vector) {

		set(x / other.x, y / other.y);

		return this;
		
	}

	public inline function divideXY(_x:Float, _y:Float) {

		set(this.x / x, this.y / y);

		return this;
		
	}

	public inline function divideScalar(v:Float) {

		set(x / v, y / v);

		return this;
		
	}

	public inline function transform(m:Matrix) {

		set(m.a * x + m.c * y + m.tx, m.b * x + m.d * y + m.ty);

		return this;
		
	}
	
	inline function get_lengthSq() {

		return x * x + y * y;

	}

	inline function get_length() {

		return Math.sqrt(x * x + y * y);

	}

	inline function set_length(v:Float) {

		normalize().multiplyScalar(v);
		return v;

	}

	function set_x(v:Float) {

		return x = v;

	}

	function set_y(v:Float) {

		return y = v;

	}


}

