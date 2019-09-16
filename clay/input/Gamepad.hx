package clay.input;


import clay.system.App;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.GamepadEvent;


@:allow(clay.system.InputManager)
@:access(clay.events.GamepadEvent)
class Gamepads extends Input {


	// need to figure how gamepad is stored, and change map to array maybe
	var _gamepads:Map<Int, Gamepad>;
	var _gamepadEvent:GamepadEvent;

	var _gamepadBindings:Map<String, Map<Int, Int>>;
	var _binding:Bindings;


	function new(app:App) {
		
		super(app);

		_gamepadBindings = new Map();
		_binding = Clay.input.binding;

	}

	public function get(gamepad:Int):Gamepad {

		if(!active) {
			return null;
		}

		return _gamepads.get(gamepad);

	}

	override function enable() {

		if(active) {
			return;
		}

		_gamepads = new Map();

		#if use_gamepad_input
		
		kha.input.Gamepad.notifyOnConnect(onconnect, ondisconnect);

		#end 

		_gamepadEvent = new GamepadEvent();

		super.enable();

	}

	override function disable() {
		
		if(!active) {
			return;
		}

		#if use_gamepad_input

		kha.input.Gamepad.removeConnect(onconnect, ondisconnect);
		for (g in _gamepads) {
			g.unlistenEvents();
		}

		#end 

		_gamepads = null;
		_gamepadEvent = null;

		super.disable();

	}

	public function pressed(gamepad:Int, button:Int):Bool {

		var g = _gamepads.get(gamepad);
		if(g != null) {
			return g.pressed(button);
		}

		return false;

	}

	public function released(gamepad:Int, button:Int):Bool {

		var g = _gamepads.get(gamepad);
		if(g != null) {
			return g.released(button);
		}

		return false;

	}

	public function down(gamepad:Int, button:Int):Bool {

		var g = _gamepads.get(gamepad);
		if(g != null) {
			return g.down(button);
		}

		return false;

	}

	public function axis(gamepad:Int, axis:Int):Float {

		var g = _gamepads.get(gamepad);
		if(g != null) {
			return g.axis(axis);
		}

		return 0;

	}

	public function bind(name:String, gamepad:Int, button:Int) {

		var b = _gamepadBindings.get(name);

		if(b == null) {
			b = new Map();
			_gamepadBindings.set(name, b);
		}

		b.set(gamepad, button);

	}

	public function unbind(name:String) {

		if(_gamepadBindings.exists(name)) {
			_gamepadBindings.remove(name);
			_binding.removeAll(name);
		}

	}

	function checkBinding(gamepad:Int, button:Int, pressed:Bool) {

		for (k in _gamepadBindings.keys()) { // todo: using this is broke hashlink build, ftw?
			var g = _gamepadBindings.get(k);
			if(g != null) {
				if(g.exists(gamepad)) {
					var n = g.get(gamepad);
					if(Bits.check(n, button)) {
						_binding.inputEvent.setGamepad(k, _gamepadEvent);
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

	}

	function reset() {

		#if use_gamepad_input
		
		for (g in _gamepads) {
			g.clear();
		}

		#end

	}

	function onconnect(gamepad:Int) {
		
		_debug('onconnect gamepad:$gamepad');
		assert(!_gamepads.exists(gamepad), 'trying to add gamepad that already exists');

		var g = new Gamepad(gamepad, this);
		g.listenEvents();
		_gamepads.set(gamepad, g);

		_gamepadEvent.set(gamepad, g.id, -1, -1, 0, GamepadEvent.DEVICE_ADDED);

		_app.emitter.emit(GamepadEvent.DEVICE_ADDED, _gamepadEvent);

	}

	function ondisconnect(gamepad:Int) {
		
		_debug('ondisconnect gamepad:$gamepad');
		assert(_gamepads.exists(gamepad), 'trying to remove gamepad that not exists');

		var g = _gamepads.get(gamepad);
		g.unlistenEvents();
		_gamepads.remove(gamepad);

		_gamepadEvent.set(gamepad, g.id, -1, -1, 0, GamepadEvent.DEVICE_REMOVED);
		
		_app.emitter.emit(GamepadEvent.DEVICE_REMOVED, _gamepadEvent);

	}

}

@:allow(clay.input.Gamepads)
@:access(clay.system.App, clay.input.Gamepads)
class Gamepad {


	public var id(default, null):String;
	public var gamepad(default, null):Int;
	public var deadzone:Float = 0.15;

	var _buttonsPressed:UInt = 0;
	var _buttonsReleased:UInt = 0;
	var _buttonsDown:UInt = 0;

	var _axisID:Int = -1;
	var _axisValue:Float = 0;

	var _gamepadEvent:GamepadEvent;
	var _gamepads:Gamepads;


	function new(gamepad:Int, gamepads:Gamepads) {

		this.gamepad = gamepad;
		_gamepads = gamepads;
		id = kha.input.Gamepad.get(this.gamepad).id;
		_gamepadEvent = new GamepadEvent();

	}

	public inline function pressed(b:Int):Bool {

		return Bits.check(_buttonsPressed, b);

	}

	public inline function released(b:Int):Bool {

		return Bits.check(_buttonsReleased, b);

	}

	public inline function down(b:Int):Bool {

		return Bits.check(_buttonsDown, b);

	}

	public inline function axis(a:Int):Float {

		if(a == _axisID) {
			return _axisValue;
		}

		return 0;

	}

	function listenEvents() {

		kha.input.Gamepad.get(gamepad).notify(onAxis, onButton);

	}

	function unlistenEvents() {

		kha.input.Gamepad.get(gamepad).remove(onAxis, onButton);

	}

	function clear() {

		_buttonsPressed = 0;
		_buttonsReleased = 0;
		_axisID = -1;
		_axisValue = 0;

	}

	function onAxis(a:Int, v:Float) {

		if(Math.abs(v) < deadzone) {
			return;
		}
		
		_debug('onAxis gamepad:$gamepad, axis:$a, value:$v');

		_axisID = a;
		_axisValue = v;

		_gamepadEvent.set(gamepad, id, -1, _axisID, _axisValue, GamepadEvent.AXIS);

		_gamepads._app.emitter.emit(GamepadEvent.AXIS, _gamepadEvent);

	}

	function onButton(b:Int, v:Float) {
		
		_debug('onButton gamepad:$gamepad, button:$b, value:$v');

		if(v > 0.5) {
			onPressed(b);
		} else {
			onReleased(b);
		}

	}

	inline function onPressed(b:Int) {

		_debug('onPressed gamepad:$gamepad, button:$b');

		_buttonsPressed = Bits.set(_buttonsPressed, b);
		_buttonsDown = Bits.set(_buttonsDown, b);

		_gamepadEvent.set(gamepad, id, b, -1, 0, GamepadEvent.BUTTON_DOWN);

		_gamepads.checkBinding(gamepad, b, true);
		_gamepads._app.emitter.emit(GamepadEvent.BUTTON_DOWN, _gamepadEvent);

	}

	inline function onReleased(b:Int) {

		_debug('onReleased gamepad:$gamepad, button:$b');

		_buttonsPressed = Bits.clear(_buttonsPressed, b);
		_buttonsDown = Bits.clear(_buttonsDown, b);
		_buttonsReleased = Bits.set(_buttonsReleased, b);

		_gamepadEvent.set(gamepad, id, b, -1, 0, GamepadEvent.BUTTON_UP);

		_gamepads.checkBinding(gamepad, b, false);
		_gamepads._app.emitter.emit(GamepadEvent.BUTTON_UP, _gamepadEvent);

	}


}