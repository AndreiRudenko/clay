package clay;

import clay.system.App;
import clay.utils.Log.*;

class Clay {

	@:allow(clay.system.App)
	public static var app(default, null):clay.system.App;
	public static var debug(get, never):clay.system.Debug;

	public static var screen(get, never):clay.system.Screen;
	public static var renderer(get, never):clay.render.Renderer;
	public static var camera(get, never):clay.render.Camera;
	public static var cameras(get, never):clay.render.CameraManager;
	public static var layers(get, never):clay.render.Layers;
	public static var draw(get, never):clay.utils.Draw;

	public static var input(get, never):clay.input.InputManager;
	public static var resources(get, never):clay.resources.ResourceManager;

	public static var audio(get, never):clay.audio.Audio;
	public static var timer(get, never):clay.utils.Timer.TimerManager;
	public static var events(get, never):clay.events.Events;
	public static var tween(get, never):clay.tween.TweenManager;
	
	public static var random(get, never):clay.utils.Random;

	public static var dt(get, never):Float;
	public static var time(get, never):Float;
	public static var timescale(get, set):Float;

	// public static var io(default, null):clay.IO;

	static var inited:Bool = false;


	public static function init(options:ClayOptions, onReady:()->Void) {
		assert(!inited, "app already inited");
		inited = true;
		new clay.system.App(options, onReady);
	}

	public static inline function on<T>(event:clay.events.EventType<T>, handler:T->Void, priority:Int = 0) {
		app.emitter.on(event, handler, priority);
	}

	public static inline function off<T>(event:clay.events.EventType<T>, handler:T->Void):Bool {
		return app.emitter.off(event, handler);
	}

	public static inline function next(func:()->Void) app.next(func);
	public static inline function defer(func:()->Void) app.defer(func);

	static inline function get_debug() return app.debug;
	
	static inline function get_screen() return app.screen;
	static inline function get_renderer() return app.renderer;
	static inline function get_camera() return app.renderer.camera;
	static inline function get_cameras() return app.renderer.cameras;
	static inline function get_layers() return app.renderer.layers;
	static inline function get_draw() return app.draw;

	static inline function get_input() return app.input;
	static inline function get_resources() return app.resources;

	static inline function get_audio() return app.audio;
	static inline function get_timer() return app.timer;
	static inline function get_events() return app.events;
	static inline function get_tween() return app.tween;

	static inline function get_random() return app.random;
	
	static inline function get_dt() return app.dt;
	static inline function get_time() return app.time;
	static inline function get_timescale() return app.timescale;
	static inline function set_timescale(v) return app.timescale = v;
	
}
