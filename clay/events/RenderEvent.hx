package clay.events;


import kha.Framebuffer;


@:allow(clay.Engine)
class RenderEvent implements IEvent {


	public static inline var PRERENDER:EventType<RenderEvent>;
	public static inline var POSTRENDER:EventType<RenderEvent>;
	public static inline var RENDER:EventType<RenderEvent>;


	public var framebuffer(default, null):Framebuffer;


	function new() {}

	inline function set(framebuffer) {

		this.framebuffer = framebuffer;
		
	}



}
