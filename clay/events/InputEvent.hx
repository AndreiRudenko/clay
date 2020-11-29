package clay.events;

import clay.utils.EventType;

@:allow(clay.input.Bindings)
class InputEvent implements IEvent {

	static public inline var INPUT_UP:EventType<InputEvent>;
	static public inline var INPUT_DOWN:EventType<InputEvent>;

	public var name(default, null):String;
	public var type(default, null):InputType;

	public var mouse(default, null):MouseEvent;
	public var keyboard(default, null):KeyEvent;
	public var gamepad(default, null):GamepadEvent;
	public var touch(default, null):TouchEvent;
	public var pen(default, null):PenEvent;

	function new() {
		name = "";
		type = InputType.NONE;
	}

	inline function set(mouse:MouseEvent, keyboard:KeyEvent, gamepad:GamepadEvent, touch:TouchEvent, pen:PenEvent) {
		this.mouse = mouse;
		this.keyboard = keyboard;
		this.gamepad = gamepad;
		this.touch = touch;
		this.pen = pen;
	}

	@:noCompletion public function setMouse(name:String, mouse:MouseEvent) {
		this.name = name;
		type = InputType.MOUSE;
		set(mouse, null, null, null, null);
	}

	@:noCompletion public function setKey(name:String, keyboard:KeyEvent) {
		this.name = name;
		type = InputType.KEYBOARD;
		set(null, keyboard, null, null, null);
	}

	@:noCompletion public function setGamepad(name:String, gamepad:GamepadEvent) {
		this.name = name;
		type = InputType.GAMEPAD;
		set(null, null, gamepad, null, null);
	}

	@:noCompletion public function setTouch(name:String, touch:TouchEvent) {
		this.name = name;
		type = InputType.TOUCH;
		set(null, null, null, touch, null);
	}

	@:noCompletion public function setPen(name:String, pen:PenEvent) {
		this.name = name;
		type = InputType.PEN;
		set(null, null, null, null, pen);
	}

}

enum abstract InputType(Int){
	var NONE;
	var MOUSE;
	var KEYBOARD;
	var GAMEPAD;
	var TOUCH;
	var PEN;
}

