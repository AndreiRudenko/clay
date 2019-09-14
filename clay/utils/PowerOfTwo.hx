package clay.utils;

/**
	Power Of Two integers utility
**/


class PowerOfTwo {

	/** Returns the next power of two. */
	public inline static function next(x:Int):Int {

		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;

		return x + 1;

	}

	/** Checks if value is power of two **/
	public inline static function check(x:Int):Bool {

		return x != 0 && (x & (x - 1)) == 0;

	}

	/**
		Returns the specified value if the value is already a power of two.
		Returns next power of two else.
	**/
	public static function require(x:Int):Int {

		if(x == 0) {
			return 1;
		}

		--x;
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;

		return x + 1;

	}

    public inline static function toPowOf2(num:Int):Int{

        return Math.round(Math.log(num)/Math.log(2));

    }

    public inline static function fromPowOf2(num:Int):Int{

        return 1 << num;

    }
    
}