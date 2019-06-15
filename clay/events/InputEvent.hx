package clay.events;


@:allow(clay.input.Bindings)
class InputEvent implements IEvent {


	public static inline var INPUT_UP:EventType<InputEvent>;
	public static inline var INPUT_DOWN:EventType<InputEvent>;


	public var name (default, null):String;
	public var type (default, null):InputType;

	public var mouse (default, null):MouseEvent;
	public var keyboard (default, null):KeyEvent;
	public var gamepad (default, null):GamepadEvent;
	public var touch (default, null):TouchEvent;
	public var pen (default, null):PenEvent;


	function new() {

		name = '';
		type = InputType.none;

	}

	inline function set(mouse:MouseEvent, keyboard:KeyEvent, gamepad:GamepadEvent, touch:TouchEvent, pen:PenEvent) {

		this.mouse = mouse;
		this.keyboard = keyboard;
		this.gamepad = gamepad;
		this.touch = touch;
		this.pen = pen;
		
	}

	@:noCompletion public function set_mouse(name:String, mouse:MouseEvent) {

		this.name = name;
		type = InputType.mouse;
		set(mouse, null, null, null, null);

	}

	@:noCompletion public function set_key(name:String, keyboard:KeyEvent) {

		this.name = name;
		type = InputType.keyboard;
		set(null, keyboard, null, null, null);

	}

	@:noCompletion public function set_gamepad(name:String, gamepad:GamepadEvent) {

		this.name = name;
		type = InputType.gamepad;
		set(null, null, gamepad, null, null);

	}

	@:noCompletion public function set_touch(name:String, touch:TouchEvent) {

		this.name = name;
		type = InputType.touch;
		set(null, null, null, touch, null);

	}

	@:noCompletion public function set_pen(name:String, pen:PenEvent) {

		this.name = name;
		type = InputType.pen;
		set(null, null, null, null, pen);

	}


}

@:enum abstract InputType(Int) from Int to Int {

    var none          = 0;
    var mouse         = 1;
    var keyboard      = 2;
    var gamepad       = 3;
    var touch         = 4;
    var pen           = 5;

}

