package clay.math;



class Mathf {


	public static inline function fixed( value:Float, precision:Int ):Float {

		var n = Math.pow( 10, precision );
		return ( Std.int(value * n) / n );

	}

	public static inline function lerp(value:Float, target:Float, t:Float):Float {

		t = clamp(t, 0, 1);

		return (value + t * (target - value));

	}

	public static inline function clamp(value:Float, a:Float, b:Float):Float {

		return ( value < a ) ? a : ( ( value > b ) ? b : value );

	}

	public static inline function clampi(value:Int, a:Int, b:Int):Int {

		return ( value < a ) ? a : ( ( value > b ) ? b : value );

	}

	public static inline function clamp_bottom(value:Float, a:Float):Float {

		return value < a ? a : value;

	}

	public static inline function clamp_bottomi(value:Int, a:Int):Int {

		return value < a ? a : value;

	}

	public static inline function within_range(value:Float, start_range:Float, end_range:Float):Bool {

		return value >= start_range && value <= end_range;

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


		/** Used by `degrees()` and `radians()`, use those to convert, unless needed */
	public static inline var DEG2RAD:Float = 3.14159265358979 / 180;
		/** Used by `degrees()` and `radians()`, use those to convert, unless needed */
	public static inline var RAD2DEG:Float = 180 / 3.14159265358979;

	public static inline var EPSILON:Float = 1e-8;


}