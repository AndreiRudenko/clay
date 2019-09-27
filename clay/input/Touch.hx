package clay.input;


import clay.system.App;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.TouchEvent;


@:allow(clay.system.InputManager)
@:access(clay.system.App)
class Touch extends Input {


	public var count(default, null):Int = 0;
	public var touches(default, null):Array<TouchEvent>;

	var _touches:Array<TouchEvent>;


	override function enable() {

		if(active) {
			return;
		}

		_debug('enable');

		_touches = [];
		touches = [];

		for (i in 0...10) {
			_touches.push(new TouchEvent(i));
		}

		#if use_touch_input

		var t = kha.input.Surface.get();
		if(t != null) {
			t.notify(onPressed, onReleased, onMove);
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
			t.remove(onPressed, onReleased, onMove);
		}
		
		#end

		_touches = null;

		super.disable();

	}

	function reset() {

	}

	function onPressed(id:Int, x:Int, y:Int) {

		_debug('onPressed id:$id, x:$x, y$y');

		count++;

		var t = _touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_DOWN);
		
		touches.push(t);

		_app.emitter.emit(TouchEvent.TOUCH_DOWN, t);


	}

	function onReleased(id:Int, x:Int, y:Int) {

		_debug('onPressed id:$id, x:$x, y$y');

		count--;

		var t = _touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_UP);

		_app.emitter.emit(TouchEvent.TOUCH_UP, t);

		touches.remove(t);

	}

	function onMove(id:Int, x:Int, y:Int) {

		_verboser('onMove id:$id, x:$x, y$y');

		var t = _touches[id];
		t.set(x, y, x - t.x, y - t.y, TouchEvent.TOUCH_MOVE);

		_app.emitter.emit(TouchEvent.TOUCH_MOVE, t);

	}


}
