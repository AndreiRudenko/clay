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

	var _frameMaxDelta:Float = 0.25;
	var _deltaSmoothing:Int = 10;
	var _deltaIndex:Int = 0;
	var _deltas:Array<Float>;

	var _fixedOverflow:Float = 0;
	var _lastTime:Float = 0;

	var _options:ClayOptions;

	var _inited:Bool = false;

	var _nextQueue:Array<()->Void> = [];
	var _deferQueue:Array<()->Void> = [];

	var _appEvent:AppEvent;
	var _renderEvent:RenderEvent;


	public function new(options:ClayOptions, onReady:()->Void) {

		_debug("creating app");

		var _khaOpt = parseOptions(options);

		System.start(
			_khaOpt, 
			function(_) {
				ready(onReady);
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

		if(func != null) _nextQueue.push(func);

	}

		/** Call a function at the end of the current frame */
	public inline function defer(func:()->Void) {

		if(func != null) _deferQueue.push(func);

	}

	function ready(onReady:()->Void) {
		
		_debug("ready");

		clay.Clay.app = this;

		_appEvent = new AppEvent();
		_renderEvent = new RenderEvent();

		emitter = new Emitter();
		events = new Events();
		
		tween = new TweenManager();
		random = new Random(_options.randomSeed);
		timer = new TimerManager();

		renderer = new Renderer(_options.renderer);
		draw = new Draw();
		screen = new Screen(_options.antialiasing);
		audio = new Audio();
		
		input = new InputManager(this);
		resources = new ResourceManager();

		debug = new Debug(this);


		if(_options.noDefaultFont != true) {
			
			Clay.resources.loadAll(
				[
				"assets/Muli-Regular.ttf",
				"assets/Muli-Bold.ttf"
				], 
				function() {

					init();
					_debug("onReady");
					onReady();

				}
			);

		} else {

			init();
			_debug("onReady");
			onReady();
		}

	}

	function init() {

		_debug("init");

		time = kha.System.time;
		_lastTime = time;

		_deltas = [];
		for (i in 0..._deltaSmoothing) {
			_deltas.push(1/60);
		}

		input.init();
		
		connectEvents();

		screen.init();
		renderer.init();
		_inited = true;
		
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
		_nextQueue = null;
		_deferQueue = null;

	}

	function parseOptions(options:ClayOptions):SystemOptions {

		_debug("parsing options: " + options);

		_options = {};
		_options.title = def(options.title, "clay game");
		_options.width = def(options.width, 800);
		_options.height = def(options.height, 600);
		_options.vsync = def(options.vsync, false);
		_options.antialiasing = def(options.antialiasing, 1);
		_options.window = def(options.window, {});
		_options.renderer = def(options.renderer, {});

		var features:WindowFeatures = None;
		if (_options.window.resizable) features |= WindowFeatures.FeatureResizable;
		if (_options.window.maximizable) features |= WindowFeatures.FeatureMaximizable;
		if (_options.window.minimizable) features |= WindowFeatures.FeatureMinimizable;
		if (_options.window.borderless) features |= WindowFeatures.FeatureBorderless;
		if (_options.window.ontop) features |= WindowFeatures.FeatureOnTop;

		var _khaOpt: SystemOptions = {
			title: _options.title,
			width: _options.width,
			height: _options.height,
			window: {
				x: _options.window.x,
				y: _options.window.y,
				mode: _options.window.mode,
				windowFeatures: features
			},
			framebuffer: {
				samplesPerPixel: _options.antialiasing,
				verticalSync: _options.vsync
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
		frameDelta = time - _lastTime;

		if(frameDelta > _frameMaxDelta) {
			frameDelta = 1/60;
		}

		// Smooth out the delta over the previous X frames
		_deltas[_deltaIndex] = frameDelta;
		
		_deltaIndex++;

		if(_deltaIndex > _deltaSmoothing) {
			_deltaIndex = 0;
		}

		dt = 0;

		for (i in 0..._deltaSmoothing) {
			dt += _deltas[i];
		}

		dt /= _deltaSmoothing;

		tick();

		_fixedOverflow += frameDelta;
		while(_fixedOverflow >= fixedFrameTime) {
			emitter.emit(AppEvent.FIXEDUPDATE, fixedFrameTime);
			_fixedOverflow -= fixedFrameTime;
		}

		emitter.emit(AppEvent.UPDATE, dt);
		
		renderer.update(dt);

		_lastTime = time;

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

		var count = _nextQueue.length;
		var i = 0;
		while(i < count) {
			(_nextQueue.shift())();
			++i;
		}

	}

	inline function cycleDeferQueue() {

		var count = _deferQueue.length;
		var i = 0;
		while(i < count) {
			(_deferQueue.shift())();
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