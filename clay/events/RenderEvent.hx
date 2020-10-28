package clay.events;

import clay.Graphics;
import clay.utils.EventType;
import kha.Framebuffer;

@:allow(clay.App)
class RenderEvent implements IEvent {

	static public inline var PRERENDER:EventType<RenderEvent>;
	static public inline var POSTRENDER:EventType<RenderEvent>;
	static public inline var RENDER:EventType<RenderEvent>;

	public var g(default, null):Graphics;
	public var g2(default, null):kha.graphics2.Graphics;
	public var g4(default, null):kha.graphics4.Graphics;

	public function new() {}

	inline function set(g:Graphics, g2:kha.graphics2.Graphics, g4:kha.graphics4.Graphics) {
		this.g = g;
		this.g2 = g2;
		this.g4 = g4;
	}

}
