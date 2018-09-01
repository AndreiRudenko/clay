package clay.core;


import clay.World;
import clay.utils.Log.*;
import clay.types.AppEvent;


import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;


@:access(clay.World)
class Worlds {


	var inited:Bool = false;
    var worlds:Map<String, World>;
	var active_worlds:Array<World>;


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
		
		var _world = new World(_name, upper_power_of_two(_capacity), _comptypes);
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
			Clay.engine.setup_world(_world);
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
			if (_world.priority <= w.priority) {
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
		
	}

	@:noCompletion public function init() {

		if(inited) {
			return;
		}

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

		worlds = null;
		active_worlds = null;
		
	}

	inline function prerender() {

		_verboser('prerender');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.prerender);
		}
	}

	inline function postrender() {

		_verboser('postrender');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.postrender);
		}
	}

	inline function tickstart() {

		_verboser('tickstart');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.tickstart);
		}
	}

	inline function tickend() {

		_verboser('tickend');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.tickend);
		}
	}

	inline function update(dt:Float) {

		_verboser('update dt:${dt}');

		for (w in active_worlds) {
			w.update(dt);
		}

	}

	inline function render() {

		_verboser('render');

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.render);
		}
	}


	// key
	inline function keydown(e:KeyEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.keydown, e);
		}
	}

	inline function keyup(e:KeyEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.keyup, e);
		}
	}

	// mouse
	inline function mousedown(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.mousedown, e);
		}
	}

	inline function mouseup(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.mouseup, e);
		}
	}

	inline function mousemove(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.mousemove, e);
		}
	}

	inline function mousewheel(e:MouseEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.mousewheel, e);
		}
	}

	// gamepad
	inline function gamepadadd(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.gamepadconnect, e);
		}
	}

	inline function gamepadremove(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.gamepaddisconnect, e);
		}
	}

	inline function gamepaddown(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.gamepaddown, e);
		}
	}

	inline function gamepadup(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.gamepadup, e);
		}
	}

	inline function gamepadaxis(e:GamepadEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.gamepadaxis, e);
		}
	}

	// touch
	inline function touchdown(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.touchdown, e);
		}
	}

	inline function touchup(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.touchup, e);
		}
	}

	inline function touchmove(e:TouchEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.touchmove, e);
		}
	}

	// pen
	inline function pendown(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.pendown, e);
		}
	}

	inline function penup(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.penup, e);
		}
	}

	inline function penmove(e:PenEvent) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.penmove, e);
		}
	}

	inline function timescale(t:Float) {

		for (w in active_worlds) {
			w.emitter.emit(AppEvent.timescale, t);
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

	function upper_power_of_two(v:Int):Int {

		v--;
	    v |= v >> 1;
	    v |= v >> 2;
	    v |= v >> 4;
	    v |= v >> 8;
	    v |= v >> 16;
	    v++;

	    return v;

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