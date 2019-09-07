package clay.system;


import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Touch;
import clay.input.Gamepad;
import clay.input.Pen;
import clay.input.Bindings;
import clay.system.App;


@:allow(clay.system.App)
class InputManager {


	public var binding      (default, null):Bindings;

	public var mouse   		(default, null):Mouse;
	public var keyboard		(default, null):Keyboard;
	public var touch   		(default, null):Touch;
	public var gamepad 		(default, null):Gamepads;
	public var pen     		(default, null):Pen;

	var _app:App;


	function new(app:App) {

		_app = app;
		binding = new Bindings(_app);

	}

	function init() {
		
		mouse = new Mouse(_app);
		keyboard = new Keyboard(_app);
		touch = new Touch(_app);
		gamepad = new Gamepads(_app);
		pen = new Pen(_app);

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
