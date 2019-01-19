/**
 * @author Joshua Granick
 * @author Andreas Rønning
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package clay.tween.easing;

import clay.tween.TweenNode;
	
	
class Sine {
	
	
    public static var easeIn (get, never):EaseFunc;
    public static var easeInOut (get, never):EaseFunc;
    public static var easeOut (get, never):EaseFunc;
    

	static function get_easeIn():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return -delta * Math.cos(t * (Math.PI / 2)) + delta + start;

		};
		
	}
	
	static function get_easeOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return delta * Math.sin(t * (Math.PI / 2)) + start;

		};
		
	}

	static function get_easeInOut():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return (-delta * 0.5) * (Math.cos(Math.PI * t) - 1) + start;

		};
		
	}
	
		
}