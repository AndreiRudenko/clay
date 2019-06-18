package clay.input;


import clay.ds.BitVector;
import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.utils.Log.*;
import clay.events.*;


@:allow(clay.system.InputManager)
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

		_app.emitter.emit(InputEvent.INPUT_DOWN, input_event);

	}

	@:noCompletion public function inputreleased() {

		_verboser('inputreleased');

		dirty = true;

		add_released(input_event.name);
		remove_pressed(input_event.name);
		remove_down(input_event.name);

		_app.emitter.emit(InputEvent.INPUT_UP, input_event);

	}


}
