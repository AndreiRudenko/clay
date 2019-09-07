package clay.input;


import clay.system.App;
import clay.utils.Log.*;
import clay.utils.Bits;

import clay.events.MouseEvent;


@:allow(clay.system.InputManager)
@:access(clay.system.App)
class Mouse extends Input {


	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;

	var _buttons_pressed:UInt = 0;
	var _buttons_released:UInt = 0;
	var _buttons_down:UInt = 0;
	var _mouse_event:MouseEvent;

	var _mouse_bindings:Map<String, UInt>;
	var _binding:Bindings;


	function new(_app:App) {
		
		super(_app);

		_mouse_bindings = new Map();
		_binding = Clay.input.binding;

	}

	override function enable() {

		if(active) {
			return;
		}

		_mouse_event = new MouseEvent();

		#if use_mouse_input

		var m = kha.input.Mouse.get();
		if(m != null) {
			m.notify(_onpressed, _onreleased, _onmove, _onwheel);
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
			m.remove(_onpressed, _onreleased, _onmove, _onwheel);
		}
		
		#end
		
		_mouse_event = null;

		super.disable();

	}

    public inline function pressed(button:Int):Bool {

    	return Bits.check(_buttons_pressed, button);

    }

    public inline function released(button:Int):Bool {

    	return Bits.check(_buttons_released, button);

    }

    public inline function down(button:Int):Bool {

    	return Bits.check(_buttons_down, button);

    }

    public function bind(name:String, key:UInt) {

    	var n:Int = 0;
    	
    	if(_mouse_bindings.exists(name)) {
    		n = _mouse_bindings.get(name);
    	}

    	_mouse_bindings.set(name, Bits.set(n, key));

    }

    public function unbind(name:String) {
    	
    	if(_mouse_bindings.exists(name)) {
    		_mouse_bindings.remove(name);
    		_binding.remove_all(name);
    	}

    }

    function check_binding(key:Int, pressed:Bool) {

    	for (k in _mouse_bindings.keys()) { // todo: using this is broke hashlink build, ftw?
    		if(_mouse_bindings.exists(k)) {
    			var n = _mouse_bindings.get(k);
	    		if(Bits.check(n, key)) {
		    		_binding.input_event.set_mouse(k, _mouse_event);
			    	if(pressed) {
			    		_binding.inputpressed();
			    	} else {
						_binding.inputreleased();
			    	}
			    	return;
	    		}
    		}
    	}

    }

	function reset() {

		#if use_mouse_input
		
		_buttons_pressed = 0;
		_buttons_released = 0;

		#end
	}

	function _onpressed(button:Int, x:Int, y:Int) {

		_debug('_onpressed x:$x, y$y, button:$button');

		this.x = x;
		this.y = y;

		_buttons_pressed = Bits.set(_buttons_pressed, button);
		_buttons_down = Bits.set(_buttons_down, button);

		_mouse_event.set(x, y, 0, 0, 0, MouseEvent.MOUSE_DOWN, button);

		check_binding(button, true);

		_app.emitter.emit(MouseEvent.MOUSE_DOWN, _mouse_event);

	}

	function _onreleased(button:Int, x:Int, y:Int) {

		_debug('_onpressed x:$x, y$y, button:$button');

		this.x = x;
		this.y = y;

		_buttons_pressed = Bits.clear(_buttons_pressed, button);
		_buttons_down = Bits.clear(_buttons_down, button);
		_buttons_released = Bits.set(_buttons_released, button);

		_mouse_event.set(x, y, 0, 0, 0, MouseEvent.MOUSE_UP, button);

		check_binding(button, false);

		_app.emitter.emit(MouseEvent.MOUSE_UP, _mouse_event);

	}

	function _onwheel(d:Int) {
		
		_debug('_onwheel delta:$d');

		_mouse_event.set(x, y, 0, 0, d, MouseEvent.MOUSE_WHEEL, MouseButton.none);

		check_binding(MouseButton.none, false); // todo: check this

		_app.emitter.emit(MouseEvent.MOUSE_WHEEL, _mouse_event);

	}

	function _onmove(x:Int, y:Int, x_rel:Int, y_rel:Int) {

		_verboser('_onmove x:$x, y$y, xrel:$x_rel, yrel:$y_rel');

		this.x = x;
		this.y = y;

		_mouse_event.set(x, y, x_rel, y_rel, 0, MouseEvent.MOUSE_MOVE, MouseButton.none);

		_app.emitter.emit(MouseEvent.MOUSE_MOVE, _mouse_event);

	}


}
