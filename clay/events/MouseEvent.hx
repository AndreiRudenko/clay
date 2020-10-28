package clay.events;

import clay.utils.EventType;

@:allow(clay.input.Mouse)
class MouseEvent implements IEvent {

	static public inline var MOUSE_UP:EventType<MouseEvent>;
	static public inline var MOUSE_DOWN:EventType<MouseEvent>;
	static public inline var MOUSE_MOVE:EventType<MouseEvent>;
	static public inline var MOUSE_WHEEL:EventType<MouseEvent>;

	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;
	public var wheel(default, null):Int = 0;

	public var button(default, null):MouseButton = MouseButton.NONE;
	public var state(default, null):EventType<MouseEvent> = MouseEvent.MOUSE_UP;

	public function new() {}

	public inline function set(x:Int, y:Int, dx:Int, dy:Int, wheel:Int, state:EventType<MouseEvent>, button:MouseButton) {
		this.x = x;
		this.y = y;
		this.dx = dx;
		this.dy = dy;
		this.wheel = wheel;
		this.state = state;
		this.button = button;
	}

}

enum abstract MouseButton(Int) from Int to Int {
    var NONE = -1;
    var LEFT = 0;
    var RIGHT = 1;
    var MIDDLE = 2;
    var EXTRA1 = 3;
    var EXTRA2 = 4;
    var EXTRA3 = 5;
    var EXTRA4 = 6;
}
