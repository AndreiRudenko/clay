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

	var key_bindings:Map<String, Map<Int, Bool>>;
	var binding:Bindings;


	function new(_engine:Engine) {
		
		super(_engine);

		key_bindings = new Map();
		binding = Clay.input.binding;

	}

	override function enable() {

		if(active) {
			return;
		}

		#if use_keyboard_input

		var k = kha.input.Keyboard.get();
		if(k != null) {
			k.notify(onkeypressed, onkeyreleased, ontextinput);
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
			k.remove(onkeypressed, onkeyreleased, ontextinput);
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

    public function bind(_name:String, _key:Key) {

    	var b = key_bindings.get(_name);
    	if(b == null) {
    		b = new Map<Int, Bool>();
    		key_bindings.set(_name, b);
    	}
    	b.set(_key, true);

    }

    public function unbind(_name:String) {
    	
    	if(key_bindings.exists(_name)) {
    		key_bindings.remove(_name);
    		binding.remove_all(_name);
    	}

    }

    function check_binding(_key:Int, _pressed:Bool) {

    	for (k in key_bindings.keys()) {
    		if(key_bindings.get(k).exists(_key)) {
		    	binding.input_event.set_key(k, key_event);
			    if(_pressed) {
			    	binding.inputpressed();
			    } else {
					binding.inputreleased();
			    }
			    return;
    		}
    	}

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

		check_binding(_key, true);

		engine.keydown(key_event);

	}

	function onkeyreleased(_key:Int) {

		_verboser('onkeyreleased: $_key');

		dirty = true;

		key_code_released.enable(_key);
		key_code_pressed.disable(_key);
		key_code_down.disable(_key);

		key_event.set(_key, KeyEventState.up);

		check_binding(_key, false);

		engine.keyup(key_event);

	}
	
	function ontextinput(_char:String) {

		_verboser('ontextinput: $_char');

		engine.textinput(_char);

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

