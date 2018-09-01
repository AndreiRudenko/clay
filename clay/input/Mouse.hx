package clay.input;


import clay.Engine;
import clay.utils.Log.*;
import clay.utils.Bits;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Mouse extends Input {

	// todo: Vector?
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;

	var buttons_pressed:UInt = 0;
	var buttons_released:UInt = 0;
	var buttons_down:UInt = 0;
	var mouse_event:MouseEvent;


	override function enable() {

		if(active) {
			return;
		}

		mouse_event = new MouseEvent();

		#if use_mouse_input

		var m = kha.input.Mouse.get();
		if(m != null) {
			m.notify(onpressed, onreleased, onmove, onwheel);
		}

		#end

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		#if use_mouse_input

		var m = kha.input.Mouse.get();
		if(m != null) {
			m.remove(onpressed, onreleased, onmove, onwheel);
		}
		
		#end
		
		mouse_event = null;

		super.disable();

	}

    public inline function pressed(_button:Int):Bool {

    	return Bits.check(buttons_pressed, _button);

    }

    public inline function released(_button:Int):Bool {

    	return Bits.check(buttons_released, _button);

    }

    public inline function down(_button:Int):Bool {

    	return Bits.check(buttons_down, _button);

    }

	function reset() {

		buttons_pressed = 0;
		buttons_released = 0;

	}

	function onpressed(_button:Int, _x:Int, _y:Int) {

		_debug('onpressed x:$_x, y$_y, button:$_button');

		x = _x;
		y = _y;

		buttons_pressed = Bits.set(buttons_pressed, _button);
		buttons_down = Bits.set(buttons_down, _button);

		mouse_event.set(x, y, 0, 0, 0, MouseEventState.down, _button);

		engine.onmousedown(mouse_event);

	}

	function onreleased(_button:Int, _x:Int, _y:Int) {

		_debug('onpressed x:$_x, y$_y, button:$_button');

		x = _x;
		y = _y;

		buttons_pressed = Bits.clear(buttons_pressed, _button);
		buttons_down = Bits.clear(buttons_down, _button);
		buttons_released = Bits.set(buttons_released, _button);

		mouse_event.set(x, y, 0, 0, 0, MouseEventState.up, _button);

		engine.onmouseup(mouse_event);

	}

	function onwheel(d:Int) {
		
		_debug('onwheel delta:$d');

		mouse_event.set(x, y, 0, 0, d, MouseEventState.wheel, MouseButton.none);

		engine.onmousewheel(mouse_event);

	}

	function onmove(_x:Int, _y:Int, _x_rel:Int, _y_rel:Int) {

		_verboser('onmove x:$_x, y$_y, xrel:$_x_rel, yrel:$_y_rel');

		x = _x;
		y = _y;

		mouse_event.set(x, y, _x_rel, _y_rel, 0, MouseEventState.up, MouseButton.none);

		engine.onmousemove(mouse_event);

	}


}

@:allow(clay.input.Mouse)
class MouseEvent {


	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var x_rel(default, null):Int = 0;
	public var y_rel(default, null):Int = 0;
	public var wheel(default, null):Int = 0;

	public var button(default, null):MouseButton = MouseButton.none;
	public var state(default, null):MouseEventState = MouseEventState.none;

	
	function new() {}

	inline function set(_x:Int, _y:Int, _x_rel:Int, _y_rel:Int, _wheel:Int, _state:MouseEventState, _button:MouseButton) {
		
		x = _x;
		y = _y;
		x_rel = _x_rel;
		y_rel = _y_rel;
		wheel = _wheel;
		state = _state;
		button = _button;

	}

}

@:enum abstract MouseEventState(Int) from Int to Int {

    var none  = 0;
    var down  = 1;
    var up    = 2;
    var move  = 3;
    var wheel = 4;

}

@:enum abstract MouseButton(Int) from Int to Int {

    var none   	= 0;
    var left   	= 1;
    var right  	= 2;
    var middle 	= 3;
    var extra1 	= 4;
    var extra2 	= 5;
    var extra3 	= 6;
    var extra4 	= 7;

}
