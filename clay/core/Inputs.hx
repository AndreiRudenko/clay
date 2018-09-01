package clay.core;


import clay.input.Mouse;
import clay.input.Keyboard;
import clay.input.Touch;
import clay.input.Gamepad;
import clay.input.Pen;
import clay.Engine;


@:allow(clay.Engine)
class Inputs {


	public var mouse   		(default, null):Mouse;
	public var keyboard		(default, null):Keyboard;
	public var touch   		(default, null):Touch;
	public var gamepad 		(default, null):Gamepads;
	public var pen     		(default, null):Pen;


	function new(_engine:Engine) {

		mouse = new Mouse(_engine);
		keyboard = new Keyboard(_engine);
		touch = new Touch(_engine);
		gamepad = new Gamepads(_engine);
		pen = new Pen(_engine);

	}

	function destroy() {
		
		mouse = null;
		keyboard = null;
		touch = null;
		gamepad = null;
		pen = null;

	}

	function enable() {
		
		mouse.enable();
		keyboard.enable();
		touch.enable();
		gamepad.enable();
		pen.enable();

	}

	function disable() {
		
		mouse.disable();
		keyboard.disable();
		touch.disable();
		gamepad.disable();
		pen.disable();

	}

	function reset() {

		mouse.reset();
		keyboard.reset();
		touch.reset();
		gamepad.reset();
		pen.reset();
		
	}


}
