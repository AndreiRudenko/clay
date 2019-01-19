/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;
	
	
class Cubic {
	
	
    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;
    

	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return delta * t * t * t + start;

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return delta * ((t -= 1) * t * t + 1) + start;

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			if ((t *= 2) < 1) {
				return delta * 0.5 * t * t * t + start;
			} else {
				return delta * 0.5 * ((t -= 2) * t * t + 2) + start;
			}

		};
		
	}
	
	
}