package clay.input;


import clay.ds.BitVector;
import clay.input.Key;
import clay.utils.Log.*;
import clay.events.KeyEvent;
import clay.system.App;


@:allow(clay.system.InputManager)
@:access(clay.system.App)
class Keyboard extends Input {


	var _keyCodePressed:BitVector;
	var _keyCodeReleased:BitVector;
	var _keyCodeDown:BitVector;

	var _keyEvent:KeyEvent;
	var _dirty:Bool = false;

	var _keyBindings:Map<String, Map<Int, Bool>>;
	var _binding:Bindings;


	function new(app:App) {
		
		super(app);

		_keyBindings = new Map();
		_binding = Clay.input.binding;

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
		
		_keyCodePressed = new BitVector(256);
		_keyCodeReleased = new BitVector(256);
		_keyCodeDown = new BitVector(256);

		_keyEvent = new KeyEvent();

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

		_keyCodePressed = null;
		_keyCodeReleased = null;
		_keyCodeDown = null;

		_keyEvent = null;

		super.disable();

	}

	public function pressed(key:Key):Bool {

		return _keyCodePressed.get(key);

	}

	public function released(key:Key):Bool {

		return _keyCodeReleased.get(key);

	}

	public function down(key:Key):Bool {

		return _keyCodeDown.get(key);

	}

	public function bind(name:String, key:Key) {

		var b = _keyBindings.get(name);
		if(b == null) {
			b = new Map<Int, Bool>();
			_keyBindings.set(name, b);
		}
		b.set(key, true);

	}

	public function unbind(name:String) {
		
		if(_keyBindings.exists(name)) {
			_keyBindings.remove(name);
			_binding.removeAll(name);
		}

	}

	function checkBinding(key:Int, pressed:Bool) {

		for (k in _keyBindings.keys()) {
			if(_keyBindings.get(k).exists(key)) {
				_binding.inputEvent.setKey(k, _keyEvent);
				if(pressed) {
					_binding.inputPressed();
				} else {
					_binding.inputReleased();
				}
				return;
			}
		}

	}

	function reset() {

		#if use_keyboard_input
		
		_verboser("reset");

		if(_dirty) {
			_keyCodePressed.disableAll();
			_keyCodeReleased.disableAll();
			_dirty = false;
		}

		#end
	}

	function onKeyPressed(key:Int) {

		_verboser('onKeyPressed: $key');

		_dirty = true;

		_keyCodePressed.enable(key);
		_keyCodeDown.enable(key);

		_keyEvent.set(key, KeyEvent.KEY_DOWN);

		checkBinding(key, true);

		_app.emitter.emit(KeyEvent.KEY_DOWN, _keyEvent);

	}

	function onKeyReleased(key:Int) {

		_verboser('onKeyReleased: $key');

		_dirty = true;

		_keyCodeReleased.enable(key);
		_keyCodePressed.disable(key);
		_keyCodeDown.disable(key);

		_keyEvent.set(key, KeyEvent.KEY_UP);

		checkBinding(key, false);

		_app.emitter.emit(KeyEvent.KEY_UP, _keyEvent);

	}
	
	function onTextInput(char:String) {

		_verboser('onTextInput: $char');

		_app.emitter.emit(KeyEvent.TEXT_INPUT, char);

	}


}
