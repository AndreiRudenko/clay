package clay.utils;

class PowerOfTwo {

	static public inline function next(x:Int):Int {
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;

		return x + 1;
	}

	static public inline function prev(x:Int):Int {
		x |= x >>> 1;
		x |= x >>> 2;
		x |= x >>> 4;
		x |= x >>> 8;
		x |= x >>> 16;

		return x - (x>>>1);
	}

	static public inline function check(x:Int):Bool {
		return x != 0 && (x & (x - 1)) == 0;
	}

	static public inline function get(x:Int):Int {
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

    static public inline function toPowOf2(num:Int):Int {
        return Math.round(Math.log(num)/Math.log(2));
    }

    static public inline function fromPowOf2(num:Int):Int {
        return 1 << num;
    }
    
}