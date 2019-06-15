package clay.core.ecs;


import clay.World;

import clay.utils.Log.*;
import clay.utils.PowerOfTwo;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;
import clay.events.*;


@:allow(clay.Engine)
class Worlds {


	var inited:Bool = false;
	var worlds:Map<String, World>;
	var active_worlds:Array<World>;
	var events_priority:Int = 999;


	public function new() {
		
		_debug('creating new Worlds');
		worlds = new Map();
		active_worlds = [];

	}

	public function create(_name:String, ?_options:WorldOptions, _add_default_processors:Bool = false):World {

		_debug('create world: "${_name}"');

		var _active:Bool = true;
		var _priority:Int = 0;
		var _capacity:Int = 16384;
		var _comptypes:Int = 64;

		if(_options != null) {
			if(_options.active != null) {
				_active = _options.active;
			}
			if(_options.priority != null) {
				_priority = _options.priority;
			}
			if(_options.capacity != null) {
				_capacity = _options.capacity;
			}
			if(_options.component_types != null) {
				_comptypes = _options.component_types;
			}
		}
		
		var _world = new World(_name, PowerOfTwo.require(_capacity), _comptypes);
		_world.priority = _priority;

		handle_duplicate_warning(_name);
		worlds.set(_world.name, _world);

		if(inited) {
			_world.init();
		}
		
		if(_active) {
			enable(_world);
		}

		if(_add_default_processors) {
			_world.processors.add(new clay.processors.common.TransformProcessor(), 980);
			_world.processors.add(new clay.processors.graphics.ParticlesProcessor(), 991);
			_world.processors.add(new clay.processors.graphics.AnimationProcessor(), 992);
			_world.processors.add(new clay.processors.graphics.RenderProcessor(), 999);
		}

		return _world;

	}

	public function destroy(_world:World) {

		if(worlds.exists(_world.name)) {
			_debug('remove world: "${_world.name}"');
			worlds.remove(_world.name);
			disable(_world);
		} else {
			log('can`t remove world: "${_world.name}" , already removed?');
		}


		_world.destroy();

	}

	public inline function get(_name:String):World {

		return worlds.get(_name);

	}

	public function enable(_world:World) {

		if(_world._active) {
			return;
		}
		
		var added:Bool = false;
		var w:World = null;
		for (i in 0...active_worlds.length) {
			w = active_worlds[i];
			if (_world.priority < w.priority) {
				active_worlds.insert(i, _world);
				added = true;
				break;
			}
		}

		_world._active = true;

		if(!added) {
			active_worlds.push(_world);
		}

	}

	public function disable(_world:World) {

		if(!_world._active) {
			return;
		}

		active_worlds.remove(_world);
		_world._active = false;

		Clay.debug.remove(_world.name+'.update');
		
	}
	
	@:noCompletion public function init() {

		if(inited) {
			return;
		}

		listen_engine_signals();

		_debug('init');

		for (w in worlds) {
			w.init();
		}

		inited = true;

	}

	@:noCompletion public function destroy_manager() {

		_debug('empty');
		
		for (w in worlds) {
			destroy(w);
		}

		unlisten_engine_signals();

		worlds = null;
		active_worlds = null;
		
	}

	function listen_engine_signals() {

		Clay.on(RenderEvent.PRERENDER,       	prerender,     events_priority);     	
		Clay.on(RenderEvent.RENDER,          	render,        events_priority);     	    
		Clay.on(RenderEvent.POSTRENDER,      	postrender,    events_priority);     	

		Clay.on(AppEvent.TICKSTART,          	tickstart,     events_priority);     	
		Clay.on(AppEvent.TICKEND,            	tickend,       events_priority);     	
		Clay.on(AppEvent.FOREGROUND,         	foreground,    events_priority);     	
		Clay.on(AppEvent.BACKGROUND,         	background,    events_priority);     	
		Clay.on(AppEvent.PAUSE,              	pause,         events_priority);     	    
		Clay.on(AppEvent.RESUME,             	resume,        events_priority);     	    
		Clay.on(AppEvent.TIMESCALE,          	timescale,     events_priority);     	

		Clay.on(AppEvent.UPDATE,             	update,        events_priority);     	    
		Clay.on(AppEvent.FIXEDUPDATE,        	fixedupdate,   events_priority);     	

		Clay.on(KeyEvent.KEY_DOWN,           	keydown,       events_priority);     	
		Clay.on(KeyEvent.KEY_UP,             	keyup,         events_priority);       	
		Clay.on(KeyEvent.TEXT_INPUT,         	textinput,     events_priority);   	

		Clay.on(MouseEvent.MOUSE_DOWN,       	mousedown,     events_priority);   	
		Clay.on(MouseEvent.MOUSE_UP,         	mouseup,       events_priority);     	
		Clay.on(MouseEvent.MOUSE_MOVE,       	mousemove,     events_priority);   	
		Clay.on(MouseEvent.MOUSE_WHEEL,      	mousewheel,    events_priority);  	

		Clay.on(GamepadEvent.DEVICE_ADDED,   	gamepadadd,    events_priority);  	
		Clay.on(GamepadEvent.DEVICE_REMOVED, 	gamepadremove, events_priority);
		Clay.on(GamepadEvent.BUTTON_DOWN,    	gamepaddown,   events_priority); 	
		Clay.on(GamepadEvent.BUTTON_UP,      	gamepadup,     events_priority);   	
		Clay.on(GamepadEvent.AXIS,           	gamepadaxis,   events_priority); 	

		Clay.on(PenEvent.PEN_DOWN,           	pendown,       events_priority); 	    
		Clay.on(PenEvent.PEN_UP,             	penup,         events_priority); 	        
		Clay.on(PenEvent.PEN_MOVE,           	penmove,       events_priority); 

		Clay.on(TouchEvent.TOUCH_DOWN,          touchdown,     events_priority); 	    
		Clay.on(TouchEvent.TOUCH_UP,            touchup,       events_priority); 	        
		Clay.on(TouchEvent.TOUCH_MOVE,          touchmove,     events_priority); 	    

		Clay.on(InputEvent.INPUT_DOWN,       	inputdown,     events_priority); 	    
		Clay.on(InputEvent.INPUT_UP,         	inputup,       events_priority); 	    

	}

	function unlisten_engine_signals() {
		
		Clay.off(RenderEvent.PRERENDER,       	prerender);     	
		Clay.off(RenderEvent.RENDER,          	render);     	    
		Clay.off(RenderEvent.POSTRENDER,      	postrender);     	

		Clay.off(AppEvent.TICKSTART,          	tickstart);     	
		Clay.off(AppEvent.TICKEND,            	tickend);     	
		Clay.off(AppEvent.FOREGROUND,         	foreground);     	
		Clay.off(AppEvent.BACKGROUND,         	background);     	
		Clay.off(AppEvent.PAUSE,              	pause);     	    
		Clay.off(AppEvent.RESUME,             	resume);     	    
		Clay.off(AppEvent.TIMESCALE,          	timescale);     	

		Clay.off(AppEvent.UPDATE,             	update);     	    
		Clay.off(AppEvent.FIXEDUPDATE,        	fixedupdate);     	

		Clay.off(KeyEvent.KEY_DOWN,           	keydown);     	
		Clay.off(KeyEvent.KEY_UP,             	keyup);       	
		Clay.off(KeyEvent.TEXT_INPUT,         	textinput);   	

		Clay.off(MouseEvent.MOUSE_DOWN,       	mousedown);   	
		Clay.off(MouseEvent.MOUSE_UP,         	mouseup);     	
		Clay.off(MouseEvent.MOUSE_MOVE,       	mousemove);   	
		Clay.off(MouseEvent.MOUSE_WHEEL,      	mousewheel);  	

		Clay.off(GamepadEvent.DEVICE_ADDED,   	gamepadadd);  	
		Clay.off(GamepadEvent.DEVICE_REMOVED, 	gamepadremove);
		Clay.off(GamepadEvent.BUTTON_DOWN,    	gamepaddown); 	
		Clay.off(GamepadEvent.BUTTON_UP,      	gamepadup);   	
		Clay.off(GamepadEvent.AXIS,           	gamepadaxis); 	

		Clay.off(PenEvent.PEN_DOWN,           	pendown); 	    
		Clay.off(PenEvent.PEN_UP,             	penup); 	        
		Clay.off(PenEvent.PEN_MOVE,           	penmove); 	   

		Clay.off(TouchEvent.TOUCH_DOWN,          touchdown); 	    
		Clay.off(TouchEvent.TOUCH_UP,            touchup); 	        
		Clay.off(TouchEvent.TOUCH_MOVE,          touchmove); 	 

		Clay.off(InputEvent.INPUT_DOWN,       	inputdown); 	    
		Clay.off(InputEvent.INPUT_UP,         	inputup); 	  

	}
	function prerender(e) {

		_verboser('prerender');

		for (w in active_worlds) {
			w.emitter.emit(RenderEvent.PRERENDER, e);
		}
		
	}

	function render(e) {

		_verboser('render');

		for (w in active_worlds) {
			w.emitter.emit(RenderEvent.RENDER, e);
		}

	}

	function postrender(e) {

		_verboser('postrender');

		for (w in active_worlds) {
			w.emitter.emit(RenderEvent.POSTRENDER, e);
		}

	}

	function tickstart(e) {

		_verboser('tickstart');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.TICKSTART, e);
		}

	}

	function tickend(e) {

		_verboser('tickend');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.TICKEND, e);
		}

	}

	function update(dt:Float) {

		_verboser('update dt:${dt}');

		for (w in active_worlds) {
			Clay.debug.start(w.name+'.update');
			w.update();
			w.emitter.emit(AppEvent.UPDATE, dt);
			Clay.debug.end(w.name+'.update');
		}

	}

	function fixedupdate(rate:Float) {

		_verboser('fixedupdate rate:${rate}');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.FIXEDUPDATE, rate);
		}

	}

	// key
	function keydown(e:KeyEvent) {

		for (w in active_worlds) {
			w.emitter.emit(KeyEvent.KEY_DOWN, e);  
		}

	}

	function keyup(e:KeyEvent) {

		for (w in active_worlds) {
			w.emitter.emit(KeyEvent.KEY_UP, e);
		}

	}

	function textinput(e:String) {

		for (w in active_worlds) {
			w.emitter.emit(KeyEvent.TEXT_INPUT, e);
		}

	}

	// mouse
	function mousedown(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(MouseEvent.MOUSE_DOWN, e);  
		}

	}

	function mouseup(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(MouseEvent.MOUSE_UP, e);
		}

	}

	function mousemove(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(MouseEvent.MOUSE_MOVE, e); 
		}

	}

	function mousewheel(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(MouseEvent.MOUSE_WHEEL, e);  
		}

	}

	// gamepad
	function gamepadadd(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(GamepadEvent.DEVICE_ADDED, e);  
		}

	}

	function gamepadremove(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(GamepadEvent.DEVICE_REMOVED, e);
		}

	}

	function gamepaddown(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(GamepadEvent.BUTTON_DOWN, e);
		}

	}

	function gamepadup(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(GamepadEvent.BUTTON_UP, e);
		}

	}

	function gamepadaxis(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(GamepadEvent.AXIS, e);
		}

	}

	// touch
	function touchdown(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(TouchEvent.TOUCH_DOWN, e);
		}

	}

	function touchup(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(TouchEvent.TOUCH_UP, e);
		}

	}

	function touchmove(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(TouchEvent.TOUCH_MOVE, e);
		}

	}

	// pen
	function pendown(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(PenEvent.PEN_DOWN, e);
		}

	}

	function penup(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(PenEvent.PEN_UP, e);
		}

	}

	function penmove(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(PenEvent.PEN_MOVE, e);
		}

	}

	// bindings
	function inputdown(e:InputEvent) {

		for (w in active_worlds) {
			w.emitter.emit(InputEvent.INPUT_UP, e);
		}

	}

	function inputup(e:InputEvent) {

		for (w in active_worlds) {
			w.emitter.emit(InputEvent.INPUT_DOWN, e);
		}

	}


	function timescale(t:Float) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.TIMESCALE, t);
		}

	}

	function foreground(e) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.FOREGROUND, e);
		}

	}

	function background(e) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.BACKGROUND, e);
		}

	}

	function pause(e) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.PAUSE, e);
		}

	}

	function resume(e) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.RESUME, e);
		}

	}

	inline function handle_duplicate_warning(_name:String) {

		var w:World = worlds.get(_name);
		if(w != null) {
			log('adding a second world named: "${_name}"!
				This will replace the existing one, possibly leaving the previous one in limbo.');
			worlds.remove(_name);
			disable(w);
		}

	}

	@:noCompletion public function toString() {

		var _list = []; 

		for (w in worlds) {
			_list.push(w.name);
		}

		return 'worlds: [${_list.join(", ")}]';

	}

	@:noCompletion public inline function iterator():Iterator<World> {

		return worlds.iterator();

	}

}

typedef WorldOptions = {

	@:optional var active:Bool;
	@:optional var priority:Int;
	@:optional var capacity:Int;
	@:optional var component_types:Int;

}