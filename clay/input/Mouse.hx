package clay.input;


import clay.Engine;
import clay.utils.Log.*;
import clay.utils.Bits;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Mouse extends Input {

	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;

	var buttons_pressed:UInt = 0;
	var buttons_released:UInt = 0;
	var buttons_down:UInt = 0;
	var mouse_event:MouseEvent;

	var mouse_bindings:Map<String, UInt>;
	var binding:Bindings;


	function new(_engine:Engine) {
		
		super(_engine);

		mouse_bindings = new Map();
		binding = Clay.input.binding;

	}

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

    public function bind(_name:String, _key:UInt) {

    	var n:Int = 0;
    	
    	if(mouse_bindings.exists(_name)) {
    		n = mouse_bindings.get(_name);
    	}

    	mouse_bindings.set(_name, Bits.set(n, _key));

    }

    public function unbind(_name:String) {
    	
    	if(mouse_bindings.exists(_name)) {
    		mouse_bindings.remove(_name);
    		binding.remove_all(_name);
    	}

    }

    function check_binding(_key:Int, _pressed:Bool) {

    	for (k in mouse_bindings.keys()) { // todo: using this is broke hashlink build, ftw?
    		if(mouse_bindings.exists(k)) {
    			var n = mouse_bindings.get(k);
	    		if(Bits.check(n, _key)) {
		    		binding.input_event.set_mouse(k, mouse_event);
			    	if(_pressed) {
			    		binding.inputpressed();
			    	} else {
						binding.inputreleased();
			    	}
			    	return;
	    		}
    		}
    	}

    }

	function reset() {

		#if use_mouse_input
		
		buttons_pressed = 0;
		buttons_released = 0;

		#end
	}

	function onpressed(_button:Int, _x:Int, _y:Int) {

		_debug('onpressed x:$_x, y$_y, button:$_button');

		x = _x;
		y = _y;

		buttons_pressed = Bits.set(buttons_pressed, _button);
		buttons_down = Bits.set(buttons_down, _button);

		mouse_event.set(x, y, 0, 0, 0, MouseEventState.down, _button);

		check_binding(_button, true);

		engine.signals.mousedown.emit(mouse_event);

	}

	function onreleased(_button:Int, _x:Int, _y:Int) {

		_debug('onpressed x:$_x, y$_y, button:$_button');

		x = _x;
		y = _y;

		buttons_pressed = Bits.clear(buttons_pressed, _button);
		buttons_down = Bits.clear(buttons_down, _button);
		buttons_released = Bits.set(buttons_released, _button);

		mouse_event.set(x, y, 0, 0, 0, MouseEventState.up, _button);

		check_binding(_button, false);

		engine.signals.mouseup.emit(mouse_event);

	}

	function onwheel(d:Int) {
		
		_debug('onwheel delta:$d');

		mouse_event.set(x, y, 0, 0, d, MouseEventState.wheel, MouseButton.none);

		check_binding(MouseButton.none, false); // todo: check this

		engine.signals.mousewheel.emit(mouse_event);

	}

	function onmove(_x:Int, _y:Int, _x_rel:Int, _y_rel:Int) {

		_verboser('onmove x:$_x, y$_y, xrel:$_x_rel, yrel:$_y_rel');

		x = _x;
		y = _y;

		mouse_event.set(x, y, _x_rel, _y_rel, 0, MouseEventState.up, MouseButton.none);

		engine.signals.mousemove.emit(mouse_event);

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

    var none   	= -1;
    var left   	= 0;
    var right  	= 1;
    var middle 	= 2;
    var extra1 	= 3;
    var extra2 	= 4;
    var extra3 	= 5;
    var extra4 	= 6;

}
