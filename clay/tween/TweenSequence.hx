package clay.tween;


@:allow(
	clay.tween.TweenManager, 
	clay.tween.TweenAction, 
	clay.tween.TweenNode, 
	clay.tween.TweenSequence, 
	clay.tween.Tween
)

class TweenSequence {


	public var manager(default, null):TweenManager;
	public var added(default, null):Bool;
	public var complete:Bool;
	public var time_based:Bool;
	public var started(default, null):Bool;

	var next_time:Float;
	var next:TweenNode;

	public function new(_manager:TweenManager, _time_based:Bool) {

		manager = _manager;
		added = false;
		complete = false;
		time_based = _time_based;
		started = false;
		next_time = 0;

	}

	@:noCompletion public function step(t:Float) {

		if(complete) {
			return;
		}

		if(!started) {
			start();
			started = true;
		}

		if(next == null) {
			_finish();
		} else {
			next.step(t);
			if(next.complete) {
				next_node();
			}
		}

	}

	public function add(s:TweenNode):TweenNode {

		if(next == null) {
			next = s;
		} else {
			var n = next;
			while(true) {
				if(n.next == null) {
					n.next = s;
					break;
				}
				n = n.next;
			}
		}

		return s;
		
	}

	public function reset() {

	}

	inline function start() {

		next._start();

	}

	inline function _finish() {
		
		complete = true;

	}

	public function next_node() {

		var n = next.next;
		if(n == null) {
			_finish();
		} else {
			next = n;
			n._start();
		}
		
	}


}
