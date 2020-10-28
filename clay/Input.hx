package clay;

import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Touch;
import clay.input.Gamepad;
import clay.input.Pen;
import clay.input.Bindings;
import clay.App;

@:allow(clay.App)
class Input {

	public var binding(default, null):Bindings;

	public var mouse(default, null):Mouse;
	public var keyboard(default, null):Keyboard;
	public var touch(default, null):Touch;
	public var gamepad(default, null):Gamepads;
	public var pen(default, null):Pen;

	function new() {
		binding = new Bindings();
	}

	function init() {
		mouse = new Mouse();
		keyboard = new Keyboard();
		touch = new Touch();
		gamepad = new Gamepads();
		pen = new Pen();
	}

	function destroy() {
		binding = null;

		mouse = null;
		keyboard = null;
		touch = null;
		gamepad = null;
		pen = null;
	}

	function enable() {
		binding.enable();

		mouse.enable();
		keyboard.enable();
		touch.enable();
		gamepad.enable();
		pen.enable();
	}

	function disable() {
		binding.disable();

		mouse.disable();
		keyboard.disable();
		touch.disable();
		gamepad.disable();
		pen.disable();
	}

	function reset() {
		binding.reset();
		
		mouse.reset();
		keyboard.reset();
		touch.reset();
		gamepad.reset();
		pen.reset();
	}

}
