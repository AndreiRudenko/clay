package clay.events;


@:allow(clay.system.App)
class AppEvent implements IEvent {


	public static inline var TICKSTART:EventType<AppEvent>;
	public static inline var TICKEND:EventType<AppEvent>;

	public static inline var UPDATE:EventType<Float>;
	public static inline var FIXEDUPDATE:EventType<Float>;

	public static inline var TIMESCALE:EventType<Float>;

	public static inline var FOREGROUND:EventType<AppEvent>;
	public static inline var BACKGROUND:EventType<AppEvent>;
	public static inline var PAUSE:EventType<AppEvent>;
	public static inline var RESUME:EventType<AppEvent>;


	function new() {}


}
