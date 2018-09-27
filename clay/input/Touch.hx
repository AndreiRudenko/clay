package clay.input;


import clay.Engine;
import clay.ds.Uint4Vector;
import clay.utils.Log.*;
import clay.utils.Bits;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Touch extends Input {


	public var count(default, null):Int = 0;

	var touches:Array<TouchEvent>;


	override function enable() {

		if(active) {
			return;
		}

		_debug('enable');

		touches = [];

		for (i in 0...10) {
			touches.push(new TouchEvent(i));
		}

		#if use_touch_input

		var t = kha.input.Surface.get();
		if(t != null) {
			t.notify(onpressed, onreleased, onmove);
		}

		#end

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		_debug('disable');

		#if use_touch_input

		var t = kha.input.Surface.get();
		if(t != null) {
			t.remove(onpressed, onreleased, onmove);
		}
		
		#end

		touches = null;

		super.disable();

	}

	function reset() {

		for (t in touches) {
			t.reset();
		}
		count = 0;

	}

	function onpressed(_id:Int, _x:Int, _y:Int) {

		_debug('onpressed id:$_id, x:$_x, y$_y');

		count++;

		var t = touches[_id];

		t.pressed = true;
		t.released = false;
		t.down = true;
		t.set(_x, _y, 0, 0, TouchEventState.down);

		engine.ontouchdown(t);

	}

	function onreleased(_id:Int, _x:Int, _y:Int) {

		_debug('onpressed id:$_id, x:$_x, y$_y');

		count--;

		var t = touches[_id];
		t.pressed = false;
		t.released = true;
		t.down = false;
		t.set(_x, _y, 0, 0, TouchEventState.up);

		engine.ontouchup(t);

	}

	function onmove(_id:Int, _x:Int, _y:Int) {

		_verboser('onmove id:$_id, x:$_x, y$_y');

		var t = touches[_id];
		t.set(_x, _y, _x-t.x, _y-t.y, TouchEventState.move);

		engine.ontouchmove(t);

	}


}

@:allow(clay.input.Touch)
class TouchEvent {


	public var id(default, null):Int = 0;

	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;

	public var state(default, null):TouchEventState = TouchEventState.none;

	var pressed(default, null):Bool = false;
	var released(default, null):Bool = false;
	var down(default, null):Bool = false;

	
	function new(_id:Int) {

		id = _id;

	}

	inline function set(_x:Int, _y:Int, _dx:Int, _dy:Int, _state:TouchEventState) {
		
		x = _x;
		y = _y;
		dx = _dx;
		dy = _dy;
		state = _state;

	}

	inline function reset() {

		pressed = false;
		released = false;

	}


}

@:enum abstract TouchEventState(Int) from Int to Int {

    var none  = 0;
    var down  = 1;
    var up    = 2;
    var move  = 3;

}

