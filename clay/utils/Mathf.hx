package clay.utils;



class Mathf {


	public static inline function fixed(value:Float, precision:Int):Float {

		var n = Math.pow( 10, precision );
		return ( Std.int(value * n) / n );

	}

	public static inline function lerp(start:Float, end:Float, t:Float):Float {

		t = clamp(t, 0, 1);

		return (start + t * (end - start));

	}

	public static inline function inverseLerp(start:Float, end:Float, value:Float):Float {

		return clamp((value - start) / (end - start), 0, 1);

	}

	public static inline function clamp(value:Float, a:Float, b:Float):Float {

		return ( value < a ) ? a : ( ( value > b ) ? b : value );

	}

	public static inline function clampi(value:Int, a:Int, b:Int):Int {

		return ( value < a ) ? a : ( ( value > b ) ? b : value );

	}

	public static inline function clampBottom(value:Float, a:Float):Float {

		return value < a ? a : value;

	}

	public static inline function clampBottomi(value:Int, a:Int):Int {

		return value < a ? a : value;

	}

	public static inline function clampTop(value:Float, a:Float):Float {

		return value > a ? a : value;

	}

	public static inline function clampTopi(value:Int, a:Int):Int {

		return value > a ? a : value;

	}

	public static inline function withinRange(value:Float, startRange:Float, endRange:Float):Bool {

		return value >= startRange && value <= endRange;

	}

    public static inline function smoothstep(x:Float, min:Float, max:Float):Float {

        if (x <= min) {
            return 0;
        }

        if (x >= max) {
            return 1;
        }

        x = ( x - min ) / ( max - min );

        return x * x * ( 3 - 2 * x );

    }

		/** Return the sign of a number, `1` if >= 0 and `-1` if < 0 */
	public static inline function sign(x:Float):Int {

		return (x >= 0) ? 1 : -1;

	}

		/** Return the sign of a number, `0` is returned as `0`, `1` if > `0` and `-1` if < `0` */
	public static inline function sign0(x:Float):Int {

		return (x < 0) ? -1 : ((x > 0) ? 1 : 0);

	}

		/** Convert a number from degrees to radians */
	public static inline function radians(degrees:Float):Float {

		return degrees * DEG2RAD;

	}

		/** Convert a number from radians to degrees */
	public static inline function degrees(radians:Float):Float {

		return radians * RAD2DEG;

	}

		/** Returns the next power of two. */
	public inline static function nextPow2(x:Int):Int {

		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;

		return x + 1;

	}

		/** Returns the previous power of two. */
	public inline static function prevPow2(x:Int):Int {

		x |= x >>> 1;
		x |= x >>> 2;
		x |= x >>> 4;
		x |= x >>> 8;
		x |= x >>> 16;

		return x - (x>>>1);

	}

	/**
		Returns the specified value if the value is already a power of two.
		Returns next power of two else.
	**/
	public static function requirePow2(x:Int):Int {

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

		/** Computes log base 2 of v */
	public static inline function log2(v:Int):Int {

		var r; 
		var shift;

		r =     v > 0xFFFF? 1 << 4 : 0; v >>>= r;
		shift = v > 0xFF  ? 1 << 3 : 0; v >>>= shift; r |= shift;
		shift = v > 0xF   ? 1 << 2 : 0; v >>>= shift; r |= shift;
		shift = v > 0x3   ? 1 << 1 : 0; v >>>= shift; r |= shift;

		return r | (v >> 1);

	}

	/** Checks if value is power of two **/
	public static inline function checkPow2(x:Int):Bool {

		return x != 0 && (x & (x - 1)) == 0;

	}

	public static inline function mod(i:Int, n:Int):Int {
		
		return (i % n + n) % n;

	}

		/** Used by `degrees()` and `radians()`, use those to convert, unless needed */
	public static inline var DEG2RAD:Float = 3.14159265358979 / 180;
		/** Used by `degrees()` and `radians()`, use those to convert, unless needed */
	public static inline var RAD2DEG:Float = 180 / 3.14159265358979;

	public static inline var EPSILON:Float = 1e-8;


}