package clay.events;


@:allow(clay.input.Keyboard)
class KeyEvent implements IEvent {


	public static inline var KEY_UP:EventType<KeyEvent>;
	public static inline var KEY_DOWN:EventType<KeyEvent>;
	public static inline var TEXT_INPUT:EventType<String>;


    public var key(default, null):Int;
	public var state(default, null):EventType<KeyEvent> = KeyEvent.KEY_UP;


	function new() {}

	inline function set(key:Int, state:EventType<KeyEvent>) {
		
		this.key = key;
		this.state = state;

	}


}
