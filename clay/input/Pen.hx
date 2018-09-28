package clay.input;


import clay.Engine;
import clay.ds.Uint4Vector;
import clay.utils.Log.*;
import clay.utils.Bits;


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

		pen_pressed = false;
		pen_released = false;
		dx = 0;
		dy = 0;

	}

	function onpressed(_x:Int, _y:Int, _pressure:Float) {

		_debug('onpressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		pen_pressed = true;
		pen_released = false;
		pen_down = true;

		pen_event.set(x, y, 0, 0, PenEventState.down, pressure);

		engine.pendown(pen_event);

	}

	function onreleased(_x:Int, _y:Int, _pressure:Float) {

		_debug('onpressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		pen_pressed = false;
		pen_released = true;
		pen_down = false;

		pen_event.set(x, y, 0, 0, PenEventState.up, pressure);

		engine.penup(pen_event);

	}

	function onmove(_x:Int, _y:Int, _pressure:Float) {

		_verboser('onmove x:$_x, y$_y, dx:$_dx, dy:$_dy');

		dx = _x - x;
		dy = _y - y;
		x = _x;
		y = _y;
		pressure = _pressure;

		pen_event.set(x, y, dx, dy, PenEventState.move, pressure);

		engine.penmove(pen_event);

	}


}

@:allow(clay.input.Pen)
class PenEvent {


	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;
	
	public var pressure(default, null):Float = 0;
	public var state(default, null):PenEventState = PenEventState.none;

	
	function new() {}

	inline function set(_x:Int, _y:Int, _dx:Int, _dy:Int, _state:PenEventState, _pressure:Float) {
		
		x = _x;
		y = _y;
		dx = _dx;
		dy = _dy;
		state = _state;
		pressure = _pressure;

	}

}

@:enum abstract PenEventState(Int) from Int to Int {

    var none  = 0;
    var down  = 1;
    var up    = 2;
    var move  = 3;

}

