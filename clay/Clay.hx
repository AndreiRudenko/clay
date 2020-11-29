package clay;

import clay.App;

class Clay {

	@:allow(clay.App)
	public static var app(default, null):App;

	public static var display(get, never):clay.Display;
	public static var window(get, never):clay.Window;
	public static var graphics(get, never):clay.Graphics;
	public static var input(get, never):clay.Input;
	public static var resources(get, never):clay.Resources;
	public static var audio(get, never):clay.Audio;

	// TODO: remove timer and random
	// public static var timer(get, never):clay.utils.Timer.TimerManager;
	public static var random(get, never):clay.utils.Random;

	public static var dt(get, never):Float;
	public static var time(get, never):Float;
	public static var timescale(get, set):Float;

	static var inited:Bool = false;


	public static function init(options:ClayOptions, onReady:()->Void) {
		clay.utils.Log.assert(!inited, "app is already inited");
		inited = true;
		new App(options, onReady);
	}

	public static inline function on<T>(event:clay.utils.EventType<T>, handler:T->Void, priority:Int = 0) {
		app.emitter.on(event, handler, priority);
	}

	public static inline function off<T>(event:clay.utils.EventType<T>, handler:T->Void):Bool {
		return app.emitter.off(event, handler);
	}

	public static inline function next(func:()->Void) app.next(func);
	public static inline function defer(func:()->Void) app.defer(func);

	static inline function get_display() return Display.primary;
	static inline function get_window() return app.window;
	static inline function get_graphics() return app.graphics;
	static inline function get_input() return app.input;
	static inline function get_resources() return app.resources;
	static inline function get_audio() return app.audio;
	// static inline function get_timer() return app.timer;
	static inline function get_random() return app.random;
	
	static inline function get_dt() return app.dt;
	static inline function get_time() return app.time;
	static inline function get_timescale() return app.timescale;
	static inline function set_timescale(v) return app.timescale = v;
	
}
