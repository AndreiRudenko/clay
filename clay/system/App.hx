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
import clay.render.Draw;
import clay.events.Emitter;
import clay.events.Events;
import clay.events.AppEvent;
import clay.events.RenderEvent;

import clay.utils.Random;
import clay.utils.Mathf;
import clay.utils.Log.*;


@:keep
class App {


	public var renderer(default, null):Renderer;
	public var draw(default, null):Draw;
	public var audio(default, null):Audio;
	public var debug(default, null):Debug;

	public var emitter(default, null):Emitter;
	public var events(default, null):Events;

	public var screen(default, null):Screen;
	public var input(default, null):InputManager;
	public var resources(default, null):ResourceManager;

	public var timer(default, null):TimerManager;
	public var random(default, null):Random;
	public var tween(default, null):TweenManager;

	public var inFocus(default, null):Bool = true;

	// average delta time
	public var dt(default, null):Float = 0;
	// frame time
	public var frameDelta(default, null):Float = 0;

	public var time(default, null):Float = 0;
	public var timescale(default, set):Float = 1;

	public var fixedFrameTime(default, set):Float = 1/60;

	var frameMaxDelta:Float = 0.25;
	var deltaSmoothing:Int = 10;
	var deltaIndex:Int = 0;
	var deltas:Array<Float>;

	var fixedOverflow:Float = 0;
	var lastTime:Float = 0;

	var options:ClayOptions;

	var inited:Bool = false;

	var nextQueue:Array<()->Void> = [];
	var deferQueue:Array<()->Void> = [];

	var _appEvent:AppEvent;
	var _renderEvent:RenderEvent;


	public function new(_options:ClayOptions, _onready:()->Void) {

		_debug("creating app");

		var _khaOpt = parseOptions(_options);

		System.start(
			_khaOpt, 
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
	public inline function next(func:()->Void) {

		if(func != null) nextQueue.push(func);

	}

		/** Call a function at the end of the current frame */
	public inline function defer(func:()->Void) {

		if(func != null) deferQueue.push(func);

	}

	function ready(_onready:()->Void) {
		
		_debug("ready");

		clay.Clay.app = this;

		_appEvent = new AppEvent();
		_renderEvent = new RenderEvent();

		emitter = new Emitter();
		events = new Events();
		
		tween = new TweenManager();
		random = new Random(options.randomSeed);
		timer = new TimerManager();

		renderer = new Renderer(options.renderer);
		draw = new Draw();
		screen = new Screen(options.antialiasing);
		audio = new Audio();
		
		input = new InputManager(this);
		resources = new ResourceManager();

		debug = new Debug(this);


		if(options.noDefaultFont != true) {
			
			Clay.resources.loadAll(
				[
				"assets/Muli-Regular.ttf",
				"assets/Muli-Bold.ttf"
				], 
				function() {

					init();
					_debug("onready");
					_onready();

				}
			);

		} else {

			init();
			_debug("onready");
			_onready();
		}

	}

	function init() {

		_debug("init");

		time = kha.System.time;
		lastTime = time;

		deltas = [];
		for (i in 0...deltaSmoothing) {
			deltas.push(1/60);
		}

		input.init();
		
		connectEvents();

		screen.init();
		renderer.init();
		inited = true;
		
		debug.init();

		debug.start(DebugTag.process);
		debug.start(DebugTag.update);
		debug.start(DebugTag.render);

	}

	function destroy() {

		disconnectEvents();
		
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
		nextQueue = null;
		deferQueue = null;

	}

	function parseOptions(_options:ClayOptions):SystemOptions {

		_debug("parsing options: " + _options);

		options = {};
		options.title = def(_options.title, "clay game");
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

		var _khaOpt: SystemOptions = {
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

		return _khaOpt;

	}

	function connectEvents() {

		System.notifyOnFrames(render);
		System.notifyOnApplicationState(foreground, resume, pause, background, null);

		input.enable();

	}

	function disconnectEvents() {

		System.removeFramesListener(render);

		input.disable();
		
	}

	var renderCounter:Int = 0;
	var stepCounter:Int = 0;

	function step() {

		if(!inFocus) {
			return;
		}

		tickstart();

		time = kha.System.time;
		frameDelta = time - lastTime;

		if(frameDelta > frameMaxDelta) {
			frameDelta = 1/60;
		}

		// Smooth out the delta over the previous X frames
		deltas[deltaIndex] = frameDelta;
		
		deltaIndex++;

		if(deltaIndex > deltaSmoothing) {
			deltaIndex = 0;
		}

		dt = 0;

		for (i in 0...deltaSmoothing) {
			dt += deltas[i];
		}

		dt /= deltaSmoothing;

		tick();

		fixedOverflow += frameDelta;
		while(fixedOverflow >= fixedFrameTime) {
			emitter.emit(AppEvent.FIXEDUPDATE, fixedFrameTime);
			fixedOverflow -= fixedFrameTime;
		}

		emitter.emit(AppEvent.UPDATE, dt);
		
		renderer.update(dt);

		lastTime = time;

		tickend();

	}

	inline function tickstart() {

		_verboser("ontickstart");
		
		cycleNextQueue();

		emitter.emit(AppEvent.TICKSTART, _appEvent);
		
	}

	inline function tick() {

		_verboser("tick");
		
		timer.update(dt);
		events.process();
		tween.step(dt);
		draw.update();

	}

	inline function tickend() {

		_verboser("ontickend");

		emitter.emit(AppEvent.TICKEND, _appEvent);
		input.reset();

		cycleDeferQueue();

	}

	// render
	function render(f:Array<Framebuffer>) {

		_verboser("render");

		debug.start(DebugTag.process);

		debug.start(DebugTag.update);
		step(); // todo: move to another place?
		debug.end(DebugTag.update);

		debug.start(DebugTag.render);

		_renderEvent.set(f[0]);

		emitter.emit(RenderEvent.PRERENDER, _renderEvent);

		emitter.emit(RenderEvent.RENDER, _renderEvent);
		renderer.process(f[0]);
		
		emitter.emit(RenderEvent.POSTRENDER, _renderEvent);

		debug.end(DebugTag.render);

		debug.end(DebugTag.process);

	}

	function foreground() {

		emitter.emit(AppEvent.FOREGROUND, _appEvent);

		inFocus = true;

	}

	function background() {

		emitter.emit(AppEvent.BACKGROUND, _appEvent);

		inFocus = false;

	}

	function pause() {

		emitter.emit(AppEvent.PAUSE, _appEvent);

	}

	function resume() {

		emitter.emit(AppEvent.RESUME, _appEvent);

	}

	inline function cycleNextQueue() {

		var count = nextQueue.length;
		var i = 0;
		while(i < count) {
			(nextQueue.shift())();
			++i;
		}

	}

	inline function cycleDeferQueue() {

		var count = deferQueue.length;
		var i = 0;
		while(i < count) {
			(deferQueue.shift())();
			++i;
		}

	}

	function set_timescale(v:Float):Float {

		v = Mathf.clampBottom(v, 0);

		timescale = v;

		emitter.emit(AppEvent.TIMESCALE, v);

		return v;
		
	}

	function set_fixedFrameTime(v:Float):Float {

		return fixedFrameTime = Mathf.clampBottom(v, 0);
		
	}

}

@:noCompletion
@:allow(clay.system.App)
class DebugTag {
	static var process      = "core.process";
	static var update       = "core.update";
	static var tick         = "core.tick";
	static var render       = "core.render";
	static var debug        = "core.debug";
	static var updates      = "core.updates";
	static var events       = "core.events";
	static var audio        = "core.audio";
	static var input        = "core.input";
	static var timer        = "core.timer";
	static var scene        = "core.scene";
}

typedef ClayOptions = {
	?title:String,
	?width:Int,
	?height:Int,
	?antialiasing:Int,
	?vsync:Bool,
	?randomSeed:Int,
	?renderer:RendererOptions,
	?window:WindowOptions,
	?noDefaultFont:Bool,
	?noDefaultWorld:Bool,

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