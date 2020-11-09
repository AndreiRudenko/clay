package clay.math;

@:structInit
class Vector2 {

	public var x(default, set):Float;
	var _x:Float;
	inline function get_x() return _x;
	function set_x(v:Float) return _x = v;

	public var y(default, set):Float;
	var _y:Float;
	inline function get_y() return _y;
	function set_y(v:Float) return _y = v;

	public var length(get, set):Float;
	inline function get_length() return Math.sqrt(x * x + y * y);
	inline function set_length(v:Float) {
		normalize();
		multiplyScalar(v);
		return v;
	}

	public var lengthSq(get, never):Float;
	inline function get_lengthSq() return x * x + y * y;

	public inline function new(x:Float = 0, y:Float = 0) {
		_x = x;
		_y = y;
	}

	public function set(x:Float, y:Float) {
		_x = x;
		_y = y;
		
		return this;
	}

	public inline function copyFrom(other:Vector2) {
		set(other.x, other.y);
		return this;
	}

	public inline function equals(other:Vector2):Bool {
		return x == other.x && y == other.y;
	}

	public inline function clone() {
		return new Vector2(x, y);
	}

	public inline function normalize() {
		return divideScalar(length);
	}

	public inline function dot(other:Vector2) {
		return x * other.x + y * other.y;
	}

	public inline function cross(other:Vector2) {
		return x * other.y - y * other.x;
	}

	public inline function distance(other:Vector2) {
		return Math.sqrt((other.y - y) * (other.y - y) + (other.x - x) * (other.x - x));
	}

	public inline function invert() {
		set(-x, -y);
		return this;
	}

	public inline function add(other:Vector2) {
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

	public inline function subtract(other:Vector2) {
		set(x - other.x, y - other.y);
		return this;
	}

	public inline function subtractXY(x:Float, y:Float) {
		set(this.x - x, this.y - y);
		return this;
	}

	public inline function subtractScalar(v:Float) {
		set(x - v, y - v);
		return this;
	}

	public inline function multiply(other:Vector2) {
		set(x * other.x, y * other.y);
		return this;
	}

	public inline function multiplyXY(x:Float, y:Float) {
		set(this.x * x, this.y * y);
		return this;
	}

	public inline function multiplyScalar(v:Float) {
		set(x * v, y * v);
		return this;
	}

	public inline function divide(other:Vector2) {
		set(x / other.x, y / other.y);
		return this;
	}

	public inline function divideXY(x:Float, y:Float) {
		set(this.x / x, this.y / y);
		return this;
	}

	public inline function divideScalar(v:Float) {
		set(x / v, y / v);
		return this;
	}

	public inline function perpendicular(clockwise:Bool = true) {
		if(clockwise) {
			set(y, -x);
		} else {
			set(-y, x);
		}
		return this;
	}

	public inline function rotate(radians:Float) {
		var ca = Math.cos(radians);
		var sa = Math.sin(radians);
		set(ca * x - sa * y, sa * x + ca * y);
		return this;
	}

	public inline function transform(a:Float, b:Float, c:Float, d:Float, tx:Float, ty:Float) {
		set(a * x + c * y + tx, b * x + d * y + ty);
		return this;
	}
	
	// return angle in radians
	public inline function angle2D(other:Vector2):Float {
		return Math.atan2(other.y - y, other.x - x);
	}

	static public inline function Add(a:Vector2, b:Vector2) {
	    return new Vector2(a.x + b.x, a.y + b.y);
	}

	static public inline function AddScalar(a:Vector2, v:Float) {
	    return new Vector2(a.x + v, a.y + v);
	}

	static public inline function Subtract(a:Vector2, b:Vector2) {
	    return new Vector2(a.x - b.x, a.y - b.y);
	}

	static public inline function SubtractScalar(a:Vector2, v:Float) {
	    return new Vector2(a.x - v, a.y - v);
	}

	static public inline function Multiply(a:Vector2, b:Vector2) {
	    return new Vector2(a.x * b.x, a.y * b.y);
	}

	static public inline function MultiplyScalar(a:Vector2, v:Float) {
	    return new Vector2(a.x * v, a.y * v);
	}

	static public inline function Divide(a:Vector2, b:Vector2) {
	    return new Vector2(a.x / b.x, a.y / b.y);
	}

	static public inline function DivideScalar(a:Vector2, v:Float) {
	    return new Vector2(a.x / v, a.y / v);
	}

	static public inline function Distance(a:Vector2, v:Vector2) {
	    return a.distance(v);
	}

}

