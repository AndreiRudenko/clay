package clay;


import kha.System;
import kha.Scheduler;
import kha.Framebuffer;
import kha.WindowOptions;

import clay.math.Random;

import clay.components.event.Events;
import clay.components.misc.Camera;

import clay.core.Inputs;
import clay.core.Resources;
import clay.core.EngineSignals;
import clay.core.Audio;
import clay.core.Screen;
import clay.core.TimerSystem;
import clay.core.ecs.Worlds;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;

import clay.render.Renderer;
import clay.render.Draw;

import clay.tween.TweenManager;

import clay.utils.Log.*;


@:keep
class Engine {


	public var renderer     (default, null):Renderer;
	public var camera 	    (default, set):Camera;
	public var draw         (default, null):Draw;
	public var audio        (default, null):Audio;

	@:allow(Clay)
	public var world 	    (default, null):World;
	public var worlds	    (default, null):Worlds;

	public var screen	    (default, null):Screen;
	public var input	    (default, null):Inputs;
	public var resources	(default, null):Resources;
	public var signals	    (default, null):EngineSignals;
	public var events	    (default, null):Events;
	public var timer 	    (default, null):TimerSystem;
	public var random 	    (default, null):Random;
	public var motion 	    (default, null):TweenManager;

	public var dt 	        (get, never):Float;
	public var time 	    (default, null):Float;
	public var timescale 	(default, set):Float = 1;

	public var fixed_timestep:Bool = true;
	public var fixed_frame_time	(default, set):Float = 1/60;
	public var frame_max_delta 	(default, set):Float = 0.25;

	// Timing information.
	public var frame_delta (default, null):Float = 0;
	
	var fixed_overflow:Float = 0;
	var frame_start:Float = 0;
	var frame_start_prev:Float = 0;
	var fixed_time_scaled:Float = 0;
	var sim_time:Float = 0;
	var sim_delta:Float = 0;

	var options:ClayOptions;

	var inited:Bool = false;
	var tick_task_id:Int;

	var next_queue:Array<Void->Void> = [];
	var defer_queue:Array<Void->Void> = [];


	public function new(_options:ClayOptions, _onready:Void->Void) {

		_debug('creating engine');

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

		Clay.engine = this;

		signals = new EngineSignals();
		motion = new TweenManager();
		random = new Random(options.random_seed);
		timer = new TimerSystem();

		renderer = new Renderer(options.renderer);
		draw = new Draw();
		screen = new Screen(options.antialiasing);
		audio = new Audio();
		
		events = new Events();
		input = new Inputs(this);
		resources = new Resources();

		worlds = new Worlds();

		init();

		_debug('onready');
		_onready();

	}

	function init() {

		_debug('init');

		time = kha.System.time;
		frame_start_prev = time;

		input.init();
		
		connect_events();
		screen.init();
		renderer.init();
		draw.init();
		worlds.init();
		inited = true;

		#if !no_default_world
			world = worlds.create('default_world', { capacity: 32768, component_types: 64 }, true);
		#end

		camera = renderer.cameras.create('default_camera');

	}

	function destroy() {

		disconnect_events();
		worlds.destroy_manager();
		events.destroy();
		input.destroy();
		renderer.destroy();
		// audio.destroy();
		timer.destroy();
		signals.destroy();

		screen = null;
		world = null;
		worlds = null;
		input = null;
		audio = null;
		renderer = null;
		motion = null;
		signals = null;
		next_queue = null;
		defer_queue = null;

	}

	function parse_options(_options:ClayOptions):SystemOptions {

		_debug('parsing options:$_options');

		options = {};
		options.title = def(_options.title, 'clay game');
		options.width = def(_options.width, 800);
		options.height = def(_options.height, 600);
		options.vsync = def(_options.vsync, true);
		options.antialiasing = def(_options.antialiasing, 1);
		options.window = def(_options.window, {});
		options.window.name = def(_options.window.name, options.title);
		options.renderer = def(_options.renderer, {});

		var features: Int = 0;
		if (options.window.resizable) features |= WindowOptions.FeatureResizable;
		if (options.window.maximizable) features |= WindowOptions.FeatureMaximizable;
		if (options.window.minimizable) features |= WindowOptions.FeatureMinimizable;
		if (options.window.borderless) features |= WindowOptions.FeatureBorderless;
		if (options.window.ontop) features |= WindowOptions.FeatureOnTop;

		var _kha_opt: SystemOptions = {
			title: options.title,
			width: options.width,
			height: options.height,
			window: {
				// name: options.window.name, // todo: ?
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

		tick_task_id = Scheduler.addFrameTask(internal_tick, 0);

		input.enable();

	}

	function disconnect_events() {

		Scheduler.removeFrameTask(tick_task_id);
		System.removeFramesListener(render);

		input.disable();
		
	}

	inline function prerender() {

		_verboser('onprerender');

		signals.prerender.emit();
		worlds.prerender();
		draw.prerender();

	}

	inline function postrender() {

		_verboser('onpostrender');

		signals.postrender.emit();
		worlds.postrender();
		draw.postrender();

	}

	inline function tickstart() {

		_verboser('ontickstart');
		
		cycle_next_queue();

		signals.tickstart.emit();
		worlds.tickstart();
		
	}

	inline function tickend() {

		_verboser('ontickend');

		signals.tickend.emit();
		worlds.tickend();
		input.reset();

		cycle_defer_queue();

	}

	inline function tick() {

		_verboser('tick');
		
		timer.process(frame_start);
		motion.tick();
		
	}

	function update(dt:Float) {

		_verboser('update dt:${dt}');

		events.process();
		timer.update(dt);
		motion.step(dt);
		signals.update.emit(dt);
		worlds.update(dt);
		renderer.update(dt);

	}

	function internal_tick() {

		_verboser('internal_tick');

		tickstart();

		time = kha.System.time;

		frame_start = time;
		frame_delta = frame_start - frame_start_prev;
		frame_start_prev = frame_start;

		sim_delta = frame_delta * timescale;
		if(sim_delta > frame_max_delta) {
			sim_delta = frame_max_delta;
		}

		tick();

		if(fixed_timestep) {
			fixed_overflow += sim_delta;
			fixed_time_scaled = fixed_frame_time * timescale;
			while(fixed_overflow >= fixed_frame_time) {
				update(fixed_time_scaled);
				sim_time += fixed_time_scaled;
				fixed_overflow -= fixed_time_scaled;
			}
		} else {
			update(sim_delta);
			sim_time += sim_delta;
		}

		tickend();

	}

	function render(f:Array<Framebuffer>) {

		_verboser('render');

		prerender();

		signals.render.emit();
		worlds.render();
		renderer.process(f[0]);
		
		postrender();

	}

	// key
	function keydown(e:KeyEvent) {

		signals.keydown.emit(e);
		worlds.keydown(e);
		
	}

	function keyup(e:KeyEvent) {

		signals.keyup.emit(e);
		worlds.keyup(e);

	}

	// mouse
	function mousedown(e:MouseEvent) {

		signals.mousedown.emit(e);
		worlds.mousedown(e);

	}

	function mouseup(e:MouseEvent) {

		signals.mouseup.emit(e);
		worlds.mouseup(e);

	}

	function mousemove(e:MouseEvent) {

		signals.mousemove.emit(e);
		worlds.mousemove(e);

	}

	function mousewheel(e:MouseEvent) {

		signals.mousewheel.emit(e);
		worlds.mousewheel(e);

	}

	// gamepad
	function gamepadadd(e:GamepadEvent) {

		signals.gamepadadd.emit(e);
		worlds.gamepadadd(e);

	}

	function gamepadremove(e:GamepadEvent) {

		signals.gamepadremove.emit(e);
		worlds.gamepadremove(e);

	}

	function gamepaddown(e:GamepadEvent) {

		signals.gamepaddown.emit(e);
		worlds.gamepaddown(e);

	}

	function gamepadup(e:GamepadEvent) {

		signals.gamepadup.emit(e);
		worlds.gamepadup(e);

	}

	function gamepadaxis(e:GamepadEvent) {

		signals.gamepadaxis.emit(e);
		worlds.gamepadaxis(e);

	}

	// touch
	function touchdown(e:TouchEvent) {

		signals.touchdown.emit(e);
		worlds.touchdown(e);

	}

	function touchup(e:TouchEvent) {

		signals.touchup.emit(e);
		worlds.touchup(e);

	}

	function touchmove(e:TouchEvent) {

		signals.touchmove.emit(e);
		worlds.touchmove(e);

	}

	// pen
	function pendown(e:PenEvent) {

		signals.pendown.emit(e);
		worlds.pendown(e);

	}

	function penup(e:PenEvent) {

		signals.penup.emit(e);
		worlds.penup(e);

	}

	function penmove(e:PenEvent) {

		signals.penmove.emit(e);
		worlds.penmove(e);

	}

	// bindings
	function inputdown(e:InputEvent) {

		signals.inputdown.emit(e);
		worlds.inputdown(e);

	}

	function inputup(e:InputEvent) {

		signals.inputup.emit(e);
		worlds.inputup(e);

	}

	function foreground() {

		signals.foreground.emit();
		worlds.foreground();

	}

	function background() {

		signals.background.emit();
		worlds.background();

	}

	function pause() {

		signals.pause.emit();
		worlds.pause();

	}

	function resume() {

		signals.resume.emit();
		worlds.resume();

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

		if(v < 0) {
			v = 0;
		}
		timescale = v;

		signals.timescale.emit(v);
		worlds.timescale(v);

		return v;
		
	}

	function set_fixed_frame_time(v:Float):Float {

		if(v > 0) {
			fixed_frame_time = v;
		}

		return fixed_frame_time;
		
	}

	function set_frame_max_delta(v:Float):Float {

		if(v > 0) {
			frame_max_delta = v;
		}

		return frame_max_delta;
		
	}

	inline function get_dt():Float {

		return frame_delta;
		
	}

	inline function get_time():Float {

		return System.time;
		
	}

	function set_camera(v:Camera):Camera {

		camera = v;

		return camera;
		
	}


}
