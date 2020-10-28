package clay.input;

import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.utils.Log;
import clay.events.*;

@:allow(clay.Input)
class Bindings {

	public var active(default, null):Bool = false;

	@:noCompletion public var inputEvent:InputEvent;

	var _inputPressed:Map<String, Int>;
	var _inputReleased:Map<String, Int>;
	var _inputDown:Map<String, Int>;

	var _dirty:Bool = false;

	public function new() {}

	public function enable() {
		if(active) {
			return;
		}
		
		_inputPressed = new Map();
		_inputReleased = new Map();
		_inputDown = new Map();

		inputEvent = new InputEvent();
		
		active = true;
	}

	public function disable() {
		if(!active) {
			return;
		}

		_inputPressed = null;
		_inputReleased = null;
		_inputDown = null;

		inputEvent = null;

		active = false;
	}

	public function pressed(_key:String):Bool {
		return _inputPressed.exists(_key);
	}

	public function released(_key:String):Bool {
		return _inputReleased.exists(_key);
	}

	public function down(_key:String):Bool {
		return _inputDown.exists(_key);
	}

	function reset() {
		if(_dirty) {
			Log.debug("reset");
			for (k in _inputPressed.keys()) {
				_inputPressed.remove(k);
			}
			for (k in _inputReleased.keys()) {
				_inputReleased.remove(k);
			}
			_dirty = false;
		}
	}

	inline function addPressed(_name:String) {
		var n:Int = 0;
		if(_inputPressed.exists(_name)) {
			n = _inputPressed.get(_name);
		}
		_inputPressed.set(_name, ++n);
	}

	inline function addDown(_name:String) {
		var n:Int = 0;
		if(_inputDown.exists(_name)) {
			n = _inputDown.get(_name);
		}
		_inputDown.set(_name, ++n);
	}

	inline function addReleased(_name:String) {
		var n:Int = 0;
		if(_inputReleased.exists(_name)) {
			n = _inputReleased.get(_name);
		}
		_inputReleased.set(_name, ++n);
	}

	inline function removePressed(_name:String) {
		if(_inputPressed.exists(_name)) {
			var n = _inputPressed.get(_name);
			if(--n <= 0) {
				_inputPressed.remove(_name);
			}
		}
	}

	inline function removeDown(_name:String) {
		if(_inputDown.exists(_name)) {
			var n = _inputDown.get(_name);
			if(--n <= 0) {
				_inputDown.remove(_name);
			}
		}
	}

	inline function removeReleased(_name:String) {
		if(_inputReleased.exists(_name)) {
			var n = _inputReleased.get(_name);
			if(--n <= 0) {
				_inputReleased.remove(_name);
			}
		}
	}

	@:noCompletion public function removeAll(_name:String) {
		removePressed(_name);
		removeDown(_name);
		removeReleased(_name);
	}

	@:noCompletion public function inputPressed() {
		Log.debug('inputPressed');

		_dirty = true;

		addPressed(inputEvent.name);
		addDown(inputEvent.name);

		Clay.app.emitter.emit(InputEvent.INPUT_DOWN, inputEvent);
	}

	@:noCompletion public function inputReleased() {
		Log.debug('inputReleased');

		_dirty = true;

		addReleased(inputEvent.name);
		removePressed(inputEvent.name);
		removeDown(inputEvent.name);

		Clay.app.emitter.emit(InputEvent.INPUT_UP, inputEvent);
	}

}
