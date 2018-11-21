package ;


import clay.utils.Log.*;

class Clay {


	@:allow(clay.Engine)
	public static var engine      	(default, null):clay.Engine;
	public static var debug      	(get, never):clay.core.Debug;

	public static var world       	(get, set):clay.World;
	public static var worlds      	(get, never):clay.core.ecs.Worlds;

	public static var screen      	(get, never):clay.core.Screen;
	public static var renderer 	    (get, never):clay.render.Renderer;
	public static var camera 	    (get, never):clay.render.Camera;
	public static var cameras 	    (get, never):clay.render.CameraManager;
	public static var layers 	    (get, never):clay.render.LayerManager;
	public static var draw     	    (get, never):clay.render.Draw;

	public static var input    	    (get, never):clay.core.Inputs;
	public static var resources	    (get, never):clay.core.Resources;

	public static var audio 	    (get, never):clay.core.Audio;
	public static var timer    	    (get, never):clay.core.TimerSystem;
	public static var events    	(get, never):clay.components.event.Events;
	public static var motion    	(get, never):clay.tween.TweenManager;
	
	public static var random    	(get, never):clay.math.Random;

	public static var signals      	(get, never):clay.core.EngineSignals;

	public static var tags   	    (get, never):clay.core.ecs.TagSystem;
	public static var groups   	    (get, never):clay.core.ecs.GroupSystem;
	
	public static var entities   	(get, never):clay.core.ecs.Entities;
	public static var components 	(get, never):clay.core.ecs.Components;
	public static var processors 	(get, never):clay.core.ecs.Processors;
	public static var families      (get, never):clay.core.ecs.Families;

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

	public static inline function next(func:Void->Void) engine.next(func);
	public static inline function defer(func:Void->Void) engine.defer(func);

	static inline function get_world() return engine.world;
	static inline function set_world(w) return engine.world = w;
	static inline function get_worlds() return engine.worlds;

	static inline function get_debug() return engine.debug;

	static inline function get_screen() return engine.screen;
	static inline function get_renderer() return engine.renderer;
	static inline function get_camera() return engine.renderer.camera;
	static inline function get_cameras() return engine.renderer.cameras;
	static inline function get_layers() return engine.renderer.layers;
	static inline function get_draw() return engine.draw;

	static inline function get_input() return engine.input;
	static inline function get_resources() return engine.resources;

	static inline function get_audio() return engine.audio;
	static inline function get_timer() return engine.timer;
	static inline function get_events() return engine.events;
	static inline function get_motion() return engine.motion;

	static inline function get_random() return engine.random;
	static inline function get_signals() return engine.signals;

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
