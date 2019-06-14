package clay.tween.easing;

	
class Bounce {


	public static inline function easeIn(t:Float):Float {

		t = 1 - t;
		if (t < B1) return 1 - 7.5625 * t * t;
		if (t < B2) return 1 - (7.5625 * (t - B3) * (t - B3) + 0.75);
		if (t < B4) return 1 - (7.5625 * (t - B5) * (t - B5) + 0.9375);
		return 1 - (7.5625 * (t - B6) * (t - B6) + 0.984375);

	}
	
	public static inline function easeOut(t:Float):Float {

		if (t < B1) return 7.5625 * t * t;
		if (t < B2) return 7.5625 * (t - B3) * (t - B3) + 0.75;
		if (t < B4) return 7.5625 * (t - B5) * (t - B5) + 0.9375;
		return 7.5625 * (t - B6) * (t - B6) + 0.984375;

	}

	public static inline function easeInOut(t:Float):Float {

		if (t < 0.5) {
			t = 1 - t * 2;
			if (t < B1) return (1 - 7.5625 * t * t) / 2;
			if (t < B2) return (1 - (7.5625 * (t - B3) * (t - B3) + 0.75)) / 2;
			if (t < B4) return (1 - (7.5625 * (t - B5) * (t - B5) + 0.9375)) / 2;
			return (1 - (7.5625 * (t - B6) * (t - B6) + 0.984375)) / 2;
		}
		t = t * 2 - 1;
		if (t < B1) return (7.5625 * t * t) / 2 + 0.5;
		if (t < B2) return (7.5625 * (t - B3) * (t - B3) + 0.75) / 2 + 0.5;
		if (t < B4) return (7.5625 * (t - B5) * (t - B5) + 0.9375) / 2 + 0.5;
		return (7.5625 * (t - B6) * (t - B6) + 0.984375) / 2 + 0.5;

	}	
	
		
}