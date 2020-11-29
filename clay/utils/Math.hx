package clay.utils;

class Math {

	static public inline var TAU = 6.28318530717958648;
	static public inline var PI = 3.14159265358979323;
	static public inline var DEG2RAD:Float = 6.28318530717958648 / 360;
	static public inline var RAD2DEG:Float = 360 / 6.28318530717958648;
	static public inline var EPSILON:Float = 1e-10;

	static public var POSITIVE_INFINITY(get, never):Float;
	static public var NEGATIVE_INFINITY(get, never):Float;
	static public var NaN(get, never):Float;

	static inline function get_POSITIVE_INFINITY() {
		return std.Math.POSITIVE_INFINITY;
	}

	static inline function get_NEGATIVE_INFINITY() {
		return std.Math.NEGATIVE_INFINITY;
	}

	static inline function get_NaN() {
		return std.Math.NaN;
	}

	static public inline function isNaN(v:Float) {
		return std.Math.isNaN(v);
	}

	static public inline function floor(f:Float) {
		return std.Math.floor(f);
	}

	static public inline function log(f:Float) {
		return std.Math.log(f);
	}

	static public inline function random() {
		return std.Math.random();
	}

	static public inline function ceil(f:Float) {
		return std.Math.ceil(f);
	}

	static public inline function round(f:Float) {
		return std.Math.round(f);
	}

	static public inline function pow(v:Float, p:Float) {
		return std.Math.pow(v,p);
	}

	static public inline function exp(f:Float) {
		return std.Math.exp(f);
	}

	static public inline function cos(f:Float) {
		return std.Math.cos(f);
	}

	static public inline function sin(f:Float) {
		return std.Math.sin(f);
	}

	static public inline function tan(f:Float) {
		return std.Math.tan(f);
	}

	static public inline function acos(f:Float) {
		return std.Math.acos(f);
	}

	static public inline function asin(f:Float) {
		return std.Math.asin(f);
	}

	static public inline function atan(f:Float) {
		return std.Math.atan(f);
	}

	static public inline function sqrt(f:Float) {
		return std.Math.sqrt(f);
	}

	static public inline function invSqrt(f:Float) {
		return 1. / sqrt(f);
	}

	static public inline function atan2(dy:Float, dx:Float) {
		return std.Math.atan2(dy,dx);
	}

	static public inline function abs(f:Float) {
		return f < 0 ? -f : f;
	}

	static public inline function iabs( i : Int ) {
		return i < 0 ? -i : i;
	}

	static public inline function max(a:Float, b:Float ) {
		return a < b ? b : a;
	}

	static public inline function imax( a : Int, b : Int ) {
		return a < b ? b : a;
	}

	static public inline function min(a:Float, b:Float ) {
		return a > b ? b : a;
	}

	static public inline function imin( a : Int, b : Int ) {
		return a > b ? b : a;
	}

	static public inline function fixed(value:Float, precision:Int):Float {
		var n = Math.pow( 10, precision );
		return ( Std.int(value * n) / n );
	}

	static public inline function lerp(start:Float, end:Float, t:Float):Float {
		t = clamp(t, 0, 1);
		return (start + t * (end - start));
	}

	static public inline function inverseLerp(start:Float, end:Float, value:Float):Float {
		return clamp((value - start) / (end - start), 0, 1);
	}

	static public inline function map(istart:Float, iend:Float, ostart:Float, oend:Float, value:Float):Float {
		return ostart + (oend - ostart) * ((value - istart) / (iend - istart));
	}

	static public inline function imap(istart:Float, iend:Float, ostart:Float, oend:Float, value:Float):Float {
		return Std.int(map(istart, iend, ostart, oend, value));
	}

	static public inline function clamp(value:Float, a:Float, b:Float):Float {
		return ( value < a ) ? a : ( ( value > b ) ? b : value );
	}

	static public inline function iclamp(value:Int, a:Int, b:Int):Int {
		return ( value < a ) ? a : ( ( value > b ) ? b : value );
	}

	static public inline function withinRange(value:Float, startRange:Float, endRange:Float):Bool {
		return value >= startRange && value <= endRange;
	}

	static public inline function smoothStep(x:Float, min:Float, max:Float):Float {
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
	static public inline function sign(x:Float):Int {
		return (x >= 0) ? 1 : -1;
	}

		/** Return the sign of a number, `0` is returned as `0`, `1` if > `0` and `-1` if < `0` */
	static public inline function sign0(x:Float):Int {
		return (x < 0) ? -1 : ((x > 0) ? 1 : 0);
	}

	static public inline function fract(v:Float):Float {
		return v - Std.int(v);
	}
	
		/** Convert a number from degrees to radians */
	static public inline function radians(degrees:Float):Float {
		return degrees * DEG2RAD;
	}

		/** Convert a number from radians to degrees */
	static public inline function degrees(radians:Float):Float {
		return radians * RAD2DEG;
	}

		/** Computes log base 2 of v */
	static public inline function log2(v:Int):Int {
		var r; 
		var shift;

		r =     v > 0xFFFF? 1 << 4 : 0; v >>>= r;
		shift = v > 0xFF  ? 1 << 3 : 0; v >>>= shift; r |= shift;
		shift = v > 0xF   ? 1 << 2 : 0; v >>>= shift; r |= shift;
		shift = v > 0x3   ? 1 << 1 : 0; v >>>= shift; r |= shift;

		return r | (v >> 1);
	}

	static public inline function mod(i:Int, n:Int):Int {
		return (i % n + n) % n;
	}

	static public inline function distanceSq(dx:Float, dy:Float) {
		return dx * dx + dy * dy;
	}

	static public inline function distance(dx:Float, dy:Float) {
		return sqrt(distanceSq(dx,dy));
	}

}