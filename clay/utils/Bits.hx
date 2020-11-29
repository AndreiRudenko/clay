package clay.utils;

class Bits {

	static public inline function set(v:Int, n:Int):Int {
		return v | (1 << n);
	}

	static public inline function clear(v:Int, n:Int):Int {
		return v & ~(1 << n);
	}

	static public inline function toggle(v:Int, n:Int):Int {
		return v ^ (1 << n);
	}

	static public inline function check(v:Int, n:Int):Bool {
		return (v >> n) & 1 == 1;
	}

	static public inline function setToPos(v:Int, num:Int, pos:Int):Int { 
		return v | (num << pos);
	}

	static public inline function setRange(v:Int, left:Int, right:Int):Int { 
		return v | (((1 << (left - 1)) - 1) ^ ((1 << right) - 1));
	}

	static public inline function clearRange(v:Int, left:Int, right:Int):Int { 
		return v & ~(((1 << (left - 1)) - 1) ^ ((1 << right) - 1));
	}

	static public inline function toggleRange(v:Int, left:Int, right:Int):Int { 
		return v ^ (((1 << (left - 1)) - 1) ^ ((1 << right) - 1));
	}

	static public inline function extractRange(v:Int, pos:Int, len:Int):Int { 
		return ((1 << len) - 1) & (v >> (pos - 1));
	}

	static public function forEach(v:Int, cb:(b:Int)->Void) {
		var i:Int = 0;
		while (v != 0) {
			if (v & 0x1 == 1) {
				cb(i);
			}
			v >>= 1;
			i++;
		}
	}

	static public function countSinged(n:Int):Int { 
		return Std.int(Math.pow(2, n)-1);
	}

	static public function countUnsinged(n:Int, neg:Bool) {  
		if(neg) {
			return Std.int(Math.pow(-2, n-1));
		} else {
			return Std.int(Math.pow(2, n-1)-1);
		}
	}

}
