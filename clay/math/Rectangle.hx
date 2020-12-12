package clay.math;

@:structInit
class Rectangle {

	public var x(get, set):Float;
	var _x:Float;
	inline function get_x() return _x; 
	function set_x(v:Float) return _x = v;
	
	public var y(get, set):Float;
	var _y:Float;
	inline function get_y() return _y; 
	function set_y(v:Float) return _y = v;
	
	public var w(get, set):Float;
	var _w:Float;
	inline function get_w() return _w; 
	function set_w(v:Float) return _w = v;
	
	public var h(get, set):Float;
	var _h:Float;
	inline function get_h() return _h; 
	function set_h(v:Float) return _h = v;
	
	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		_x = x;
		_y = y;
		_w = w;
		_h = h;
	}

	public function set(x:Float, y:Float, w:Float, h:Float):Rectangle {
		_x = x;
		_y = y;
		_w = w;
		_h = h;

		return this;
	}
	
	public function pointInside(px:Float, py:Float) {
		if(px < x) return false;
		if(py < y) return false;
		if(px > x + w) return false;
		if(py > y + h) return false;

		return true;
	}

	public function overlaps(other:Rectangle) {
		if(
			x < (other.x + other.w) && 
			y < (other.y + other.h) && 
			(x + w) > other.x && 
			(y + h) > other.y 
		) {
			return true;
		}

		return false;
	}

	public function clamp(other:Rectangle) {
		if(x < other.x) {
			w -= other.x - x;
			x = other.x;
		}

		if(y < other.y) {
			h -= other.y - y;
			y = other.y;
		}

		if(x + w > other.x + other.w) {
			w = other.x + other.w - x;
		}

		if(y + h > other.y + other.h) {
			h = other.y + other.h - y;
		}
	}

	public function expand(other:Rectangle) {
		if(other.x < x) {
			x = other.x;
		}

		if(other.y < y) {
			y = other.y;
		}

		if(x + w < other.x + other.w) {
			w = other.x + other.w - x;
		}
		
		if(y + h < other.y + other.h) {
			h = other.y + other.h - y;
		}
	}

	public inline function equals(other:Rectangle):Bool {
		return x == other.x && 
			y == other.y && 
			w == other.w && 
			h == other.h;
	}

	public inline function copyFrom(other:Rectangle):Rectangle {
		return set(other.x, other.y, other.w, other.h);
	}

	public inline function clone():Rectangle {
		return new Rectangle(x, y, w, h);
	}

	@:noCompletion public function toString() {
		return '{$x, $y, $w, $h}';
	}

}