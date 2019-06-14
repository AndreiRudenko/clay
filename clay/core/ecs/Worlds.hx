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


@:allow(clay.Engine)
class Worlds {


	var inited:Bool = false;
    var worlds:Map<String, World>;
	var active_worlds:Array<World>;
	var signals_order:Int = 999;


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
		
		Clay.signals.prerender.add(prerender, signals_order);
		Clay.signals.render.add(render, signals_order);
		Clay.signals.postrender.add(postrender, signals_order);
		Clay.signals.tickstart.add(tickstart, signals_order);
		Clay.signals.tickend.add(tickend, signals_order);
		Clay.signals.update.add(update, signals_order);
		Clay.signals.fixedupdate.add(fixedupdate, signals_order);
		Clay.signals.keydown.add(keydown, signals_order);
		Clay.signals.keyup.add(keyup, signals_order);
		Clay.signals.textinput.add(textinput, signals_order);
		Clay.signals.mousedown.add(mousedown, signals_order);
		Clay.signals.mouseup.add(mouseup, signals_order);
		Clay.signals.mousemove.add(mousemove, signals_order);
		Clay.signals.mousewheel.add(mousewheel, signals_order);
		Clay.signals.gamepadadd.add(gamepadadd, signals_order);
		Clay.signals.gamepadremove.add(gamepadremove, signals_order);
		Clay.signals.gamepaddown.add(gamepaddown, signals_order);
		Clay.signals.gamepadup.add(gamepadup, signals_order);
		Clay.signals.gamepadaxis.add(gamepadaxis, signals_order);
		Clay.signals.touchdown.add(touchdown, signals_order);
		Clay.signals.touchup.add(touchup, signals_order);
		Clay.signals.touchmove.add(touchmove, signals_order);
		Clay.signals.pendown.add(pendown, signals_order);
		Clay.signals.penup.add(penup, signals_order);
		Clay.signals.penmove.add(penmove, signals_order);
		Clay.signals.inputdown.add(inputdown, signals_order);
		Clay.signals.inputup.add(inputup, signals_order);
		Clay.signals.timescale.add(timescale, signals_order);
		Clay.signals.foreground.add(foreground, signals_order);
		Clay.signals.background.add(background, signals_order);
		Clay.signals.pause.add(pause, signals_order);
		Clay.signals.resume.add(resume, signals_order);

	}

	function unlisten_engine_signals() {
		
		Clay.signals.prerender.remove(prerender);
		Clay.signals.render.remove(render);
		Clay.signals.postrender.remove(postrender);
		Clay.signals.tickstart.remove(tickstart);
		Clay.signals.tickend.remove(tickend);
		Clay.signals.update.remove(update);
		Clay.signals.fixedupdate.remove(fixedupdate);
		Clay.signals.keydown.remove(keydown);
		Clay.signals.keyup.remove(keyup);
		Clay.signals.textinput.remove(textinput);
		Clay.signals.mousedown.remove(mousedown);
		Clay.signals.mouseup.remove(mouseup);
		Clay.signals.mousemove.remove(mousemove);
		Clay.signals.mousewheel.remove(mousewheel);
		Clay.signals.gamepadadd.remove(gamepadadd);
		Clay.signals.gamepadremove.remove(gamepadremove);
		Clay.signals.gamepaddown.remove(gamepaddown);
		Clay.signals.gamepadup.remove(gamepadup);
		Clay.signals.gamepadaxis.remove(gamepadaxis);
		Clay.signals.touchdown.remove(touchdown);
		Clay.signals.touchup.remove(touchup);
		Clay.signals.touchmove.remove(touchmove);
		Clay.signals.pendown.remove(pendown);
		Clay.signals.penup.remove(penup);
		Clay.signals.penmove.remove(penmove);
		Clay.signals.inputdown.remove(inputdown);
		Clay.signals.inputup.remove(inputup);
		Clay.signals.timescale.remove(timescale);
		Clay.signals.foreground.remove(foreground);
		Clay.signals.background.remove(background);
		Clay.signals.pause.remove(pause);
		Clay.signals.resume.remove(resume);

	}

	function prerender() {

		_verboser('prerender');

		for (w in active_worlds) {
			w.signals.prerender.emit();
		}
		
	}

	function postrender() {

		_verboser('postrender');

		for (w in active_worlds) {
			w.signals.postrender.emit();
		}

	}

	function tickstart() {

		_verboser('tickstart');

		for (w in active_worlds) {
			w.signals.tickstart.emit();
		}

	}

	function tickend() {

		_verboser('tickend');

		for (w in active_worlds) {
			w.signals.tickend.emit();
		}

	}

	function update(dt:Float) {

		_verboser('update dt:${dt}');

		for (w in active_worlds) {
			Clay.debug.start(w.name+'.update');
			w.update();
			w.signals.update.emit(dt);
			Clay.debug.end(w.name+'.update');
		}

	}

	function fixedupdate(rate:Float) {

		_verboser('fixedupdate rate:${rate}');

		for (w in active_worlds) {
			w.signals.fixedupdate.emit(rate);
		}

	}

	function render() {

		_verboser('render');

		for (w in active_worlds) {
			w.signals.render.emit();
		}

	}


	// key
	function keydown(e:KeyEvent) {

		for (w in active_worlds) {
			w.signals.keydown.emit(e);
		}

	}

	function keyup(e:KeyEvent) {

		for (w in active_worlds) {
			w.signals.keyup.emit(e);
		}

	}

	function textinput(e:String) {

		for (w in active_worlds) {
			w.signals.textinput.emit(e);
		}

	}

	// mouse
	function mousedown(e:MouseEvent) {

		for (w in active_worlds) {
			w.signals.mousedown.emit(e);
		}

	}

	function mouseup(e:MouseEvent) {

		for (w in active_worlds) {
			w.signals.mouseup.emit(e);
		}

	}

	function mousemove(e:MouseEvent) {

		for (w in active_worlds) {
			w.signals.mousemove.emit(e);
		}

	}

	function mousewheel(e:MouseEvent) {

		for (w in active_worlds) {
			w.signals.mousewheel.emit(e);
		}

	}

	// gamepad
	function gamepadadd(e:GamepadEvent) {

		for (w in active_worlds) {
			w.signals.gamepadadd.emit(e);
		}

	}

	function gamepadremove(e:GamepadEvent) {

		for (w in active_worlds) {
			w.signals.gamepadremove.emit(e);
		}

	}

	function gamepaddown(e:GamepadEvent) {

		for (w in active_worlds) {
			w.signals.gamepaddown.emit(e);
		}

	}

	function gamepadup(e:GamepadEvent) {

		for (w in active_worlds) {
			w.signals.gamepadup.emit(e);
		}

	}

	function gamepadaxis(e:GamepadEvent) {

		for (w in active_worlds) {
			w.signals.gamepadaxis.emit(e);
		}

	}

	// touch
	function touchdown(e:TouchEvent) {

		for (w in active_worlds) {
			w.signals.touchdown.emit(e);
		}

	}

	function touchup(e:TouchEvent) {

		for (w in active_worlds) {
			w.signals.touchup.emit(e);
		}

	}

	function touchmove(e:TouchEvent) {

		for (w in active_worlds) {
			w.signals.touchmove.emit(e);
		}

	}

	// pen
	function pendown(e:PenEvent) {

		for (w in active_worlds) {
			w.signals.pendown.emit(e);
		}

	}

	function penup(e:PenEvent) {

		for (w in active_worlds) {
			w.signals.penup.emit(e);
		}

	}

	function penmove(e:PenEvent) {

		for (w in active_worlds) {
			w.signals.penmove.emit(e);
		}

	}

	// bindings
	function inputdown(e:InputEvent) {

		for (w in active_worlds) {
			w.signals.inputdown.emit(e);
		}

	}

	function inputup(e:InputEvent) {

		for (w in active_worlds) {
			w.signals.inputup.emit(e);
		}

	}


	function timescale(t:Float) {

		for (w in active_worlds) {
			w.signals.timescale.emit(t);
		}

	}

	function foreground() {

		for (w in active_worlds) {
			w.signals.foreground.emit();
		}

	}

	function background() {

		for (w in active_worlds) {
			w.signals.background.emit();
		}

	}

	function pause() {

		for (w in active_worlds) {
			w.signals.pause.emit();
		}

	}

	function resume() {

		for (w in active_worlds) {
			w.signals.resume.emit();
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