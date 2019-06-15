package clay.input;


import clay.Engine;
import clay.ds.Uint4Vector;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.TouchEvent;


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

	}

	function onpressed(id:Int, x:Int, y:Int) {

		_debug('onpressed id:$id, x:$x, y$y');

		count++;

		var t = touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_DOWN);

		engine.emitter.emit(TouchEvent.TOUCH_DOWN, t);

	}

	function onreleased(id:Int, x:Int, y:Int) {

		_debug('onpressed id:$id, x:$x, y$y');

		count--;

		var t = touches[id];
		t.set(x, y, 0, 0, TouchEvent.TOUCH_UP);

		engine.emitter.emit(TouchEvent.TOUCH_UP, t);

	}

	function onmove(id:Int, x:Int, y:Int) {

		_verboser('onmove id:$id, x:$x, y$y');

		var t = touches[id];
		t.set(x, y, x - t.x, y - t.y, TouchEvent.TOUCH_MOVE);

		engine.emitter.emit(TouchEvent.TOUCH_MOVE, t);

	}


}
