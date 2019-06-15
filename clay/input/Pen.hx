package clay.input;


import clay.Engine;
import clay.ds.Uint4Vector;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.PenEvent;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Pen extends Input {


	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;
	public var pressure(default, null):Float = 0;

	var pen_pressed:Bool = false;
	var pen_released:Bool = false;
	var pen_down:Bool = false;

	var pen_event:PenEvent;


	override function enable() {

		if(active) {
			return;
		}

		pen_event = new PenEvent();
		
		#if use_pen_input

		var p = kha.input.Pen.get();
		if(p != null) {
			p.notify(onpressed, onreleased, onmove);
		}

		#end

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		#if use_pen_input

		var p = kha.input.Pen.get();
		if(p != null) {
			p.remove(onpressed, onreleased, onmove);
		}
		
		#end

		pen_event = null;

		super.disable();

	}

	function reset() {

		#if use_pen_input
		
		pen_pressed = false;
		pen_released = false;
		dx = 0;
		dy = 0;

		#end

	}

	function onpressed(_x:Int, _y:Int, _pressure:Float) {

		_debug('onpressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		pen_pressed = true;
		pen_released = false;
		pen_down = true;

		pen_event.set(x, y, 0, 0, PenEvent.PEN_DOWN, pressure);

		engine.emitter.emit(PenEvent.PEN_DOWN, pen_event);

	}

	function onreleased(_x:Int, _y:Int, _pressure:Float) {

		_debug('onpressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		pen_pressed = false;
		pen_released = true;
		pen_down = false;

		pen_event.set(x, y, 0, 0, PenEvent.PEN_UP, pressure);

		engine.emitter.emit(PenEvent.PEN_UP, pen_event);

	}

	function onmove(_x:Int, _y:Int, _pressure:Float) {

		_verboser('onmove x:$_x, y$_y, dx:$_dx, dy:$_dy');

		dx = _x - x;
		dy = _y - y;
		x = _x;
		y = _y;
		pressure = _pressure;

		pen_event.set(x, y, dx, dy, PenEvent.PEN_MOVE, pressure);

		engine.emitter.emit(PenEvent.PEN_MOVE, pen_event);

	}


}
