package clay.utils;


class Bits {


	public static inline function set(v:Int, n:Int):Int {

		return v | (1 << n);

	}

	public static inline function clear(v:Int, n:Int):Int {

		return v & ~(1 << n);

	}

	public static inline function toggle(v:Int, n:Int):Int {

		return v ^ (1 << n);

	}

	public static inline function check(v:Int, n:Int):Bool {

		return (v >> n) & 1 == 1;

	}

	public static inline function set_to_pos(v:Int, num:Int, pos:Int):Int { 

		return v | (num << pos);

	}

	public static inline function set_range(v:Int, left:Int, right:Int):Int { 

		return v | (((1 << (left - 1)) - 1) ^ ((1 << right) - 1));

	}

	public static inline function clear_range(v:Int, left:Int, right:Int):Int { 

		return v & ~(((1 << (left - 1)) - 1) ^ ((1 << right) - 1));

	}

	public static inline function toggle_range(v:Int, left:Int, right:Int):Int { 

		return v ^ (((1 << (left - 1)) - 1) ^ ((1 << right) - 1));

	}

	public static inline function extract_range(v:Int, pos:Int, len:Int):Int { 

		return ((1 << len) - 1) & (v >> (pos - 1));

	}

	public static function for_each(v:Int, cb:(b:Int)->Void) {

		var i:Int = 0;
		while (v != 0) {
			if (v & 0x1 == 1) {
				cb(i);
			}
			v >>= 1;
			i++;
		}
	    
	}

	public static function count_singed(n:Int):Int { 

		return Std.int(Math.pow(2, n)-1);

	}

	public static function count_unsinged(n:Int, neg:Bool) {  

		if(neg) {
			return Std.int(Math.pow(-2, n-1));
		} else {
			return Std.int(Math.pow(2, n-1)-1);
		}

	}


}
