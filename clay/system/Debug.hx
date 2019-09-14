package clay.system;


import clay.system.App;
import clay.math.Vector;
import clay.utils.Log.*;

import clay.system.debug.DebugView;

#if !no_debug_console
import clay.system.debug.Inspector;
import clay.system.debug.ProfilerDebugView;
import clay.render.Layer;
#end

@:allow(clay.system.App)
class Debug {

	#if !no_debug_console
	public static var traceCallbacks:Array<Dynamic->?haxe.PosInfos->Void> = [];

	static var shutDown:Bool = false;
	static var tracing:Bool = false;
	static var haxeTrace:(v:Dynamic, ?p:haxe.PosInfos)->Void;

	static function internalTrace(_value:Dynamic, ?_info:haxe.PosInfos) {

		assert(tracing == false, 'clay.Debug: calling trace from a trace callback is an infinite loop!');
		tracing = true;

		var _out = '$_value';

		if(_info != null && _info.customParams != null) {
			_out += ' ' + _info.customParams.join(' ');
		}

		haxeTrace(_value, _info);

		if(!shutDown) {
			for(_callback in traceCallbacks) {
				_callback(_value, _info);
			}
		}

		tracing = false;

	}

	public var views:Array<DebugView>;
	public var inspector:Inspector;
	public var profiller:ProfilerDebugView;
	public var padding:Vector;
    public var margin:Float = 32;

	@:noCompletion public var currentView:DebugView;

	public var layer(default, null):Layer;
	var engine:App;
	#end

	// var currentViewIndex = 0;
	// var lastViewIndex = 0;

	function new(_engine:App) {

		#if !no_debug_console
		engine = _engine;
		views = [];
		layer = Clay.renderer.layers.create('debugLayer', 999);
		#end
	}

	@:noCompletion public function addView(_view:DebugView) {

		#if !no_debug_console

		_view.index = views.length;
		inspector.addTab(_view.debugName);
		views.push(_view);
		// world.processors.add(_view, null, false);

		#end
	}

	// public function getView<T>(_name:String):T {

	// 	#if !noDebugConsole

	// 	for(view in views) {
	// 		if(view.name == _name) {
	// 			return cast view;
	// 		}
	// 	}

	// 	#end

	// 	return null;

	// }

	@:noCompletion public function switchView(index:Int) {

		#if !no_debug_console

		// log('switchView');

		// currentViewIndex = _next ? currentViewIndex + 1 : currentViewIndex - 1;

		if(index < 0) {
			index = views.length-1;
		} else if(index > views.length-1) {
			index = 0;
		}

		// lastViewIndex = index;

		// views[lastViewIndex].disable();
		if(currentView != null) {
			currentView.active = false;
		}

		currentView = views[index];
		currentView.active = true;
		inspector.enableTab(index);

		#end

	}

	@:noCompletion public function init() {

		#if !no_debug_console

		var c = Clay.cameras.create('debug', null, 999);
		c.hideLayers();
		c.showLayers(['debugLayer']);
		Clay.camera.hideLayers(['debugLayer']);

		Clay.cameras.oncameracreate.add(function(c) {
			c.hideLayers(['debugLayer']);
		});
		
		padding = new Vector(Clay.screen.width*0.05,Clay.screen.height*0.05);

		haxeTrace = haxe.Log.trace;
		haxe.Log.trace = internalTrace;

		inspector = new Inspector(this);

		addView(new clay.system.debug.TraceDebugView(this));
		addView(new clay.system.debug.StatsDebugView(this));
		addView(new clay.system.debug.AudioDebugView(this));
		profiller = new clay.system.debug.ProfilerDebugView(this);
		addView(profiller);

		currentView = views[0];

		#end
	}

	@:noCompletion public function destroy() {

		#if !no_debug_console

		shutDown = true;
		haxe.Log.trace = haxeTrace;

		#end

	}

	public inline function start(name:String, ?max:Float) {

		#if !no_debug_console
			profiller.start(name, max);
		#end

	}

	public inline function end(name:String) {

		#if !no_debug_console
			profiller.end(name);
		#end
		
	}
	
	public inline function remove(name:String) {

		#if !no_debug_console
			profiller.remove(name);
		#end
		
	}


}
