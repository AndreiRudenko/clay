package clay.input;


import clay.system.App;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.PenEvent;


@:allow(clay.system.InputManager)
@:access(clay.system.App)
class Pen extends Input {


	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;
	public var pressure(default, null):Float = 0;

	var penPressed:Bool = false;
	var penReleased:Bool = false;
	var penDown:Bool = false;

	var penEvent:PenEvent;


	override function enable() {

		if(active) {
			return;
		}

		penEvent = new PenEvent();
		
		#if use_pen_input

		var p = kha.input.Pen.get();
		if(p != null) {
			p.notify(onPressed, onReleased, onMove);
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
			p.remove(onPressed, onReleased, onMove);
		}
		
		#end

		penEvent = null;

		super.disable();

	}

	function reset() {

		#if use_pen_input
		
		penPressed = false;
		penReleased = false;
		dx = 0;
		dy = 0;

		#end

	}

	function onPressed(_x:Int, _y:Int, _pressure:Float) {

		_debug('onPressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		penPressed = true;
		penReleased = false;
		penDown = true;

		penEvent.set(x, y, 0, 0, PenEvent.PEN_DOWN, pressure);

		_app.emitter.emit(PenEvent.PEN_DOWN, penEvent);

	}

	function onReleased(_x:Int, _y:Int, _pressure:Float) {

		_debug('onPressed x:$_x, y$_y, button:$_pressure');

		x = _x;
		y = _y;
		pressure = _pressure;

		penPressed = false;
		penReleased = true;
		penDown = false;

		penEvent.set(x, y, 0, 0, PenEvent.PEN_UP, pressure);

		_app.emitter.emit(PenEvent.PEN_UP, penEvent);

	}

	function onMove(_x:Int, _y:Int, _pressure:Float) {

		_verboser('onMove x:$_x, y$_y, dx:$_dx, dy:$_dy');

		dx = _x - x;
		dy = _y - y;
		x = _x;
		y = _y;
		pressure = _pressure;

		penEvent.set(x, y, dx, dy, PenEvent.PEN_MOVE, pressure);

		_app.emitter.emit(PenEvent.PEN_MOVE, penEvent);

	}


}
