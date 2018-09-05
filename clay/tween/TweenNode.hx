package clay.tween;


typedef EaseFunc = Float->Float->Float->Float;


@:allow(
	clay.tween.TweenAction, 
	clay.tween.TweenSequence
)
class TweenNode {


	public var target 	  	(default, null):Dynamic;

	public var sequence	  	(default, null):TweenSequence;
	public var current 	  	(default, null):TweenAction;

	public var easing     	(default, null):EaseFunc;

	public var active   	(default, null):Bool;
	public var complete   	(default, null):Bool;

	public var paused     	(default, null):Bool;
	public var reflect   	(default, null):Bool;
	public var reverse   	(default, null):Bool;
	public var repeat   	(default, null):Int;

	var _onupdate:Void->Void;
	var _onrepeat:Void->Void;
	var _oncomplete:Void->Void;

	var head:TweenAction;
	var tail:TweenAction;

	var next:TweenNode;


	public function new(_sequence:TweenSequence, _target:Dynamic) {

		sequence = _sequence;
		target = _target;
		active = false;
		complete = false;
		paused = false;
		reflect = false;
		reverse = false;
		repeat = 0;
		easing = clay.tween.easing.Linear.none;

	}

	@:noCompletion public function step(t:Float) {

		if(!active || paused) {
			return;
		}

		if(current == null) {
			_finish();
		} else {
			if(_onupdate != null) {
				_onupdate();
			}
			current.step(t);
			if(current.complete) {
				next_action();
			}
		}

	}

	@:noCompletion public function next_action() {

		var n:TweenAction = null;
		if(!reverse) {
			n = current.next;
		} else {
			n = current.prev;
		}

		if(n == null) {
			if(repeat != 0) {
				_repeat();
			} else {
				_finish();
			}
		} else {
			set_current(n);
		}

	}

	inline function set_current(_action:TweenAction) {

		// if(current != null) {
		// 	current.finish(); // onleave ?
		// }

		current = _action;

		if(current != null) {
			current.start(sequence.next_time);
		}
		
	}

	public function start() {

		if(active) {
			return;
		}

		active = true;
		complete = false;

		set_current(head);

	}

	public function stop(_complete:Bool) {

		if(!active) {
			return;
		}

		active = false;

		if(_complete) {
			complete = true;
			if(current != null) {
				current.stop(_complete);
			}
		}
		
	}

	public inline function create_action():TweenAction {
		
		return add(new TweenAction(this));

	}

	public function add(a:TweenAction):TweenAction {

		if (tail != null) {
			tail.next = a;
			a.prev = tail;
		} else{
			head = a;
		}

		tail = a;

		return a;

	}

	public function remove(a:TweenAction) {

		if (a == head){
			head = head.next;
			
			if (head == null) {
				tail = null;
			}
		} else if (a == tail) {
			tail = tail.prev;
				
			if (tail == null) {
				head = null;
			}
		}

		if(a == current) { // todo: check
			next_action();
		}

		if (a.prev != null) {
			a.prev.next = a.next;
		}

		if (a.next != null) {
			a.next.prev = a.prev;
		}

		a.next = a.prev = null;

	}

	inline function _finish() {

		complete = true;
		active = false;

		if(_oncomplete != null) {
			_oncomplete();
		}	
		
	}

	function _repeat() {

		if(reflect) {
			reverse = !reverse;
		}

		if(_onrepeat != null) {
			_onrepeat();
		}

		if(repeat > 0) {
			repeat--;
		}

		if(!reverse) {
			set_current(head);
		} else {
			set_current(tail);
		}

	}

}
