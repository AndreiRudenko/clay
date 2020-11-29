package clay.input;

import clay.App;
import clay.utils.Log;
import clay.utils.Bits;

import clay.events.MouseEvent;

@:allow(clay.Input)
@:access(clay.App)
class Mouse {

	public var active(default, null):Bool = false;
	
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;

	var _buttonsPressed:UInt = 0;
	var _buttonsReleased:UInt = 0;
	var _buttonsDown:UInt = 0;
	var _mouseEvent:MouseEvent;

	var _mouseBindings:Map<String, UInt>;
	var _binding:Bindings;

	public function new() {
		_mouseBindings = new Map();
		_binding = Clay.input.binding;
	}

	public function enable() {
		if(active) {
			return;
		}

		_mouseEvent = new MouseEvent();

		#if use_mouse_input

		var m = kha.input.Mouse.get();
		if(m != null) {
			m.notify(_onPressed, _onReleased, _onMove, _onWheel);
		}

		#end

		active = true;
	}

	public function disable() {
		if(!active) {
			return;
		}

		#if use_mouse_input

		var m = kha.input.Mouse.get();
		if(m != null) {
			m.remove(_onPressed, _onReleased, _onMove, _onWheel);
		}
		
		#end
		
		_mouseEvent = null;

		active = false;
	}

	public inline function pressed(button:Int):Bool {
		return Bits.check(_buttonsPressed, button);
	}

	public inline function released(button:Int):Bool {
		return Bits.check(_buttonsReleased, button);
	}

	public inline function down(button:Int):Bool {
		return Bits.check(_buttonsDown, button);
	}

	public function bind(name:String, key:UInt) {
		var n:Int = 0;
		
		if(_mouseBindings.exists(name)) {
			n = _mouseBindings.get(name);
		}

		_mouseBindings.set(name, Bits.set(n, key));
	}

	public function unbind(name:String) {
		if(_mouseBindings.exists(name)) {
			_mouseBindings.remove(name);
			_binding.removeAll(name);
		}
	}

	function checkBinding(key:Int, pressed:Bool) {
		for (k in _mouseBindings.keys()) { // todo: using this is broke hashlink build, ftw?
			if(_mouseBindings.exists(k)) {
				var n = _mouseBindings.get(k);
				if(Bits.check(n, key)) {
					_binding.inputEvent.setMouse(k, _mouseEvent);
					if(pressed) {
						_binding.inputPressed();
					} else {
						_binding.inputReleased();
					}
					return;
				}
			}
		}
	}

	function reset() {
		#if use_mouse_input
		_buttonsPressed = 0;
		_buttonsReleased = 0;
		#end
	}

	function _onPressed(button:Int, x:Int, y:Int) {
		Log.debug('_onPressed x:$x, y$y, button:$button');

		this.x = x;
		this.y = y;

		_buttonsPressed = Bits.set(_buttonsPressed, button);
		_buttonsDown = Bits.set(_buttonsDown, button);

		_mouseEvent.set(x, y, 0, 0, 0, MouseEvent.MOUSE_DOWN, button);

		checkBinding(button, true);

		Clay.app.emitter.emit(MouseEvent.MOUSE_DOWN, _mouseEvent);
	}

	function _onReleased(button:Int, x:Int, y:Int) {
		Log.debug('_onPressed x:$x, y$y, button:$button');

		this.x = x;
		this.y = y;

		_buttonsPressed = Bits.clear(_buttonsPressed, button);
		_buttonsDown = Bits.clear(_buttonsDown, button);
		_buttonsReleased = Bits.set(_buttonsReleased, button);

		_mouseEvent.set(x, y, 0, 0, 0, MouseEvent.MOUSE_UP, button);

		checkBinding(button, false);

		Clay.app.emitter.emit(MouseEvent.MOUSE_UP, _mouseEvent);
	}

	function _onWheel(d:Int) {
		Log.debug('_onWheel delta:$d');

		_mouseEvent.set(x, y, 0, 0, d, MouseEvent.MOUSE_WHEEL, MouseButton.NONE);

		checkBinding(MouseButton.NONE, false); // todo: check this

		Clay.app.emitter.emit(MouseEvent.MOUSE_WHEEL, _mouseEvent);
	}

	function _onMove(x:Int, y:Int, dx:Int, dy:Int) {
		Log.verbose('_onMove x:$x, y$y, dx:$dx, dy:$dy');

		this.x = x;
		this.y = y;

		_mouseEvent.set(x, y, dx, dy, 0, MouseEvent.MOUSE_MOVE, MouseButton.NONE);

		Clay.app.emitter.emit(MouseEvent.MOUSE_MOVE, _mouseEvent);
	}

}
