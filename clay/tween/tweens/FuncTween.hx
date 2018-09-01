package clay.tween.tweens;


class FuncTween extends Tween {


	var from:Array<Float>;
	var to:Array<Float>;
	var current:Array<Float>;
	var difference:Array<Float>;
	var fn:Dynamic;


	public function new(_action:TweenAction, _fn:Dynamic, _duration:Float, _from:Array<Float> = null, _to:Array<Float> = null) {

		super(_action, _duration);

		fn = _fn;
		difference = [];
		current = [];

		if(_from != null && _to != null) {
			from = _from.copy();
			to = _to.copy();
			for (i in 0...from.length) {
				difference[i] = to[i] - from[i];
			}
		} else {	
			from = [];
			to = [];
		}

	}

	override function onenter() {

		complete = false;

	}

	override function onupdateprops() {

		var t:Float = 0;
		var n:Float = 0;

		if(!action.sequence.reverse) {
			t = time * duration_inv;
		} else {
			t = 1 - time * duration_inv;
		}

		for (i in 0...from.length) {
			n = action.sequence.easing(from[i], difference[i], t);
			current[i] = n;
		}

		Reflect.callMethod(null, fn, current);

	}

	override function onfinish() {

		if(!action.sequence.reverse) {
			Reflect.callMethod(null, fn, to);
		} else {
			Reflect.callMethod(null, fn, from);
		}
		
	}


}
