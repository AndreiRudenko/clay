/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Philippe / http://philippe.elsass.me
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;


class Elastic {
	

    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;

	static var a = 0.1;
	static var p = 0.4;
	

	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			if (t == 0) {
				return start;
			}
			if (t == 1) {
				return start + delta;
			}
			var s:Float;
			if (a < Math.abs(delta)) {
				a = delta;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(delta / a);
			}
			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p)) + start;

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			if (t == 0) {
				return start;
			}
			if (t == 1) {
				return start + delta;
			}
			var s:Float;
			if (a < Math.abs(delta)) {
				a = delta;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(delta / a);
			}
			return a * Math.pow(2, -10 * t) * Math.sin((t - s) * (2 * Math.PI) / p) + delta + start;

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {
			
			if (t == 0) {
				return start;
			}
			t *= 2;
			if (t == 2) {
				return start + delta;
			}
			var s:Float;
			if (a < Math.abs(delta)) {
				a = delta;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(delta / a);
			}
			if (t < 1) {
				return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p)) + start;
			}
			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t - s) * (2 * Math.PI) / p) * 0.5 + delta + start;

		};
		
	}

		
}