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

	override function onstart(t:Float) {

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

	override function onupdateprops(_time:Float) {

		var t:Float = 0;
		var n:Float = 0;

		if(!action.node.reverse) {
			t = (_time - start_time) * duration_inv;
		} else {
			t = 1 - (_time - start_time) * duration_inv;
		}

		for (i in 0...names.length) {
			n = action.node.easing(from[i], difference[i], t);
			set_prop(names[i], n);
		}

	}

	override function onfinish() {

		if(!action.node.reverse) {
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
