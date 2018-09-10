package clay;


import kha.System;
import kha.Scheduler;
import kha.Framebuffer;
import kha.WindowOptions;

import clay.math.Random;
import clay.types.AppEvent;
import clay.emitters.Emitter;
import clay.utils.Log.*;

import clay.components.Camera;
import clay.core.Inputs;
import clay.core.Resources;

import clay.core.TimerSystem;
import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;

import clay.tween.TweenManager;


@:keep
@:access(Clay)
@:access(clay.core.Worlds)
class Engine {


	public var renderer     (default, null):clay.render.Renderer;
	public var camera 	    (default, set):Camera;
	public var draw         (default, null):clay.render.Draw;
	public var audio        (default, null):clay.Audio;

	public var world 	    (default, set):World;
	public var worlds	    (default, null):clay.core.Worlds;

	public var screen	    (default, null):Screen;
	public var input	    (default, null):Inputs;
	public var resources	(default, null):Resources;
	public var emitter	    (default, null):Emitter<AppEvent>;
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

    public inline function on<T>(event:AppEvent, handler:T->Void) {

        emitter.on(event, handler);

    }

    // @:generic
    public inline function off<T>(event:AppEvent, handler:T->Void) {

        return emitter.off(event, handler);

    }

    // @:generic
    public inline function emit<T>(event:AppEvent, ?data:T) {

        return emitter.emit(event, data);

    }

	public function shutdown() {

		destroy();
		System.stop();

	}

	function ready(_onready:Void->Void) {
		
		_debug('ready');

		Clay.engine = this;

		motion = new TweenManager();
		random = new Random(options.random_seed);
		timer = new TimerSystem();

		renderer = new clay.render.Renderer(options.renderer_options);
		draw = new clay.render.Draw();
		screen = new Screen();
		// screen.antialiasing = options.antialiasing;
		audio = new clay.Audio();
		
		emitter = new Emitter<AppEvent>();
		input = new Inputs(this);
		resources = new Resources();

		worlds = new clay.core.Worlds();

		Clay.motion = motion;
		Clay.random = random;
		Clay.timer = timer;
		Clay.renderer = renderer;
		Clay.draw = draw;
		Clay.audio = audio;
		Clay.worlds = worlds;
		Clay.screen = screen;
		Clay.input = input;
		Clay.resources = resources;

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

	}

	function init() {

		_debug('init');

		time = kha.System.time;
		frame_start_prev = time;

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
		emitter.destroy();
		input.destroy();
		renderer.destroy();
		// audio.destroy();
		timer.destroy();

		screen = null;
		world = null;
		worlds = null;
		emitter = null;
		input = null;
		audio = null;
		renderer = null;
		motion = null;

	}

	@:allow(clay.core.Worlds)
	function setup_world(w:World) {

		w.processors.add(new clay.processors.TransformProcessor(), -999);
		w.processors.add(new clay.processors.RenderProcessor(), 999);
		
	}

	function parse_options(_options:ClayOptions):SystemOptions {

		_debug('parsing options:$_options');

		options = {};
		options.title = def(_options.title, 'clay game');
		options.width = def(_options.width, 800);
		options.height = def(_options.height, 600);
		options.window_mode = def(_options.window_mode, clay.types.WindowMode.Window);
		options.vsync = def(_options.vsync, true);
		options.antialiasing = def(_options.antialiasing, 1);
		options.resizable = def(_options.resizable, false);
		options.renderer_options = def(_options.renderer_options, {});

		var _kha_opt:SystemOptions = {};

		var features: Int = 0;
		if (options.resizable) features |= WindowOptions.FeatureResizable;
		// if (options.maximizable) features |= WindowOptions.FeatureMaximizable;
		// if (options.minimizable) features |= WindowOptions.FeatureMinimizable;
		var _kha_opt: SystemOptions = {
			title: options.title,
			width: options.width,
			height: options.height,
			window: {
				mode: options.window_mode,
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
		tick_task_id = Scheduler.addFrameTask(internal_tick, 0);

		input.enable();

	}

	function disconnect_events() {

		Scheduler.removeFrameTask(tick_task_id);
		System.removeFramesListener(render);

		input.disable();
		
	}

	inline function onprerender() {

		_verboser('onprerender');

		emitter.emit(AppEvent.prerender);
		worlds.prerender();
		draw.prerender();

	}

	inline function onpostrender() {

		_verboser('onpostrender');

		emitter.emit(AppEvent.postrender);
		worlds.postrender();
		draw.postrender();

	}

	inline function ontickstart() {

		_verboser('ontickstart');

		emitter.emit(AppEvent.tickstart);
		worlds.tickstart();
		
	}

	inline function ontickend() {

		_verboser('ontickend');

		emitter.emit(AppEvent.tickend);
		worlds.tickend();
		input.reset();

	}

	inline function tick() {

		_verboser('tick');
		
		timer.process(frame_start);
		motion.tick();
		
	}

	function update(dt:Float) {

		_verboser('update dt:${dt}');

		timer.update(dt);
		motion.step(dt);
		emitter.emit(AppEvent.update, dt);
		worlds.update(dt);
		renderer.update(dt);

	}

	function internal_tick() {

		_verboser('internal_tick');

		ontickstart();

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

		ontickend();

	}

	function render(f:Array<Framebuffer>) {

		_verboser('render');

		onprerender();

		emitter.emit(AppEvent.render);
		worlds.render();
		renderer.process(f[0]);
		
		onpostrender();

	}

	// key
	function onkeydown(e:KeyEvent) {

		emitter.emit(AppEvent.keydown, e);
		worlds.keydown(e);
		
	}

	function onkeyup(e:KeyEvent) {

		emitter.emit(AppEvent.keyup, e);
		worlds.keyup(e);

	}

	// mouse
	function onmousedown(e:MouseEvent) {

		emitter.emit(AppEvent.mousedown, e);
		worlds.mousedown(e);

	}

	function onmouseup(e:MouseEvent) {

		emitter.emit(AppEvent.mouseup, e);
		worlds.mouseup(e);

	}

	function onmousemove(e:MouseEvent) {

		emitter.emit(AppEvent.mousemove, e);
		worlds.mousemove(e);

	}

	function onmousewheel(e:MouseEvent) {

		emitter.emit(AppEvent.mousewheel, e);
		worlds.mousewheel(e);

	}

	// gamepad
	function ongamepadadd(e:GamepadEvent) {

		emitter.emit(AppEvent.gamepadconnect, e);
		worlds.gamepadadd(e);

	}

	function ongamepadremove(e:GamepadEvent) {

		emitter.emit(AppEvent.gamepaddisconnect, e);
		worlds.gamepadremove(e);

	}

	function ongamepaddown(e:GamepadEvent) {

		emitter.emit(AppEvent.gamepaddown, e);
		worlds.gamepaddown(e);

	}

	function ongamepadup(e:GamepadEvent) {

		emitter.emit(AppEvent.gamepadup, e);
		worlds.gamepadup(e);

	}

	function ongamepadaxis(e:GamepadEvent) {

		emitter.emit(AppEvent.gamepadaxis, e);
		worlds.gamepadaxis(e);

	}

	// touch
	function ontouchdown(e:TouchEvent) {

		emitter.emit(AppEvent.touchdown, e);
		worlds.touchdown(e);

	}

	function ontouchup(e:TouchEvent) {

		emitter.emit(AppEvent.touchup, e);
		worlds.touchup(e);

	}

	function ontouchmove(e:TouchEvent) {

		emitter.emit(AppEvent.touchmove, e);
		worlds.touchmove(e);

	}

	// pen
	function onpendown(e:PenEvent) {

		emitter.emit(AppEvent.pendown, e);
		worlds.pendown(e);

	}

	function onpenup(e:PenEvent) {

		emitter.emit(AppEvent.penup, e);
		worlds.penup(e);

	}

	function onpenmove(e:PenEvent) {

		emitter.emit(AppEvent.penmove, e);
		worlds.penmove(e);

	}

	function set_timescale(v:Float):Float {

		if(v < 0) {
			v = 0;
		}
		timescale = v;

		emitter.emit(AppEvent.timescale, v);
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

	function set_world(v:World):World {

		world = v;
		Clay.world = world;

		return world;
		
	}

	function set_camera(v:Camera):Camera {

		camera = v;
		Clay.camera = camera;

		return camera;
		
	}


}
