package clay.math;

class Bounds {

	public var min:Vector;
	public var max:Vector;

	public function new(minX:Float = 0, minY:Float = 0, maxX:Float = 0, maxY:Float = 0) {
		min = new Vector(minX, minY);
		max = new Vector(maxX, maxY);
	}

	public function set(minX:Float, minY:Float, maxX:Float, maxY:Float):Bounds {
		min.set(minX, minY);
		max.set(maxX, maxY);
		
		return this;
	}
	
	public function pointInside(point:Vector):Bool {
		if(point.x < min.x) return false;
		if(point.y < min.y) return false;
		if(point.x > max.x) return false;
		if(point.y > max.y) return false;

		return true;
	}

	public function overlaps(other:Bounds) {
		if( min.x < (other.max.x) &&
			min.y < (other.max.y) &&
			(max.x) > other.min.x &&
			(max.y) > other.min.y ) {
			return true;
		}

		return false;
	}

	public function equals(other:Bounds):Bool {
		return min.equals(other.min) && max.equals(other.max);
	}

	public function clone():Bounds {
		return new Bounds(min.x, min.y, max.x, max.y);
	}

	public function copyFrom(other:Bounds):Bounds {
		min.copyFrom(other.min);
		max.copyFrom(other.max);

		return this;
	}

}