package clay.system;


import clay.system.App;
import clay.math.Vector;
import clay.utils.Log.*;

import clay.system.debug.DebugView;
import clay.render.Layers;

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

	static function internalTrace(value:Dynamic, ?info:haxe.PosInfos) {
		assert(tracing == false, 'clay.Debug: calling trace from a trace callback is an infinite loop!');
		tracing = true;

		var _out = '$value';

		if(info != null && info.customParams != null) {
			_out += ' ' + info.customParams.join(' ');
		}

		haxeTrace(value, info);

		if(!shutDown) {
			for(_callback in traceCallbacks) {
				_callback(value, info);
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

	var engine:App;
	#end

	function new(_engine:App) {
		#if !no_debug_console
		engine = _engine;
		views = [];
		#end
	}

	@:noCompletion public function addView(view:DebugView) {
		#if !no_debug_console
		view.index = views.length;
		inspector.addTab(view.debugName);
		views.push(view);
		#end
	}

	// @:noCompletion public function getView<T>(name:String):T {

	// 	#if !no_debug_console

	// 	for(view in views) {
	// 		if(view.name == name) {
	// 			return cast view;
	// 		}
	// 	}

	// 	#end

	// 	return null;

	// }

	@:noCompletion public function switchView(index:Int) {
		#if !no_debug_console
		if(index < 0) {
			index = views.length-1;
		} else if(index > views.length-1) {
			index = 0;
		}

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
		c.hideAll();
		c.show(Layers.DEBUG_UI);
		Clay.camera.hide(Layers.DEBUG_UI);

		Clay.cameras.onCameraCreate.add(function(c) {
			c.hide(Layers.DEBUG_UI);
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
