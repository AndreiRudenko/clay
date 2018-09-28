package clay.input;


import clay.ds.BitVector;
import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.utils.Log.*;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Bindings extends Input {


	@:noCompletion public var input_event:InputEvent;

	var input_pressed:Map<String, Int>;
	var input_released:Map<String, Int>;
	var input_down:Map<String, Int>;

	var dirty:Bool = false;


	override function enable() {

		if(active) {
			return;
		}
		
		input_pressed = new Map();
		input_released = new Map();
		input_down = new Map();

		input_event = new InputEvent();

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		input_pressed = null;
		input_released = null;
		input_down = null;

		input_event = null;

		super.disable();

	}

	public function pressed(_key:String):Bool {

		return input_pressed.exists(_key);

	}

	public function released(_key:String):Bool {

		return input_released.exists(_key);

	}

	public function down(_key:String):Bool {

		return input_down.exists(_key);

	}

	function reset() {

		_verboser("reset");

		if(dirty) {
			for (k in input_pressed.keys()) {
				input_pressed.remove(k);
			}
			for (k in input_released.keys()) {
				input_released.remove(k);
			}
			dirty = false;
		}

	}

	inline function add_pressed(_name:String) {
		
		var n:Int = 0;
		if(input_pressed.exists(_name)) {
			n = input_pressed.get(_name);
		}
		input_pressed.set(_name, ++n);

	}

	inline function add_down(_name:String) {
		
		var n:Int = 0;
		if(input_down.exists(_name)) {
			n = input_down.get(_name);
		}
		input_down.set(_name, ++n);

	}

	inline function add_released(_name:String) {
		
		var n:Int = 0;
		if(input_released.exists(_name)) {
			n = input_released.get(_name);
		}
		input_released.set(_name, ++n);
		
	}

	inline function remove_pressed(_name:String) {
		
		if(input_pressed.exists(_name)) {
			var n = input_pressed.get(_name);
			if(--n <= 0) {
				input_pressed.remove(_name);
			}
		}
		
	}

	inline function remove_down(_name:String) {
		
		if(input_down.exists(_name)) {
			var n = input_down.get(_name);
			if(--n <= 0) {
				input_down.remove(_name);
			}
		}
		
	}

	inline function remove_released(_name:String) {
		
		if(input_released.exists(_name)) {
			var n = input_released.get(_name);
			if(--n <= 0) {
				input_released.remove(_name);
			}
		}
		
	}

	@:noCompletion public function remove_all(_name:String) {

		remove_pressed(_name);
		remove_down(_name);
		remove_released(_name);

	}

	@:noCompletion public function inputpressed() {

		_verboser('inputpressed');

		dirty = true;

		add_pressed(input_event.name);
		add_down(input_event.name);

		engine.inputdown(input_event);

	}

	@:noCompletion public function inputreleased() {

		_verboser('inputreleased');

		dirty = true;

		add_released(input_event.name);
		remove_pressed(input_event.name);
		remove_down(input_event.name);

		engine.inputup(input_event);

	}


}

@:allow(clay.input.Bindings)
class InputEvent {


	public var name (default, null):String;
	public var type (default, null):InputType;

	public var mouse (default, null):MouseEvent;
	public var keyboard (default, null):KeyEvent;
	public var gamepad (default, null):GamepadEvent;
	public var touch (default, null):TouchEvent;
	public var pen (default, null):PenEvent;


	function new() {

		name = '';
		type = InputType.none;

	}

	inline function set(_mouse:MouseEvent, _keyboard:KeyEvent, _gamepad:GamepadEvent, _touch:TouchEvent, _pen:PenEvent) {

		mouse = _mouse;
		keyboard = _keyboard;
		gamepad = _gamepad;
		touch = _touch;
		pen = _pen;
		
	}

	@:noCompletion public function set_mouse(_name:String, _mouse:MouseEvent) {

		name = _name;
		type = InputType.mouse;
		set(_mouse, null, null, null, null);

	}

	@:noCompletion public function set_key(_name:String, _keyboard:KeyEvent) {

		name = _name;
		type = InputType.keyboard;
		set(null, keyboard, null, null, null);

	}

	@:noCompletion public function set_gamepad(_name:String, _gamepad:GamepadEvent) {

		name = _name;
		type = InputType.gamepad;
		set(null, null, _gamepad, null, null);

	}

	@:noCompletion public function set_touch(_name:String, _touch:TouchEvent) {

		name = _name;
		type = InputType.touch;
		set(null, null, null, _touch, null);

	}

	@:noCompletion public function set_pen(_name:String, _pen:PenEvent) {

		name = _name;
		type = InputType.pen;
		set(null, null, null, null, _pen);

	}


}

@:enum abstract InputType(Int) from Int to Int {

    var none          = 0;
    var mouse         = 1;
    var keyboard      = 2;
    var gamepad       = 3;
    var touch         = 4;
    var pen           = 5;

}

