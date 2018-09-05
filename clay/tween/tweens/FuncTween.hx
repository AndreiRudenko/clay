package clay.tween.tweens;


class FuncTween extends Tween {


	var from:Array<Float>;
	// var to:Array<Float>;
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
			// to = _to.copy();
			for (i in 0...from.length) {
				difference[i] = _to[i] - from[i];
			}
		} else {	
			from = [];
			// to = [];
		}

	}

	override function apply(tp:Float) {

		var n:Float = 0;
		for (i in 0...from.length) {
			n = action.node.easing(from[i], difference[i], tp);
			current[i] = n;
		}

		Reflect.callMethod(null, fn, current);

	}


}
