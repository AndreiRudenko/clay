package clay.system;


import kha.System;
import kha.Scheduler;
import kha.Framebuffer;
import kha.WindowOptions;
import kha.WindowOptions.WindowFeatures;

import clay.system.InputManager;
import clay.system.ResourceManager;
import clay.system.Audio;
import clay.system.Debug;
import clay.system.Screen;
import clay.system.TimerManager;
import clay.tween.TweenManager;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;

import clay.render.Renderer;
import clay.render.Camera;
// import clay.render.Draw;
import clay.events.Emitter;
import clay.events.Events;
import clay.events.AppEvent;
import clay.events.RenderEvent;

import clay.utils.Random;
import clay.utils.Mathf;
import clay.utils.Log.*;


@:keep
class App {


	public var renderer     (default, null):Renderer;
	// public var draw         (default, null):Draw;
	public var audio        (default, null):Audio;
	public var debug        (default, null):Debug;

	public var emitter	    (default, null):Emitter;
	public var events	    (default, null):Events;

	public var screen	    (default, null):Screen;
	public var input	    (default, null):InputManager;
	public var resources	(default, null):ResourceManager;

	public var timer 	    (default, null):TimerManager;
	public var random 	    (default, null):Random;
	public var tween 	    (default, null):TweenManager;

	public var in_focus     (default, null):Bool = true;

	// average delta time
	public var dt 	        (default, null):Float = 0;
	// frame time
	public var frame_delta  (default, null):Float = 0;

	public var time 	    (default, null):Float = 0;
	public var timescale 	(default, set):Float = 1;

	public var fixed_frame_time	(default, set):Float = 1/60;

	var frame_max_delta:Float = 0.25;
	var delta_smoothing:Int = 10;
	var delta_index:Int = 0;
	var deltas:Array<Float>;

	var fixed_overflow:Float = 0;
	var last_time:Float = 0;

	var options:ClayOptions;

	var inited:Bool = false;

	var next_queue:Array<Void->Void> = [];
	var defer_queue:Array<Void->Void> = [];

	var _app_event:AppEvent;
	var _render_event:RenderEvent;


	public function new(_options:ClayOptions, _onready:Void->Void) {

		_debug('creating app');

		var _kha_opt = parse_options(_options);

		System.start(
			_kha_opt, 
			function(_) {
				ready(_onready);
			}
		);
		
	}

	public function shutdown() {

		destroy();
		System.stop();

	}

		/** Call a function at the start of the next frame,
		useful for async calls in a sync context, allowing the sync function to return safely before the onload is fired. */
	public inline function next(func:Void->Void) {

		if(func != null) next_queue.push(func);

	}

		/** Call a function at the end of the current frame */
	public inline function defer(func:Void->Void) {

		if(func != null) defer_queue.push(func);

	}

	function ready(_onready:Void->Void) {
		
		_debug('ready');

		clay.Clay.app = this;

		_app_event = new AppEvent();
		_render_event = new RenderEvent();

		emitter = new Emitter();
		events = new Events();
		
		tween = new TweenManager();
		random = new Random(options.random_seed);
		timer = new TimerManager();

		renderer = new Renderer(options.renderer);
		// draw = new Draw();
		screen = new Screen(options.antialiasing);
		audio = new Audio();
		
		input = new InputManager(this);
		resources = new ResourceManager();

		debug = new Debug(this);


		if(options.no_default_font != true) {
			
			Clay.resources.load_all(
				[
				'assets/Montserrat-Regular.ttf',
				'assets/Montserrat-Bold.ttf',
				], 
				function() {

					init();
					_debug('onready');
					_onready();

				}
			);

		} else {

			init();
			_debug('onready');
			_onready();
		}

	}

	function init() {

		_debug('init');

		time = kha.System.time;
		last_time = time;

		deltas = [];
		for (i in 0...delta_smoothing) {
			deltas.push(1/60);
		}

		input.init();
		
		connect_events();

		screen.init();
		renderer.init();
		inited = true;
		
		debug.init();

		debug.start(DebugTag.process);
		debug.start(DebugTag.update);
		debug.start(DebugTag.render);

	}

	function destroy() {

		disconnect_events();
		
		debug.destroy();
		events.destroy();
		input.destroy();
		renderer.destroy();
		// audio.destroy();
		timer.destroy();
		// signals.destroy();

		debug = null;
		screen = null;
		events = null;
		input = null;
		renderer = null;
		audio = null;
		timer = null;
		tween = null;
		// signals = null;
		next_queue = null;
		defer_queue = null;

	}

	function parse_options(_options:ClayOptions):SystemOptions {

		_debug('parsing options:$_options');

		options = {};
		options.title = def(_options.title, 'clay game');
		options.width = def(_options.width, 800);
		options.height = def(_options.height, 600);
		options.vsync = def(_options.vsync, false);
		options.antialiasing = def(_options.antialiasing, 1);
		options.window = def(_options.window, {});
		options.renderer = def(_options.renderer, {});

		var features:WindowFeatures = None;
		if (options.window.resizable) features |= WindowFeatures.FeatureResizable;
		if (options.window.maximizable) features |= WindowFeatures.FeatureMaximizable;
		if (options.window.minimizable) features |= WindowFeatures.FeatureMinimizable;
		if (options.window.borderless) features |= WindowFeatures.FeatureBorderless;
		if (options.window.ontop) features |= WindowFeatures.FeatureOnTop;

		var _kha_opt: SystemOptions = {
			title: options.title,
			width: options.width,
			height: options.height,
			window: {
				x: options.window.x,
				y: options.window.y,
				mode: options.window.mode,
				windowFeatures: features
			},
			framebuffer: {
				samplesPerPixel: options.antialiasing,
				verticalSync: options.vsync
			}
		};

		return _kha_opt;

	}

	function connect_events() {

		System.notifyOnFrames(render);
		System.notifyOnApplicationState(foreground, resume, pause, background, null);

		input.enable();

	}

	function disconnect_events() {

		System.removeFramesListener(render);

		input.disable();
		
	}

	var render_counter:Int = 0;
	var step_counter:Int = 0;

	function step() {

		if(!in_focus) {
			return;
		}

		tickstart();

		time = kha.System.time;
		frame_delta = time - last_time;

		if(frame_delta > frame_max_delta) {
			frame_delta = 1/60;
		}

		// Smooth out the delta over the previous X frames
		deltas[delta_index] = frame_delta;
		
		delta_index++;

		if(delta_index > delta_smoothing) {
			delta_index = 0;
		}

		dt = 0;

		for (i in 0...delta_smoothing) {
			dt += deltas[i];
		}

		dt /= delta_smoothing;

		tick();

		fixed_overflow += frame_delta;
		while(fixed_overflow >= fixed_frame_time) {
			emitter.emit(AppEvent.FIXEDUPDATE, fixed_frame_time);
			fixed_overflow -= fixed_frame_time;
		}

		emitter.emit(AppEvent.UPDATE, dt);
		
		renderer.update(dt);

		last_time = time;

		tickend();

	}

	inline function tickstart() {

		_verboser('ontickstart');
		
		cycle_next_queue();

		emitter.emit(AppEvent.TICKSTART, _app_event);
		
	}

	inline function tick() {

		_verboser('tick');
		
		timer.update(dt);
		events.process();
		tween.step(dt);
		// draw.update();

	}

	inline function tickend() {

		_verboser('ontickend');

		emitter.emit(AppEvent.TICKEND, _app_event);
		input.reset();

		cycle_defer_queue();

	}

	// render
	function render(f:Array<Framebuffer>) {

		_verboser('render');

		debug.start(DebugTag.process);

		debug.start(DebugTag.update);
		step(); // todo: move to another place?
		debug.end(DebugTag.update);

		debug.start(DebugTag.render);

		_render_event.set(f[0]);

		emitter.emit(RenderEvent.PRERENDER, _render_event);

		emitter.emit(RenderEvent.RENDER, _render_event);
		renderer.process(f[0]);
		
		emitter.emit(RenderEvent.POSTRENDER, _render_event);

		debug.end(DebugTag.render);

		debug.end(DebugTag.process);

	}

	function foreground() {

		emitter.emit(AppEvent.FOREGROUND, _app_event);

		in_focus = true;

	}

	function background() {

		emitter.emit(AppEvent.BACKGROUND, _app_event);

		in_focus = false;

	}

	function pause() {

		emitter.emit(AppEvent.PAUSE, _app_event);

	}

	function resume() {

		emitter.emit(AppEvent.RESUME, _app_event);

	}

	inline function cycle_next_queue() {

		var count = next_queue.length;
		var i = 0;
		while(i < count) {
			(next_queue.shift())();
			++i;
		}

	}

	inline function cycle_defer_queue() {

		var count = defer_queue.length;
		var i = 0;
		while(i < count) {
			(defer_queue.shift())();
			++i;
		}

	}

	function set_timescale(v:Float):Float {

		v = Mathf.clamp_bottom(v, 0);

		timescale = v;

		emitter.emit(AppEvent.TIMESCALE, v);

		return v;
		
	}

	function set_fixed_frame_time(v:Float):Float {

		return fixed_frame_time = Mathf.clamp_bottom(v, 0);
		
	}

}

@:noCompletion
@:allow(clay.system.App)
class DebugTag {
    static var process      = 'core.process';
    static var update       = 'core.update';
    static var tick         = 'core.tick';
    static var render       = 'core.render';
    static var debug        = 'core.debug';
    static var updates      = 'core.updates';
    static var events       = 'core.events';
    static var audio        = 'core.audio';
    static var input        = 'core.input';
    static var timer        = 'core.timer';
    static var scene        = 'core.scene';
}

typedef ClayOptions = {
    ?title:String,
    ?width:Int,
    ?height:Int,
    ?antialiasing:Int,
    ?vsync:Bool,
    ?random_seed:Int,
    ?renderer:RendererOptions,
    ?window:WindowOptions,
    ?no_default_font:Bool,
    ?no_default_world:Bool,

};

typedef WindowOptions = {
    ?x:Int,
    ?y:Int,
    ?resizable:Bool,
    ?minimizable:Bool,
    ?maximizable:Bool,
    ?borderless:Bool,
    ?ontop:Bool,
    ?mode:WindowMode,
};