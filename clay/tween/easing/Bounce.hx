
/**
 * @author Andreas Rønning
 * @author Erik Escoffier
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;

	
class Bounce {


    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;


	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return _easeIn(start, delta, t);

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return _easeOut(start, delta, t);

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			if (t < 0.5) {
				return _easeIn(0, delta, t*2) * 0.5 + start;
			} else {
				return _easeOut(0, delta, t*2-1) * 0.5 + delta * 0.5 + start; 
			}

		};
		
	}

	static inline function _easeIn(start:Float, delta:Float, t:Float):Float {
		
		return delta - _easeOut(0, delta, 1 - t) + start;
		
	}
	
	static inline function _easeOut(start:Float, delta:Float, t:Float):Float {
		
		if (t < (1/2.75)) {
			return delta * (7.5625 * t * t) + start;
		} else if (t < (2/2.75)) {
			return delta * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + start;
		} else if (t < (2.5/2.75)) {
			return delta * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + start;
		} else {
			return delta * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + start;
		}
		
	}
	
		
}