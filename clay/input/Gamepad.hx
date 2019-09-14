package clay.input;


import clay.system.App;
import clay.utils.Log.*;
import clay.utils.Bits;
import clay.events.GamepadEvent;


@:allow(clay.system.InputManager)
@:access(clay.events.GamepadEvent)
class Gamepads extends Input {


	// need to figure how gamepad is stored, and change map to array maybe
	var gamepads:Map<Int, Gamepad>;
	var gamepadEvent:GamepadEvent;

	var gamepadBindings:Map<String, Map<Int, Int>>;
	var binding:Bindings;


	function new(app:App) {
		
		super(app);

		gamepadBindings = new Map();
		binding = Clay.input.binding;

	}

	public function get(_gamepad:Int):Gamepad {

		if(!active) {
			return null;
		}

		return gamepads.get(_gamepad);

	}

	override function enable() {

		if(active) {
			return;
		}

		gamepads = new Map();

		#if use_gamepad_input
		
		kha.input.Gamepad.notifyOnConnect(onconnect, ondisconnect);

		#end 

		gamepadEvent = new GamepadEvent();

		super.enable();

	}

	override function disable() {
		
		if(!active) {
			return;
		}

		#if use_gamepad_input

		kha.input.Gamepad.removeConnect(onconnect, ondisconnect);
		for (g in gamepads) {
			g.unlistenEvents();
		}

		#end 

		gamepads = null;
		gamepadEvent = null;

		super.disable();

	}

	public function pressed(_gamepad:Int, _button:Int):Bool {

		var g = gamepads.get(_gamepad);
		if(g != null) {
			return g.pressed(_button);
		}

		return false;

	}

	public function released(_gamepad:Int, _button:Int):Bool {

		var g = gamepads.get(_gamepad);
		if(g != null) {
			return g.released(_button);
		}

		return false;

	}

	public function down(_gamepad:Int, _button:Int):Bool {

		var g = gamepads.get(_gamepad);
		if(g != null) {
			return g.down(_button);
		}

		return false;

	}

	public function axis(_gamepad:Int, _axis:Int):Float {

		var g = gamepads.get(_gamepad);
		if(g != null) {
			return g.axis(_axis);
		}

		return 0;

	}

    public function bind(_name:String, _gamepad:Int, _button:Int) {

    	var b = gamepadBindings.get(_name);

    	if(b == null) {
    		b = new Map();
    		gamepadBindings.set(_name, b);
    	}

    	b.set(_gamepad, _button);

    }

    public function unbind(_name:String) {

    	if(gamepadBindings.exists(_name)) {
    		gamepadBindings.remove(_name);
    		binding.removeAll(_name);
    	}

    }

    function checkBinding(_gamepad:Int, _button:Int, _pressed:Bool) {

    	for (k in gamepadBindings.keys()) { // todo: using this is broke hashlink build, ftw?
    		var g = gamepadBindings.get(k);
    		if(g != null) {
    			if(g.exists(_gamepad)) {
    				var n = g.get(_gamepad);
		    		if(Bits.check(n, _button)) {
			    		binding.inputEvent.setGamepad(k, gamepadEvent);
				    	if(_pressed) {
				    		binding.inputPressed();
				    	} else {
							binding.inputReleased();
				    	}
				    	return;
		    		}
    			}
    		}
    	}

    }

	function reset() {

		#if use_gamepad_input
		
		for (g in gamepads) {
			g.clear();
		}

		#end

	}

	function onconnect(_gamepad:Int) {
		
		_debug('onconnect gamepad:$_gamepad');
		assert(!gamepads.exists(_gamepad), 'trying to add gamepad that already exists');

		var g = new Gamepad(_gamepad, this);
		g.listenEvents();
		gamepads.set(_gamepad, g);

		gamepadEvent.set(_gamepad, g.id, -1, -1, 0, GamepadEvent.DEVICE_ADDED);

		_app.emitter.emit(GamepadEvent.DEVICE_ADDED, gamepadEvent);

	}

	function ondisconnect(_gamepad:Int) {
		
		_debug('ondisconnect gamepad:$_gamepad');
		assert(gamepads.exists(_gamepad), 'trying to remove gamepad that not exists');

		var g = gamepads.get(_gamepad);
		g.unlistenEvents();
		gamepads.remove(_gamepad);

		gamepadEvent.set(_gamepad, g.id, -1, -1, 0, GamepadEvent.DEVICE_REMOVED);
		
		_app.emitter.emit(GamepadEvent.DEVICE_REMOVED, gamepadEvent);

	}

}

@:allow(clay.input.Gamepads)
@:access(clay.system.App, clay.input.Gamepads)
class Gamepad {


	public var id(default, null):String;
	public var gamepad(default, null):Int;
	public var deadzone:Float = 0.15;

	var buttonsPressed:UInt = 0;
	var buttonsReleased:UInt = 0;
	var buttonsDown:UInt = 0;

	var axisID:Int = -1;
	var axisValue:Float = 0;

	var gamepadEvent:GamepadEvent;
	var gamepads:Gamepads;


	function new(_g:Int, _gamepads:Gamepads) {

		gamepad = _g;
		gamepads = _gamepads;
		id = kha.input.Gamepad.get(gamepad).id;
		gamepadEvent = new GamepadEvent();

	}

	public inline function pressed(_b:Int):Bool {

		return Bits.check(buttonsPressed, _b);

	}

	public inline function released(_b:Int):Bool {

		return Bits.check(buttonsReleased, _b);

	}

	public inline function down(_b:Int):Bool {

		return Bits.check(buttonsDown, _b);

	}

	public inline function axis(_a:Int):Float {

		if(_a == axisID) {
			return axisValue;
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

		buttonsPressed = 0;
		buttonsReleased = 0;
		axisID = -1;
		axisValue = 0;

	}

	function onAxis(_a:Int, _v:Float) {

		if(Math.abs(_v) < deadzone) {
			return;
		}
		
		_debug('onAxis gamepad:$gamepad, axis:$_a, value:$value');

		axisID = _a;
		axisValue = _v;

		gamepadEvent.set(gamepad, id, -1, axisID, axisValue, GamepadEvent.AXIS);

		gamepads._app.emitter.emit(GamepadEvent.AXIS, gamepadEvent);

	}

	function onButton(_b:Int, _v:Float) {
		
		_debug('onButton gamepad:$gamepad, button:$_b, value:$_v');

		if(_v > 0.5) {
			onPressed(_b);
		} else {
			onReleased(_b);
		}

	}

	inline function onPressed(_b:Int) {

		_debug('onPressed gamepad:$gamepad, button:$_b');

		buttonsPressed = Bits.set(buttonsPressed, _b);
		buttonsDown = Bits.set(buttonsDown, _b);

		gamepadEvent.set(gamepad, id, _b, -1, 0, GamepadEvent.BUTTON_DOWN);

		gamepads.checkBinding(gamepad, _b, true);

		gamepads._app.emitter.emit(GamepadEvent.BUTTON_DOWN, gamepadEvent);

	}

	inline function onReleased(_b:Int) {

		_debug('onReleased gamepad:$gamepad, button:$_b');

		buttonsPressed = Bits.clear(buttonsPressed, _b);
		buttonsDown = Bits.clear(buttonsDown, _b);
		buttonsReleased = Bits.set(buttonsReleased, _b);

		gamepadEvent.set(gamepad, id, _b, -1, 0, GamepadEvent.BUTTON_UP);

		gamepads.checkBinding(gamepad, _b, false);

		gamepads._app.emitter.emit(GamepadEvent.BUTTON_UP, gamepadEvent);

	}


}