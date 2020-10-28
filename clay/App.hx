package clay;


import kha.System;
import kha.Scheduler;
import kha.Framebuffer;
import kha.WindowOptions;
import kha.WindowOptions.WindowFeatures;

import clay.Input;
import clay.Graphics;
import clay.Audio;
import clay.Resources;
import clay.Window;
import clay.utils.Timer;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;

import clay.utils.Emitter;
import clay.events.AppEvent;
import clay.events.RenderEvent;

import clay.utils.Random;
import clay.utils.Math;
import clay.utils.Log;
import clay.utils.Common.*;

@:keep
class App {

	public var graphics(default, null):Graphics;
	public var audio(default, null):Audio;

	public var emitter(default, null):Emitter;

	public var window(default, null):Window;
	public var input(default, null):Input;
	public var resources(default, null):Resources;

	public var timer(default, null):TimerManager;
	public var random(default, null):Random;

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
		Log.debug("creating app");

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
		Log.debug("ready");

		clay.Clay.app = this;
		resources = new Resources();

		#if !no_default_font
		resources.loadAll(
			[
			"Muli-Regular.ttf",
			"Muli-Bold.ttf"
			], 
			function() {
				setup();
				init();
				Log.debug("onReady");
				onReady();
			}
		);
		#else
		setup();
		init();
		Log.debug("onReady");
		onReady();
		#end
	}

	function setup() {
		Log.debug("setup");

		_appEvent = new AppEvent();
		_renderEvent = new RenderEvent();

		emitter = new Emitter();

		random = new Random(_options.randomSeed);
		timer = new TimerManager();
		Timer.globalManager = timer;

		Graphics.setup();
		graphics = new Graphics();
		
		window = new Window(_options.antialiasing);
		audio = new Audio();
		
		input = new Input();
	}

	function init() {
		Log.debug("init");

		time = kha.System.time;
		_lastTime = time;

		_deltas = [];
		for (i in 0..._deltaSmoothing) {
			_deltas.push(1/60);
		}

		input.init();
		window.init();
		connectEvents();

		_inited = true;
	}

	function destroy() {
		disconnectEvents();
		input.destroy();
		timer.destroy();

		window = null;
		input = null;
		audio = null;
		timer = null;
		_nextQueue = null;
		_deferQueue = null;
	}

	function parseOptions(options:ClayOptions):SystemOptions {
		Log.debug("parsing options: " + options);

		_options = {};
		_options.title = def(options.title, "clay game");
		_options.width = def(options.width, 800);
		_options.height = def(options.height, 600);
		_options.vsync = def(options.vsync, false);
		_options.antialiasing = def(options.antialiasing, 1);
		_options.window = def(options.window, {});

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

	function render(f:Array<Framebuffer>) {
		Log.verbose("render");

		// debug.start(DebugTag.process);

		// debug.start(DebugTag.update);
		step(); // TODO: move to another place?
		// debug.end(DebugTag.update);

		// debug.start(DebugTag.render);
		_renderEvent.set(graphics, window.buffer.image.g2, window.buffer.image.g4);

		emitter.emit(RenderEvent.PRERENDER, _renderEvent);
		emitter.emit(RenderEvent.RENDER, _renderEvent);

		Graphics.render(f);
		window.render();

		emitter.emit(RenderEvent.POSTRENDER, _renderEvent);

		// debug.end(DebugTag.render);
		// debug.end(DebugTag.process);
	}

	function step() {
		tickstart();

		time = kha.System.time;
		frameDelta = time - _lastTime;

		if(frameDelta > _frameMaxDelta) {
			frameDelta = _frameMaxDelta;
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

		_lastTime = time;

		tickend();
	}

	inline function tickstart() {
		Log.verbose("ontickstart");

		cycleNextQueue();
		emitter.emit(AppEvent.TICKSTART, _appEvent);
	}

	inline function tick() {
		Log.verbose("tick");
		
		timer.update(dt);
	}

	inline function tickend() {
		Log.verbose("ontickend");

		emitter.emit(AppEvent.TICKEND, _appEvent);
		input.reset();

		cycleDeferQueue();
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
		v = Math.max(v, 0);

		timescale = v;

		emitter.emit(AppEvent.TIMESCALE, v);

		return v;
	}

	function set_fixedFrameTime(v:Float):Float {
		return fixedFrameTime = Math.max(v, 0);
	}

}


typedef ClayOptions = {
	?title:String,
	?width:Int,
	?height:Int,
	?antialiasing:Int,
	?vsync:Bool,
	?randomSeed:Int,
	// ?graphics:GraphicsOptions,
	?window:WindowOptions
};

typedef WindowOptions = {
	?x:Int,
	?y:Int,
	?resizable:Bool,
	?minimizable:Bool,
	?maximizable:Bool,
	?borderless:Bool,
	?ontop:Bool,
	?mode:WindowMode
};