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

	var _penPressed:Bool = false;
	var _penReleased:Bool = false;
	var _penDown:Bool = false;

	var _penEvent:PenEvent;


	override function enable() {

		if(active) {
			return;
		}

		_penEvent = new PenEvent();
		
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

		_penEvent = null;

		super.disable();

	}

	function reset() {

		#if use_pen_input
		
		_penPressed = false;
		_penReleased = false;
		dx = 0;
		dy = 0;

		#end

	}

	function onPressed(x:Int, y:Int, pressure:Float) {

		_debug('onPressed x:$x, y$y, button:$pressure');

		this.x = x;
		this.y = y;
		this.pressure = pressure;

		_penPressed = true;
		_penReleased = false;
		_penDown = true;

		_penEvent.set(x, y, 0, 0, PenEvent.PEN_DOWN, pressure);

		_app.emitter.emit(PenEvent.PEN_DOWN, _penEvent);

	}

	function onReleased(x:Int, y:Int, pressure:Float) {

		_debug('onReleased x:$x, y$y, button:$pressure');

		this.x = x;
		this.y = y;
		this.pressure = pressure;

		_penPressed = false;
		_penReleased = true;
		_penDown = false;

		_penEvent.set(x, y, 0, 0, PenEvent.PEN_UP, pressure);

		_app.emitter.emit(PenEvent.PEN_UP, _penEvent);

	}

	function onMove(x:Int, y:Int, pressure:Float) {

		dx = x - this.x;
		dy = y - this.y;
		this.x = x;
		this.y = y;
		this.pressure = pressure;

		_verboser('onMove x:$x, y$y, dx:$dx, dy:$dy');

		_penEvent.set(x, y, dx, dy, PenEvent.PEN_MOVE, pressure);

		_app.emitter.emit(PenEvent.PEN_MOVE, _penEvent);

	}


}
