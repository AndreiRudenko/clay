package clay.tween;


typedef EaseFunc = Float->Float->Float->Float;


@:allow(
	clay.tween.TweenManager, 
	clay.tween.TweenAction, 
	clay.tween.TweenNode, 
	clay.tween.TweenSequence, 
	clay.tween.Tween
)
class TweenNode {


	public var paused     	(default, null):Bool;

	public var sequence	  	(default, null):TweenSequence;
	public var target 	  	(default, null):Dynamic;

	public var current 	  	(default, null):TweenAction;
	public var easing     	(default, null):EaseFunc;
	public var added      	(default, null):Bool;
	public var complete   	(default, null):Bool;


	var _repeat:Int;
	var _reflect:Bool;
	var reverse:Bool;

	var _onupdate:Void->Void;
	var _onrepeat:Void->Void;
	var _oncomplete:Void->Void;

	var head:TweenAction;
	var tail:TweenAction;

	var next:TweenNode;


	public function new(_sequence:TweenSequence, _target:Dynamic) {

		sequence = _sequence;
		target = _target;
		_reflect = false;
		added = false;
		complete = false;
		paused = false;
		reverse = false;
		_repeat = 0;
		easing = clay.tween.easing.Linear.none;

	}

	@:noCompletion public function step(t:Float) {

		if(complete || paused) {
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

	@:noCompletion public function set_current(_action:TweenAction) {

		if(current != null) {
			current._finish();
		}

		current = _action;

		if(current != null) {
			current._start(sequence.next_time);
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
			if(_repeat != 0) {
				_do_repeat();
			} else {
				_finish();
			}
		} else {
			set_current(n);
		}

	}

	inline function _start() {
		
		set_current(head);

	}

	function _finish() {

		complete = true;
		if(_oncomplete != null) {
			_oncomplete();
		}	
		
	}

	function _do_repeat() {

		if(_onrepeat != null) {
			_onrepeat();
		}

		if(_reflect) {
			reverse = !reverse;
		}

		if(_repeat > 0) {
			_repeat--;
		}

		if(!reverse) {
			set_current(head);
		} else {
			set_current(tail);
		}

	}

	function create_action():TweenAction {
		
		return add(new TweenAction(this));

	}

	@:access(clay.tween.TweenManager)
	inline function add(a:TweenAction):TweenAction {

		if (tail != null) {
			tail.next = a;
			a.prev = tail;
		} else{
			head = a;
		}

		tail = a;

		return a;

	}

	inline function remove(a:TweenAction) {

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


}
