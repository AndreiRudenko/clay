package clay.tween;



@:allow(clay.tween.TweenAction)
class Tween {


	public var action(default, null):TweenAction;
	public var complete(default, null):Bool;
	public var inited(default, null):Bool;

	public var start_time(default, null):Float;
	public var duration(default, null):Float;
	public var duration_inv(default, null):Float;

	var target:Dynamic;
	var need_setup:Bool;


	public function new(_action:TweenAction, _duration:Float) {

		action = _action;
		target = _action.node.target;
		complete = false;
		inited = false;
		need_setup = true;

		if(_duration > 0) {
			duration = _duration;
			duration_inv = 1 / duration;
		} else {
			duration = 0;
			duration_inv = 0;
		}

	}

	function onstart(t:Float) {}
	function onfinish() {}

	function onsetup() {}
	function onupdateprops(t:Float) {}

	public function reset() {}

	public function step(t:Float) {

		if(complete) {
			return;
		}

		if (start_time + duration < t) {
			action.sequence.next_time = start_time + duration;
            complete = true;
			onfinish();
		} else {
			onupdateprops(t);
		}

	}

	public inline function set_prop(_name:String, _value:Float) {

		Reflect.setProperty(target, _name, _value);
		
	}

	public inline function get_prop(_name:String):Float {

		return Reflect.getProperty(target, _name);
		
	}

	inline function _start(t:Float) {

		start_time = t;

		onstart(t);

		if(need_setup) {
			onsetup();
			need_setup = false;
		}

	}

	inline function _reset() {

		complete = false;
		inited = false;
		need_setup = true;
		reset();

	}


}
