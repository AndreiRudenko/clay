package clay.math;

import kha.FastFloat;

abstract FastVector4(kha.math.FastVector4) from kha.math.FastVector4 to kha.math.FastVector4 {

	public var x(get, set):FastFloat;
	inline function get_x() return this.x; 
	inline function set_x(v:FastFloat) return this.x = v; 

	public var y(get, set):FastFloat;
	inline function get_y() return this.y; 
	inline function set_y(v:FastFloat) return this.y = v; 

	public var z(get, set):FastFloat;
	inline function get_z() return this.z; 
	inline function set_z(v:FastFloat) return this.z = v; 

	public var w(get, set):FastFloat;
	inline function get_w() return this.w; 
	inline function set_w(v:FastFloat) return this.w = v; 

	public var length(get, set):FastFloat;
	inline function get_length() return this.length; 
	inline function set_length(v:FastFloat) return this.length = v; 
	
	public var lengthSq(get, never):FastFloat;
	inline function get_lengthSq() return x * x + y * y + z * z + w * w;

	public inline function new(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this = new kha.math.FastVector4(x, y, z, w);
	}

	public inline function set(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	public inline function copyFrom(other:FastVector4) {
		this.x = other.x;
		this.y = other.y;
		this.z = other.z;
		this.w = other.w;
	}

	public inline function equals(other:FastVector4):Bool {
		return x == other.x && y == other.y && z == other.z && w == other.w;
	}

	public inline function clone() {
		return new FastVector4(x, y, z, w);
	}

	public inline function normalize() {
		return divideScalar(length);
	}

	public inline function invert() {
		x = -x;
		y = -y;
		z = -z;
		w = -w;
	}

	public inline function add(other:FastVector4) {
		this.x += other.x;
		this.y += other.y;
		this.z += other.z;
		this.w += other.w;
	}

	public inline function addXYZW(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this.x += x;
		this.y += y;
		this.z += z;
		this.w += w;
	}

	public inline function addScalar(v:FastFloat) {
		this.x += v;
		this.y += v;
		this.z += v;
		this.w += v;
	}

	public inline function subtract(other:FastVector4) {
		this.x -= other.x;
		this.y -= other.y;
		this.z -= other.z;
		this.w -= other.w;
	}

	public inline function subtractXYZW(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this.x -= x;
		this.y -= y;
		this.z -= z;
		this.w -= w;
	}

	public inline function subtractScalar(v:FastFloat) {
		this.x -= v;
		this.y -= v;
		this.z -= v;
		this.w -= v;
	}

	public inline function multiply(other:FastVector4) {
		this.x *= other.x;
		this.y *= other.y;
		this.z *= other.z;
		this.w *= other.w;
	}

	public inline function multiplyXYZW(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this.x *= x;
		this.y *= y;
		this.z *= z;
		this.w *= w;
	}

	public inline function multiplyScalar(v:FastFloat) {
		this.x *= v;
		this.y *= v;
		this.z *= v;
		this.w *= v;
	}

	public inline function divide(other:FastVector4) {
		this.x /= other.x;
		this.y /= other.y;
		this.z /= other.z;
		this.w /= other.w;
	}

	public inline function divideXYZW(x:FastFloat, y:FastFloat, z:FastFloat, w:FastFloat) {
		this.x /= x;
		this.y /= y;
		this.z /= z;
		this.w /= w;
	}

	public inline function divideScalar(v:FastFloat) {
		this.x /= v;
		this.y /= v;
		this.z /= v;
		this.w /= v;
	}

	static public inline function Add(a:FastVector4, b:FastVector4) {
	    return new FastVector4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
	}

	static public inline function AddScalar(a:FastVector4, v:FastFloat) {
	    return new FastVector4(a.x + v, a.y + v, a.z + v, a.w + v);
	}

	static public inline function Subtract(a:FastVector4, b:FastVector4) {
	    return new FastVector4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
	}

	static public inline function SubtractScalar(a:FastVector4, v:FastFloat) {
	    return new FastVector4(a.x - v, a.y - v, a.z - v, a.w - v);
	}

	static public inline function Multiply(a:FastVector4, b:FastVector4) {
	    return new FastVector4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w);
	}

	static public inline function MultiplyScalar(a:FastVector4, v:FastFloat) {
	    return new FastVector4(a.x * v, a.y * v, a.z * v, a.w * v);
	}

	static public inline function Divide(a:FastVector4, b:FastVector4) {
	    return new FastVector4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w);
	}

	static public inline function DivideScalar(a:FastVector4, v:FastFloat) {
	    return new FastVector4(a.x / v, a.y / v, a.z / v, a.w / v);
	}

}

