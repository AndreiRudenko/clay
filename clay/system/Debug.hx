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
	public static var trace_callbacks : Array<Dynamic->?haxe.PosInfos->Void> = [];

	static var shut_down:Bool = false;
	static var tracing:Bool = false;
	static var haxe_trace:Dynamic->?haxe.PosInfos->Void;

	static function internal_trace(_value:Dynamic, ?_info:haxe.PosInfos) {

		assert(tracing == false, 'clay.Debug: calling trace from a trace callback is an infinite loop!');
		tracing = true;

		var _out = '$_value';

		if(_info != null && _info.customParams != null) {
			_out += ' ' + _info.customParams.join(' ');
		}

		haxe_trace(_value, _info);

		if(!shut_down) {
			for(_callback in trace_callbacks) {
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

	@:noCompletion public var current_view:DebugView;

	public var layer(default, null):Layer;
	var engine:App;
	#end

	// var current_view_index = 0;
	// var last_view_index = 0;

	function new(_engine:App) {

		#if !no_debug_console
		engine = _engine;
		views = [];
		layer = Clay.renderer.layers.create('debug_layer', 999);
		#end
	}

	@:noCompletion public function add_view(_view:DebugView) {

		#if !no_debug_console

		_view.index = views.length;
		inspector.add_tab(_view.debug_name);
		views.push(_view);
		// world.processors.add(_view, null, false);

		#end
	}

	// public function get_view<T>(_name:String):T {

	// 	#if !no_debug_console

	// 	for(view in views) {
	// 		if(view.name == _name) {
	// 			return cast view;
	// 		}
	// 	}

	// 	#end

	// 	return null;

	// }

	@:noCompletion public function switch_view(index:Int) {

		#if !no_debug_console

		// log('switch_view');

		// current_view_index = _next ? current_view_index + 1 : current_view_index - 1;

		if(index < 0) {
			index = views.length-1;
		} else if(index > views.length-1) {
			index = 0;
		}

		// last_view_index = index;

		// views[last_view_index].disable();
		if(current_view != null) {
			current_view.active = false;
		}

		current_view = views[index];
		current_view.active = true;
		inspector.enable_tab(index);

		#end

	}

	@:noCompletion public function init() {

		#if !no_debug_console


		var c = Clay.cameras.create('debug', null, 999);
		c.hide_layers();
		c.show_layers(['debug_layer']);
		Clay.camera.hide_layers(['debug_layer']);

		Clay.cameras.oncameracreate.add(function(c) {
			c.hide_layers(['debug_layer']);
		});
		
		padding = new Vector(Clay.screen.width*0.05,Clay.screen.height*0.05);

		haxe_trace = haxe.Log.trace;
		haxe.Log.trace = internal_trace;

		// world = engine.worlds.create('debug_world', {capacity: 4096}, true);

		inspector = new Inspector(this);

		add_view(new clay.system.debug.TraceDebugView(this));
		// add_view(new clay.system.debug.EntitesDebugView(this));
		// add_view(new clay.system.debug.FamiliesDebugView(this));
		// add_view(new clay.system.debug.ProcessorsDebugView(this));
		add_view(new clay.system.debug.StatsDebugView(this));
		add_view(new clay.system.debug.AudioDebugView(this));
		profiller = new clay.system.debug.ProfilerDebugView(this);
		add_view(profiller);

		current_view = views[0];

		#end
	}

	@:noCompletion public function destroy() {

		#if !no_debug_console

		shut_down = true;
		haxe.Log.trace = haxe_trace;

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
