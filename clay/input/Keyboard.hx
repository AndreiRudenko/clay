package clay.input;


import clay.ds.BitVector;
import clay.input.Key;
import clay.utils.Log.*;


@:allow(clay.core.Inputs)
@:access(clay.Engine)
class Keyboard extends Input {


	var key_code_pressed:BitVector;
	var key_code_released:BitVector;
	var key_code_down:BitVector;

	var key_event:KeyEvent;
	var dirty:Bool = false;


	override function enable() {

		if(active) {
			return;
		}

		#if use_keyboard_input

		var k = kha.input.Keyboard.get();
		if(k != null) {
			k.notify(onkeypressed, onkeyreleased, null);
		}

		#end
		
		key_code_pressed = new BitVector(256);
		key_code_released = new BitVector(256);
		key_code_down = new BitVector(256);

		key_event = new KeyEvent();

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		#if use_keyboard_input

		var k = kha.input.Keyboard.get();
		if(k != null) {
			k.remove(onkeypressed, onkeyreleased, null);
		}

		#end

		key_code_pressed = null;
		key_code_released = null;
		key_code_down = null;

		key_event = null;

		super.disable();

	}

	public function pressed(_key:Key):Bool {

		return key_code_pressed.get(_key);

	}

	public function released(_key:Key):Bool {

		return key_code_released.get(_key);

	}

	public function down(_key:Key):Bool {

		return key_code_down.get(_key);

	}

	function reset() {

		_verboser("reset");

		if(dirty) {
			key_code_pressed.disable_all();
			key_code_released.disable_all();
			dirty = false;
		}

	}

	function onkeypressed(_key:Int) {

		_verboser('onkeypressed: $_key');

		dirty = true;

		key_code_pressed.enable(_key);
		key_code_down.enable(_key);

		key_event.set(_key, KeyEventState.down);

		engine.onkeydown(key_event);

	}

	function onkeyreleased(_key:Int) {

		_verboser('onkeyreleased: $_key');

		dirty = true;

		key_code_released.enable(_key);
		key_code_pressed.disable(_key);
		key_code_down.disable(_key);

		key_event.set(_key, KeyEventState.up);

		engine.onkeyup(key_event);

	}


}

@:allow(clay.input.Keyboard)
class KeyEvent {


    public var key (default, null):Int;
	public var state (default, null):KeyEventState;


	function new() {}

	inline function set(_key:Int, _state:KeyEventState) {
		
		key = _key;
		state = _state;

	}


}

@:enum abstract KeyEventState(Int) from Int to Int {

    var none         = 0;
    var down         = 1;
    var up           = 2;

}

