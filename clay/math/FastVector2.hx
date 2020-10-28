package clay.math;

import kha.FastFloat;

abstract FastVector2(kha.math.FastVector2) from kha.math.FastVector2 to kha.math.FastVector2 {

	public var x(get, set):FastFloat;
	inline function get_x() return this.x; 
	inline function set_x(v:FastFloat) return this.x = v; 

	public var y(get, set):FastFloat;
	inline function get_y() return this.y; 
	inline function set_y(v:FastFloat) return this.y = v; 

	public var length(get, set):FastFloat;
	inline function get_length() return this.length; 
	inline function set_length(v:FastFloat) return this.length = v; 
	
	public var lengthSq(get, never):FastFloat;
	inline function get_lengthSq() return x * x + y * y;

	public inline function new(x:FastFloat, y:FastFloat) {
		this = new kha.math.FastVector2(x, y);
	}

	public inline function set(x:FastFloat, y:FastFloat) {
		this.x = x;
		this.y = y;
	}

	public inline function copyFrom(other:FastVector2) {
		this.x = other.x;
		this.y = other.y;
	}

	public inline function fromVector2(other:Vector2) {
		this.x = other.x;
		this.y = other.y;
	}

	public inline function equals(other:FastVector2):Bool {
		return x == other.x && y == other.y;
	}

	public inline function clone() {
		return new FastVector2(x, y);
	}

	public inline function perpendicular(clockwise:Bool = false) {
		var tmp:FastFloat = x;
		if(clockwise) {
			x = y;
			y = -tmp;
		} else {
			x = -y;
			y = tmp;
		}
	}

	public inline function normalize() {
		return divideScalar(length);
	}

	public inline function dot(other:FastVector2) {
		return x * other.x + y * other.y;
	}

	public inline function cross(other:FastVector2) {
		return x * other.y - y * other.x;
	}

	public inline function distance(other:FastVector2) {
		return Math.sqrt((other.y - y) * (other.y - y) + (other.x - x) * (other.x - x));
	}

	public inline function invert() {
		x = -x;
		y = -y;
	}

	public inline function add(other:FastVector2) {
		this.x += other.x;
		this.y += other.y;
	}

	public inline function addXY(x:FastFloat, y:FastFloat) {
		this.x += x;
		this.y += y;
	}

	public inline function addScalar(v:FastFloat) {
		this.x += v;
		this.y += v;
	}

	public inline function subtract(other:FastVector2) {
		this.x -= other.x;
		this.y -= other.y;
	}

	public inline function subtractXY(x:FastFloat, y:FastFloat) {
		this.x -= x;
		this.y -= y;
	}

	public inline function subtractScalar(v:FastFloat) {
		this.x -= v;
		this.y -= v;
	}

	public inline function multiply(other:FastVector2) {
		this.x *= other.x;
		this.y *= other.y;
	}

	public inline function multiplyXY(x:FastFloat, y:FastFloat) {
		this.x *= x;
		this.y *= y;
	}

	public inline function multiplyScalar(v:FastFloat) {
		this.x *= v;
		this.y *= v;
	}

	public inline function divide(other:FastVector2) {
		this.x /= other.x;
		this.y /= other.y;
	}

	public inline function divideXY(x:FastFloat, y:FastFloat) {
		this.x /= x;
		this.y /= y;
	}

	public inline function divideScalar(v:FastFloat) {
		this.x /= v;
		this.y /= v;
	}

	public inline function rotate(radians:FastFloat) {
		var ca = Math.cos(radians);
		var sa = Math.sin(radians);
		this.x = ca * x - sa * y;
		this.y = sa * x + ca * y;
	}
	
	// return angle in radians
	public inline function angle2D(other:FastVector2):FastFloat {
		return Math.atan2(other.y - y, other.x - x);
	}

	public inline function transform(m:Matrix) {
		this.x = m.a * x + m.c * y + m.tx;
		this.y = m.b * x + m.d * y + m.ty;
	}

	public inline function transformFast(m:FastMatrix3) {
		this.x = m.a * x + m.c * y + m.tx;
		this.y = m.b * x + m.d * y + m.ty;
	}

	static public inline function Add(a:FastVector2, b:FastVector2) {
	    return new FastVector2(a.x + b.x, a.y + b.y);
	}

	static public inline function AddScalar(a:FastVector2, v:FastFloat) {
	    return new FastVector2(a.x + v, a.y + v);
	}

	static public inline function Subtract(a:FastVector2, b:FastVector2) {
	    return new FastVector2(a.x - b.x, a.y - b.y);
	}

	static public inline function SubtractScalar(a:FastVector2, v:FastFloat) {
	    return new FastVector2(a.x - v, a.y - v);
	}

	static public inline function Multiply(a:FastVector2, b:FastVector2) {
	    return new FastVector2(a.x * b.x, a.y * b.y);
	}

	static public inline function MultiplyScalar(a:FastVector2, v:FastFloat) {
	    return new FastVector2(a.x * v, a.y * v);
	}

	static public inline function Divide(a:FastVector2, b:FastVector2) {
	    return new FastVector2(a.x / b.x, a.y / b.y);
	}

	static public inline function DivideScalar(a:FastVector2, v:FastFloat) {
	    return new FastVector2(a.x / v, a.y / v);
	}

	static public inline function Distance(a:FastVector2, v:FastVector2) {
	    return a.distance(v);
	}

}

