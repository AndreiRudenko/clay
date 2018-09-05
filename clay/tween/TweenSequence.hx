package clay.tween;


@:allow(clay.tween.TweenManager)
class TweenSequence {


	public var manager   	(default, null):TweenManager;

	public var added     	(default, null):Bool;
	public var started   	(default, null):Bool;
	public var active  	    (default, null):Bool;
	public var paused  	    (default, null):Bool;
	public var complete  	(default, null):Bool;
	public var time_based	(default, null):Bool;

	@:noCompletion
	public var next_time:Float;
	var pause_time:Float;

	var head:TweenNode;
	var next:TweenNode;


	public function new(_manager:TweenManager, _time_based:Bool) {

		manager = _manager;
		active = false;
		paused = false;
		added = false;
		complete = false;
		started = false;
		time_based = _time_based;
		next_time = 0;
		pause_time = 0;

	}

	@:noCompletion public function step(t:Float) {

		if(paused || complete) {
			return;
		}

		if(!started) {
			start();
		}

		if(!active) {
			return;
		}

		if(next == null) {
			finish();
		} else {
			next.step(t);
			if(next.complete) {
				next_node();
			}
		}

	}

	public function add(n:TweenNode):TweenNode {

		var nodes:Array<TweenNode> = manager.targets.get(n.target);
		if(nodes == null) {
			nodes = [];
			manager.targets.set(n.target, nodes);
		}
		nodes.push(n);

		if(next == null) {
			next = n;
			head = n;
		} else {
			var n = next;
			while(true) {
				if(n.next == null) {
					n.next = n;
					break;
				}
				n = n.next;
			}
		}

		return n;
		
	}

	public function start() {

		if(active) {
			return;
		}

		if(!added) {
			manager.add_sequence(this);
		}

		started = true;

		active = true;
		complete = false;

		next = head;
		next.start();

	}

	public function stop(_complete:Bool = false) {

		if(!active) {
			return;
		}

		active = false;

		if(next != null) {
			complete = true;
			next.stop(_complete);
		}

	}

	public function pause() { // todo

		paused = true;

	}

	public function unpause() { // todo

		paused = false;

	}

	inline function finish() {
		
		complete = true;
		active = false;

	}

	public function next_node() {

		var n = next.next;
		if(n == null) {
			finish();
		} else {
			next = n;
			n.start();
		}
		
	}


}
