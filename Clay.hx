package ;


import clay.utils.Log.*;


class Clay {


	public static var engine      	(default, null):clay.Engine;

	public static var world       	(default, null):clay.World;
	public static var worlds      	(default, null):clay.core.Worlds;

	public static var screen      	(default, null):clay.Screen;
	public static var renderer 	    (default, null):clay.render.Renderer;
	public static var camera 	    (default, null):clay.components.Camera;
	public static var draw     	    (default, null):clay.render.Draw;

	public static var input    	    (default, null):clay.core.Inputs;
	public static var resources	    (default, null):clay.core.Resources;

	public static var audio 	    (default, null):clay.Audio;
	public static var timer    	    (default, null):clay.core.TimerSystem;
	public static var motion    	(default, null):clay.tween.TweenManager;
	
	public static var random    	(default, null):clay.math.Random;

	public static var tags   	    (get, never):clay.core.TagSystem;
	public static var groups   	    (get, never):clay.core.GroupSystem;
	
	public static var entities   	(get, never):clay.core.Entities;
	public static var components 	(get, never):clay.core.Components;
	public static var processors 	(get, never):clay.core.Processors;
	public static var families      (get, never):clay.core.Families;

	public static var dt	        (get, never):Float;
	public static var time	        (get, never):Float;
	public static var timescale	    (get, set):Float;

	// public static var io       	(default, null):clay.IO;


	static var inited:Bool = false;


	public static function init(_options:clay.ClayOptions, _onready:Void->Void) {

		assert(!inited, 'engine already inited');

		inited = true;

		new clay.Engine(_options, _onready);

	}
		/** listen for core events */
	public static function on<T>(event:clay.types.AppEvent, handler:T->Void ):Void {

		engine.emitter.on(event, handler);

	}

		/** stop listening for core events */
	public static function off<T>(event:clay.types.AppEvent, handler:T->Void ):Bool {

		return engine.emitter.off(event, handler);

	}

	static inline function get_tags() return world.tags;
	static inline function get_groups() return world.groups;
	static inline function get_entities() return world.entities;
	static inline function get_components() return world.components;
	static inline function get_processors() return world.processors;
	static inline function get_families() return world.families;

	static inline function get_dt() return engine.dt;
	static inline function get_time() return engine.time;
	static inline function get_timescale() return engine.timescale;
	static inline function set_timescale(v) return engine.timescale = v;
	

}
