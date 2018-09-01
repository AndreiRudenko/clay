package clay.tween;



@:allow(clay.tween.TweenAction)
class Tween {


	public var action(default, null):TweenAction;
	public var complete(default, null):Bool;
	public var inited(default, null):Bool;
	public var duration(default, null):Float;
	public var duration_inv(default, null):Float;
	public var time(default, null):Float;

	var target:Dynamic;
	var need_setup:Bool;


	public function new(_action:TweenAction, _duration:Float) {

		action = _action;
		target = _action.sequence.target;
		complete = false;
		inited = false;
		need_setup = true;
		time = 0;

		if(_duration > 0) {
			duration = _duration;
			duration_inv = 1 / duration;
		} else {
			duration = 0;
			duration_inv = 0;
		}

	}

	public function init() {}
	public function onenter() {}
	public function onleave() {}

	public function onsetup() {}
	public function onupdateprops() {}
	public function onfinish() {}

	public function reset() {}

	public function step(dt:Float) {

		if(complete) {
			return;
		}

		time += dt;

		if (time > duration) {
			action.sequence.time_remains = time - duration;
			time = duration;
			onfinish();
            complete = true;
		} else {
			onupdateprops();
		}

	}

	public inline function set_prop(_name:String, _value:Float) {

		Reflect.setProperty(target, _name, _value);
		
	}

	public inline function get_prop(_name:String):Float {

		return Reflect.getProperty(target, _name);
		
	}

	inline function _enter() {

		time = action.sequence.time_remains;
		onenter();

		if(need_setup) {
			onsetup();
			need_setup = false;
		}

	}

	inline function _init() {

		if(inited) {
			return;
		}
		inited = true;

		init();

	}

	inline function _reset() {

		complete = false;
		inited = false;
		need_setup = true;
		time = 0;
		reset();

	}


}
