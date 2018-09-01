package clay.tween;


import clay.tween.actions.EmptyAction;

typedef EaseFunc = Float->Float->Float->Float;


@:allow(clay.tween.TweenManager, clay.tween.TweenAction, clay.tween.Tween)
class TweenSequence {


	public var complete (default, null):Bool;
	public var paused (default, null):Bool;

	public var manager	(default, null):TweenManager;
	public var target 	(default, null):Dynamic;

	public var current 	(default, null):TweenAction;
	public var easing   (default, null):EaseFunc;
	public var added   (default, null):Bool;

	public var time_based(default, null):Bool;

	var time_remains:Float; // remaining time after action finished
	var repeat:Int;
	var reflect:Bool;
	var reverse:Bool;

	var inited:Bool;
	var _onupdate:Void->Void;
	var _onrepeat:Void->Void;
	var _oncomplete:Void->Void;
	var head:TweenAction;
	var tail:TweenAction;


	public function new(_manager:TweenManager, _target:Dynamic) {

		manager = _manager;
		target = _target;
		inited = false;
		added = false;
		repeat = 0;
		time_remains = 0;
		paused = false;
		reflect = false;
		reverse = false;
		complete = false;
		easing = clay.tween.easing.Linear.none;
		time_based = false;

	}

	public function play() {

		if(complete) {
			if(!added) {
				manager.add_sequence(this);
			}
			complete = false;
			var a = head;
			while(a != null) {
				a._reset();
				a = a.next;
			}
			set_current(head);
			paused = false;
		}


	}

	public function unpause() {

		paused = true;

	}

	public function pause() {

		paused = true;

	}

	public function stop() {

		complete = true;

	}

	@:noCompletion public function step(dt:Float) {

		if(complete || paused) {
			return;
		}

		if(!inited) {
			init();
		}

		if(current == null) {
			_finish();

		} else {
			current.step(dt);
			if(_onupdate != null) {
				_onupdate();
			}
			if(current.complete) {
				set_next_action();
				time_remains = 0;
			}
		}

	}

	function _finish() {

		complete = true;
		if(_oncomplete != null) {
			_oncomplete();
		}	
		
	}

	@:noCompletion public function set_current(_action:TweenAction) {

		if(current != null) {
			current._leave();
		}

		current = _action;

		if(current != null) {
			current._enter();
		}
		
	}

	@:noCompletion public function set_next_action() {

		var n:TweenAction = null;
		if(!reverse) {
			n = current.next;
		} else {
			n = current.prev;
		}

		if(n == null && repeat != 0) {
			do_repeat();
		} else {
			set_current(n);
		}

	}

	function do_repeat() {

		if(_onrepeat != null) {
			_onrepeat();
		}

		if(reflect) {
			reverse = !reverse;
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

	function create_action():TweenAction {
		
		return add(new EmptyAction(this));

	}

	inline function init() {

		current = head;
		current._enter();

		inited = true;

		var a = head;
		while(a != null) {
			a._init();
			a = a.next;
		}

	}

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

		if(a == current) {
			set_next_action();
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

@:enum abstract TweenUpdateMode(Int) from Int to Int {

	var none                = 0;
	var frame               = 1; // update(dt);
	var time                = 2; // tick(time - last_time);

}
