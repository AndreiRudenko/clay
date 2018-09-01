
/**
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */

package clay.tween.easing;


class Circ {

	
	public static inline function easeIn(start:Float, delta:Float, t:Float):Float {

        return -delta * (Math.sqrt(1 - t * t) - 1) + start;

	}
	
	public static inline function easeOut(start:Float, delta:Float, t:Float):Float {

        return delta * Math.sqrt(1 - (t - 1) * t) + start;

	}

	public static inline function easeInOut(start:Float, delta:Float, t:Float):Float {

        return ((t / 2) < 1) ? -delta / 2 * (Math.sqrt(1 - t * t) - 1) + start : delta / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + start;

	}	


}

