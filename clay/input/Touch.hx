package clay.input;

import clay.App;
import clay.utils.Log;
import clay.utils.Bits;
import clay.events.TouchEvent;

@:allow(clay.Input)
@:access(clay.App)
class Touch {

	public var active(default, null):Bool = false;

	public var count(default, null):Int = 0;
	public var touches(default, null):Array<TouchEvent>;

	var _touches:Array<TouchEvent>;

	public function new() {
		
	}

	public function enable() {
		if(active) {
			return;
		}

		Log.debug('enable');

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

		active = true;
	}

	public function disable() {
		if(!active) {
			return;
		}

		Log.debug('disable');

		#if use_touch_input

		var t = kha.input.Surface.get();
		if(t != null) {
			t.remove(onPressed, onReleased, onMove);
		}
		
		#end

		_touches = null;

		active = false;
	}

	function reset() {}

	function onPressed(id:Int, x:Int, y:Int) {
		Log.debug('onPressed id:$id, x:$x, y$y');

		count++;

		var t = _touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_DOWN);
		
		touches.push(t);

		Clay.app.emitter.emit(TouchEvent.TOUCH_DOWN, t);
	}

	function onReleased(id:Int, x:Int, y:Int) {
		Log.debug('onPressed id:$id, x:$x, y$y');

		count--;

		var t = _touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_UP);

		Clay.app.emitter.emit(TouchEvent.TOUCH_UP, t);

		touches.remove(t);
	}

	function onMove(id:Int, x:Int, y:Int) {
		Log.verbose('onMove id:$id, x:$x, y$y');

		var t = _touches[id];
		t.set(x, y, x - t.x, y - t.y, TouchEvent.TOUCH_MOVE);

		Clay.app.emitter.emit(TouchEvent.TOUCH_MOVE, t);
	}

}
