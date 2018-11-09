package clay.tween;



@:allow(
	clay.tween.TweenAction, 
	clay.tween.TweenNode
)
class Tween {


	public var action(default, null):TweenAction;

	public var active(default, null):Bool;
	public var inited(default, null):Bool;
	public var complete(default, null):Bool;

	public var start_time(default, null):Float;
	public var duration(default, null):Float;
	public var duration_inv(default, null):Float;

	var target:Dynamic;


	public function new(_action:TweenAction, _duration:Float) {

		action = _action;
		target = _action.node.target;
		active = false;
		complete = false;
		inited = false;

		if(_duration > 0) {
			duration = _duration;
			duration_inv = 1 / duration;
		} else {
			duration = 0;
			duration_inv = 0;
		}

	}

	public function step(t:Float) {

		if(!active) {
			return;
		}

		if (start_time + duration < t) {
			action.sequence.next_time = start_time + duration;
			complete = true;
			active = false;
			_finish();
		} else {
			_update_props(t);
		}

	}

	public function start(t:Float) {

		if(active) {
			return;
		}

		active = true;
		complete = false;
		start_time = t;

		if(!inited) {
			init();
			inited = true;
		}

	}

	public function stop(_complete:Bool = false) {

		if(!active) {
			return;
		}

		active = false;
		inited = false;

		if(_complete) {
			complete = true;
			_finish();
		}
		
	}

	public function reset() {

		active = false;
		complete = false;
		// inited = false;

	}

	public inline function set_prop(_name:String, _value:Float) {

		Reflect.setProperty(target, _name, _value);
		
	}

	public inline function get_prop(_name:String):Float {

		return Reflect.getProperty(target, _name);
		
	}

	inline function _update_props(t:Float) {

		if(!action.node.reverse) {
			apply((t - start_time) * duration_inv);
		} else {
			apply(1 - (t - start_time) * duration_inv);
		}
		
	}

	inline function _finish():Void {

		if(!action.node.reverse) {
			apply(1);
		} else {
			apply(0);
		}

	}

	function init() {}
	function apply(tp:Float) {}


}
