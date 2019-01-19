/**
 * @author Andreas Rønning
 */

package clay.tween.easing;

import clay.tween.TweenNode;


class Linear {


    public static var none (get, never):EaseFunc;


	static function get_none():EaseFunc {
		
		return function(start:Float, delta:Float, t:Float) {

			return start + delta * t;

		};
		
	}


}