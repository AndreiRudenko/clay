package clay.core;


import clay.Engine;
import clay.World;
import clay.math.Vector;
import clay.utils.Log.*;

import clay.processors.debug.Inspector;
import clay.processors.debug.DebugView;
import clay.render.Layer;


@:allow(clay.Engine)
class Debug {

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
	public var padding:Vector;
    public var margin:Float = 32;

	@:noCompletion public var current_view:DebugView;

	public var layer(default, null):Layer;
	var engine:Engine;
	var world:World;

	var current_view_index = 0;
	var last_view_index = 0;

	function new(_engine:Engine) {

		#if !no_debug_console
		engine = _engine;
		views = [];
		layer = Clay.renderer.layers.create('debug_layer', 999);
		#end
	}

	@:noCompletion public function add_view(_view:DebugView) {

		#if !no_debug_console

		views.push(_view);
		world.processors.add(_view, null, false);

		#end
	}

	public function get_view<T>(_name:String):T {

		#if !no_debug_console

		for(view in views) {
			if(view.name == _name) {
				return cast view;
			}
		}

		#end

		return null;

	}

	@:noCompletion public function switch_view(_next:Bool = true) {

		#if !no_debug_console

		// log('switch_view');

		last_view_index = current_view_index;
		current_view_index = _next ? current_view_index + 1 : current_view_index - 1;

		if(current_view_index < 0) {
			current_view_index = views.length-1;
		} else if(current_view_index > views.length-1) {
			current_view_index = 0;
		}

		views[last_view_index].disable();
		current_view = views[current_view_index];

		current_view.enable();

		#end

	}

	@:noCompletion public function init() {

		#if !no_debug_console

		padding = new Vector(Clay.screen.width*0.05,Clay.screen.height*0.05);

		haxe_trace = haxe.Log.trace;
		haxe.Log.trace = internal_trace;

		world = engine.worlds.create('debug_world', null, true);

		inspector = new Inspector(this);

		add_view(new clay.processors.debug.TraceDebugView(this));
		add_view(new clay.processors.debug.EntitesDebugView(this));
		add_view(new clay.processors.debug.FamiliesDebugView(this));
		add_view(new clay.processors.debug.ProcessorsDebugView(this));
		add_view(new clay.processors.debug.StatsDebugView(this));

		current_view = views[0];

		world.processors.add(inspector);

		#end
	}

	@:noCompletion public function destroy() {

		#if !no_debug_console

		shut_down = true;
		haxe.Log.trace = haxe_trace;

		#end

	}

	public function start(_name:String) {

		#if !no_debug_console
		
		#end

	}

	public function end(_name:String) {

		#if !no_debug_console

		#end
		
	}



}
