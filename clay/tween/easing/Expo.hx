/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;


class Expo {

	
    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;
    

	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return t == 0 ? start : delta * Math.pow(2, 10 * (t - 1)) + start;

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return t == 1 ? start + delta : delta * (1 - Math.pow(2, -10 * t)) + start;

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {
			
			if (t == 0) {
				return start;
			}
			if (t == 1) {
				return start + delta;
			}
			if ((t *= 2.0) < 1.0) {
				return delta / 2 * Math.pow(2, 10 * (t - 1)) + start;
			}
			return delta / 2 * (2 - Math.pow(2, -10 * --t)) + start;

		};
		
	}


}
