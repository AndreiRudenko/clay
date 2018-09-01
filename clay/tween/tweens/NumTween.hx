package clay.tween.tweens;


class NumTween extends Tween {


	var names:Array<String>;
	var from:Array<Float>;
	var from_current:Array<Float>;
	// var to:Array<Float>;
	var difference:Array<Float>;
	var props:Dynamic;


	public function new(_action:TweenAction, _props:Dynamic, _duration:Float) {

		super(_action, _duration);

		props = _props;

	}

	override function onenter() {

		complete = false;

	}

	override function onsetup() {
		
		names = [];
		from = [];
		// from_current = [];
		// to = [];
		difference = [];

		for (p in Reflect.fields(props)) {
			if(!Reflect.hasField(target, p)) {
				trace('cant find field: $p');
				continue;
			}

			var _from:Float = get_prop(p);
			var _to:Float = Reflect.getProperty(props, p);

			names.push(p);
			from.push(_from);
			// to.push(_to);
			difference.push(_to - _from);
		}
		
	}

	override function onupdateprops() {

		var t:Float = 0;
		var n:Float = 0;

		if(!action.sequence.reverse) {
			t = time * duration_inv;
		} else {
			t = 1 - time * duration_inv;
		}

		for (i in 0...names.length) {
			n = action.sequence.easing(from[i], difference[i], t);
			set_prop(names[i], n);
		}

	}

	override function onfinish() {

		if(!action.sequence.reverse) {
			for (i in 0...names.length) {
				set_prop(names[i], from[i] + difference[i]);
			}
		} else {
			for (i in 0...names.length) {
				set_prop(names[i], from[i]);
			}
		}
		
	}


}
