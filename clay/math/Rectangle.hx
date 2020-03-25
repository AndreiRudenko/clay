package clay.math;

class Rectangle {

	public var x(default, set):Float;
	public var y(default, set):Float;
	public var w(default, set):Float;
	public var h(default, set):Float;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		set(x, y, w, h);
	}

	public function set(x:Float, y:Float, w:Float, h:Float):Rectangle {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;

		return this;
	}
	
	public function pointInside(point:Vector) {
		if(point.x < x) return false;
		if(point.y < y) return false;
		if(point.x > x + w) return false;
		if(point.y > y + h) return false;

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

	public function equals(other:Rectangle):Bool {
		return x == other.x && 
			y == other.y && 
			w == other.w && 
			h == other.h;
	}

	public inline function copyFrom(other:Rectangle):Rectangle {
		return set(other.x, other.y, other.w, other.h);
	}

	public function clone():Rectangle {
		return new Rectangle(x, y, w, h);
	}

	function set_x(v:Float) {
		return x = v;
	}

	function set_y(v:Float) {
		return y = v;
	}

	function set_w(v:Float) {
		return w = v;
	}

	function set_h(v:Float) {
		return h = v;
	}

	@:noCompletion public function toString() {
		return '{$x, $y, $w, $h}';
	}

}