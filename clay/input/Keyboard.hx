package clay.input;


import clay.ds.BitVector;
import clay.input.Key;
import clay.utils.Log.*;
import clay.events.KeyEvent;
import clay.system.App;


@:allow(clay.system.InputManager)
@:access(clay.system.App)
class Keyboard extends Input {


	var keyCodePressed:BitVector;
	var keyCodeReleased:BitVector;
	var keyCodeDown:BitVector;

	var keyEvent:KeyEvent;
	var dirty:Bool = false;

	var keyBindings:Map<String, Map<Int, Bool>>;
	var binding:Bindings;


	function new(app:App) {
		
		super(app);

		keyBindings = new Map();
		binding = Clay.input.binding;

	}

	override function enable() {

		if(active) {
			return;
		}

		#if use_keyboard_input

		var k = kha.input.Keyboard.get();
		if(k != null) {
			k.notify(onKeyPressed, onKeyReleased, onTextInput);
		}

		#end
		
		keyCodePressed = new BitVector(256);
		keyCodeReleased = new BitVector(256);
		keyCodeDown = new BitVector(256);

		keyEvent = new KeyEvent();

		super.enable();

	}

	override function disable() {

		if(!active) {
			return;
		}

		#if use_keyboard_input

		var k = kha.input.Keyboard.get();
		if(k != null) {
			k.remove(onKeyPressed, onKeyReleased, onTextInput);
		}

		#end

		keyCodePressed = null;
		keyCodeReleased = null;
		keyCodeDown = null;

		keyEvent = null;

		super.disable();

	}

	public function pressed(_key:Key):Bool {

		return keyCodePressed.get(_key);

	}

	public function released(_key:Key):Bool {

		return keyCodeReleased.get(_key);

	}

	public function down(_key:Key):Bool {

		return keyCodeDown.get(_key);

	}

	public function bind(_name:String, _key:Key) {

		var b = keyBindings.get(_name);
		if(b == null) {
			b = new Map<Int, Bool>();
			keyBindings.set(_name, b);
		}
		b.set(_key, true);

	}

	public function unbind(_name:String) {
		
		if(keyBindings.exists(_name)) {
			keyBindings.remove(_name);
			binding.removeAll(_name);
		}

	}

	function checkBinding(_key:Int, _pressed:Bool) {

		for (k in keyBindings.keys()) {
			if(keyBindings.get(k).exists(_key)) {
				binding.inputEvent.setKey(k, keyEvent);
				if(_pressed) {
					binding.inputPressed();
				} else {
					binding.inputReleased();
				}
				return;
			}
		}

	}

	function reset() {

		#if use_keyboard_input
		
		_verboser("reset");

		if(dirty) {
			keyCodePressed.disableAll();
			keyCodeReleased.disableAll();
			dirty = false;
		}

		#end
	}

	function onKeyPressed(_key:Int) {

		_verboser('onKeyPressed: $_key');

		dirty = true;

		keyCodePressed.enable(_key);
		keyCodeDown.enable(_key);

		keyEvent.set(_key, KeyEvent.KEY_DOWN);

		checkBinding(_key, true);

		_app.emitter.emit(KeyEvent.KEY_DOWN, keyEvent);

	}

	function onKeyReleased(_key:Int) {

		_verboser('onKeyReleased: $_key');

		dirty = true;

		keyCodeReleased.enable(_key);
		keyCodePressed.disable(_key);
		keyCodeDown.disable(_key);

		keyEvent.set(_key, KeyEvent.KEY_UP);

		checkBinding(_key, false);

		_app.emitter.emit(KeyEvent.KEY_UP, keyEvent);

	}
	
	function onTextInput(_char:String) {

		_verboser('onTextInput: $_char');

		_app.emitter.emit(KeyEvent.TEXT_INPUT, _char);

	}


}
