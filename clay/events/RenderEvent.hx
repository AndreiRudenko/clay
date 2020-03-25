package clay.events;

import clay.render.RenderContext;

@:allow(clay.system.App)
class RenderEvent implements IEvent {

	public static inline var PRERENDER:EventType<RenderEvent>;
	public static inline var POSTRENDER:EventType<RenderEvent>;
	public static inline var RENDER:EventType<RenderEvent>;

	public var ctx(default, null):RenderContext;

	function new() {}

	inline function set(ctx) {
		this.ctx = ctx;
	}

}
