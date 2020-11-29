package clay.events;

import clay.utils.EventType;

@:allow(clay.input.Pen)
class PenEvent implements IEvent{

	static public inline var PEN_UP:EventType<PenEvent>;
	static public inline var PEN_DOWN:EventType<PenEvent>;
	static public inline var PEN_MOVE:EventType<PenEvent>;

	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	public var dx(default, null):Int = 0;
	public var dy(default, null):Int = 0;

	public var pressure(default, null):Float = 0;
	public var state(default, null):EventType<PenEvent> = PenEvent.PEN_UP;

	public function new() {}

	inline function set(x:Int, y:Int, dx:Int, dy:Int, state:EventType<PenEvent>, pressure:Float) {
		this.x = x;
		this.y = y;
		this.dx = dx;
		this.dy = dy;
		this.state = state;
		this.pressure = pressure;
	}

}
