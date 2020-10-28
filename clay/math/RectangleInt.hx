package clay.math;

class RectangleInt {

	public var x(get, set):Int;
	var _x:Int;
	inline function get_x() return _x; 
	function set_x(v:Int):Int {
		return _x = v;
	}

	public var y(get, set):Int;
	var _y:Int;
	inline function get_y() return _y; 
	function set_y(v:Int):Int {
		return _y = v;
	}

	public var w(get, set):Int;
	var _w:Int;
	inline function get_w() return _w; 
	function set_w(v:Int):Int {
		return _w = v;
	}

	public var h(get, set):Int;
	var _h:Int;
	inline function get_h() return _h; 
	function set_h(v:Int):Int {
		return _h = v;
	}

	public function new(x:Int = 0, y:Int = 0, w:Int = 0, h:Int = 0) {
		set(x, y, w, h);
	}

	public function set(x:Int, y:Int, w:Int, h:Int):RectangleInt {
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

	public function overlaps(other:RectangleInt) {
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

	public function clamp(other:RectangleInt) {
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

	public function expand(other:RectangleInt) {
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

	public function equals(other:RectangleInt):Bool {
		return x == other.x && 
			y == other.y && 
			w == other.w && 
			h == other.h;
	}

	public inline function copyFrom(other:RectangleInt):RectangleInt {
		return set(other.x, other.y, other.w, other.h);
	}

	public function clone():RectangleInt {
		return new RectangleInt(x, y, w, h);
	}

	@:noCompletion public function toString() {
		return '{$x, $y, $w, $h}';
	}

}