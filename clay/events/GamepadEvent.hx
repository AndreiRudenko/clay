package clay.events;

import clay.utils.EventType;

@:allow(clay.input.Gamepad)
class GamepadEvent implements IEvent {

	static public inline var BUTTON_UP:EventType<GamepadEvent>;
	static public inline var BUTTON_DOWN:EventType<GamepadEvent>;
	static public inline var AXIS:EventType<GamepadEvent>;
	static public inline var DEVICE_ADDED:EventType<GamepadEvent>;
	static public inline var DEVICE_REMOVED:EventType<GamepadEvent>;

	public var id(default, null):String;
	public var gamepad(default, null):Int;

	public var button(default, null):Int;
	public var axis(default, null):Int;
	public var value(default, null):Float;

	public var state(default, null):EventType<GamepadEvent>;

	public function new() {}

	inline function set(gamepad:Int, id:String, button:Int, axisID:Int, value:Float, state:EventType<GamepadEvent>) {
		this.id = id;
		this.gamepad = gamepad;
		this.button = button;
		this.axis = axisID;
		this.value = value;
		this.state = state;
	}

}