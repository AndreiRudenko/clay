/**
 * @author Joshua Granick
 * @author Zeh Fernando, Nate Chatellier
 * @author Andreas Rønning
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;
	
	
class Back {
	

	public static var DRIVE:Float = 1.70158;

    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;


	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return delta * t * t * ((DRIVE + 1) * t - DRIVE) + start;

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return delta * ((t -= 1) * t * ((DRIVE + 1) * t + DRIVE) + 1) + start;

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			var s = DRIVE * 1.525;
			if ((t*=2) < 1) {
				return (delta * 0.5) * (t * t * (((s) + 1) * t - s)) + start;
			}
			return (delta * 0.5) * ((t -= 2) * t * (((s) + 1) * t + s) + 2) + start;

		};
		
	}


}