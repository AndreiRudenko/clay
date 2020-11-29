package clay.math;

import kha.FastFloat;

abstract FastVector3(kha.math.FastVector3) from kha.math.FastVector3 to kha.math.FastVector3 {

	public var x(get, set):FastFloat;
	inline function get_x() return this.x; 
	inline function set_x(v:FastFloat) return this.x = v; 

	public var y(get, set):FastFloat;
	inline function get_y() return this.y; 
	inline function set_y(v:FastFloat) return this.y = v; 

	public var z(get, set):FastFloat;
	inline function get_z() return this.z; 
	inline function set_z(v:FastFloat) return this.z = v; 

	public var length(get, set):FastFloat;
	inline function get_length() return this.length; 
	inline function set_length(v:FastFloat) return this.length = v; 
	
	public var lengthSq(get, never):FastFloat;
	inline function get_lengthSq() return x * x + y * y + z * z;

	public inline function new(x:FastFloat, y:FastFloat, z:FastFloat) {
		this = new kha.math.FastVector3(x, y, z);
	}

	public inline function set(x:FastFloat, y:FastFloat, z:FastFloat) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public inline function copyFrom(other:FastVector3) {
		this.x = other.x;
		this.y = other.y;
		this.z = other.z;
	}

	public inline function equals(other:FastVector3):Bool {
		return x == other.x && y == other.y && z == other.z;
	}

	public inline function clone() {
		return new FastVector3(x, y, z);
	}

	public inline function normalize() {
		return divideScalar(length);
	}

	public inline function dot(other:FastVector3) {
		return x * other.x + y * other.y + z * other.z;
	}

	public inline function cross(other:FastVector3) {
		set(
			y * other.z - z * other.y, 
			z * other.x - x * other.z, 
			x * other.y - y * other.x
		);
	}

	public inline function distance(other:FastVector3) {
		var dx = x - other.x;
		var dy = y - other.y;
		var dz = z - other.z;
		return Math.sqrt(dx * dx + dy * dy + dz * dz);
	}

	public inline function invert() {
		x = -x;
		y = -y;
		z = -z;
	}

	public inline function add(other:FastVector3) {
		this.x += other.x;
		this.y += other.y;
		this.z += other.z;
	}

	public inline function addXYZ(x:FastFloat, y:FastFloat, z:FastFloat) {
		this.x += x;
		this.y += y;
		this.z += z;
	}

	public inline function addScalar(v:FastFloat) {
		this.x += v;
		this.y += v;
		this.z += v;
	}

	public inline function subtract(other:FastVector3) {
		this.x -= other.x;
		this.y -= other.y;
		this.z -= other.z;
	}

	public inline function subtractXYZ(x:FastFloat, y:FastFloat, z:FastFloat) {
		this.x -= x;
		this.y -= y;
		this.z -= z;
	}

	public inline function subtractScalar(v:FastFloat) {
		this.x -= v;
		this.y -= v;
		this.z -= v;
	}

	public inline function multiply(other:FastVector3) {
		this.x *= other.x;
		this.y *= other.y;
		this.z *= other.z;
	}

	public inline function multiplyXYZ(x:FastFloat, y:FastFloat, z:FastFloat) {
		this.x *= x;
		this.y *= y;
		this.z *= z;
	}

	public inline function multiplyScalar(v:FastFloat) {
		this.x *= v;
		this.y *= v;
		this.z *= v;
	}

	public inline function divide(other:FastVector3) {
		this.x /= other.x;
		this.y /= other.y;
		this.z /= other.z;
	}

	public inline function divideXYZ(x:FastFloat, y:FastFloat, z:FastFloat) {
		this.x /= x;
		this.y /= y;
		this.z /= z;
	}

	public inline function divideScalar(v:FastFloat) {
		this.x /= v;
		this.y /= v;
		this.z /= v;
	}

	// public inline function rotate(quat:Quaternion) {

	// }
	

	static public inline function Add(a:FastVector3, b:FastVector3) {
	    return new FastVector3(a.x + b.x, a.y + b.y, a.z + b.z);
	}

	static public inline function AddScalar(a:FastVector3, v:FastFloat) {
	    return new FastVector3(a.x + v, a.y + v, a.z + v);
	}

	static public inline function Subtract(a:FastVector3, b:FastVector3) {
	    return new FastVector3(a.x - b.x, a.y - b.y, a.z - b.z);
	}

	static public inline function SubtractScalar(a:FastVector3, v:FastFloat) {
	    return new FastVector3(a.x - v, a.y - v, a.z - v);
	}

	static public inline function Multiply(a:FastVector3, b:FastVector3) {
	    return new FastVector3(a.x * b.x, a.y * b.y, a.z * b.z);
	}

	static public inline function MultiplyScalar(a:FastVector3, v:FastFloat) {
	    return new FastVector3(a.x * v, a.y * v, a.z * v);
	}

	static public inline function Divide(a:FastVector3, b:FastVector3) {
	    return new FastVector3(a.x / b.x, a.y / b.y, a.z / b.z);
	}

	static public inline function DivideScalar(a:FastVector3, v:FastFloat) {
	    return new FastVector3(a.x / v, a.y / v, a.z / v);
	}

	static public inline function Distance(a:FastVector3, v:FastVector3) {
	    return a.distance(v);
	}

}

