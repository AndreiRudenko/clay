package clay;


import clay.World;
import clay.core.ecs.Processors;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;
import clay.utils.Log.*;
import clay.events.*;


#if !macro
@:autoBuild(clay.types.macro.ProcessorMacro.build())
#end

@:allow(clay.core.ecs.Processors)
class Processor {


	public var name     (default, null):String;
	public var priority (get, set):Int;
	public var active   (get, never):Bool;
	public var world    (get, never):World;

	@:noCompletion var _priority:Int = 0;
	@:noCompletion var _active:Bool = false;
	@:noCompletion var _world:World;
	

	public function new() {

		_priority = 0;
		_active = false;
		name = Type.getClassName(Type.getClass(this));

	}

	public function enable() {

		if(world == null) {
			log('can`t enable processor `$name` without world');
			return;
		}

		world.processors._enable(this);
		
	}

	public function disable() {
		
		if(world == null) {
			log('can`t disable processor `$name` without world');
			return;
		}

		world.processors._disable(this);

	}

	@:noCompletion function init() {}
	@:noCompletion function ondestroy() {}

	@:noCompletion function onadded() {}
	@:noCompletion function onremoved() {}
	@:noCompletion function onenabled() {}
	@:noCompletion function ondisabled() {}

	@:noCompletion function onprioritychanged(value:Int) {}

	@:noCompletion function ontickstart() {}
	@:noCompletion function ontickend() {}

	@:noCompletion function onprerender() {}
	@:noCompletion function onrender() {}
	@:noCompletion function onpostrender() {}
	
	@:noCompletion function onforeground() {}
	@:noCompletion function onbackground() {}
	@:noCompletion function onpause() {}
	@:noCompletion function onresume() {}

	@:noCompletion function update(dt:Float) {}
	@:noCompletion function fixedupdate(rate:Float) {}

	@:noCompletion function onkeydown(e:KeyEvent) {}
	@:noCompletion function onkeyup(e:KeyEvent) {}
	
	@:noCompletion function ontextinput(e:String) {}

	@:noCompletion function onmousedown(e:MouseEvent) {}
	@:noCompletion function onmouseup(e:MouseEvent) {}
	@:noCompletion function onmousemove(e:MouseEvent) {}
	@:noCompletion function onmousewheel(e:MouseEvent) {}

	@:noCompletion function ongamepadadd(e:GamepadEvent) {}
	@:noCompletion function ongamepadremove(e:GamepadEvent) {}
	@:noCompletion function ongamepaddown(e:GamepadEvent) {}
	@:noCompletion function ongamepadup(e:GamepadEvent) {}
	@:noCompletion function ongamepadaxis(e:GamepadEvent) {}

	@:noCompletion function ontouchdown(e:TouchEvent) {}
	@:noCompletion function ontouchup(e:TouchEvent) {}
	@:noCompletion function ontouchmove(e:TouchEvent) {}

	@:noCompletion function onpendown(e:PenEvent) {}
	@:noCompletion function onpenup(e:PenEvent) {}
	@:noCompletion function onpenmove(e:PenEvent) {}

	@:noCompletion function oninputdown(e:InputEvent) {}
	@:noCompletion function oninputup(e:InputEvent) {}
	
	@:noCompletion function ontimescale(t:Float) {}

	@:noCompletion function __listen_emitter() {}
	@:noCompletion function __unlisten_emitter() {}

	@:noCompletion function __update(dt:Float) {

		update(dt);
		world.update();

	}

	@:noCompletion function __onprerender(e)  	onprerender();
	@:noCompletion function __onrender(e)  	    onrender();
	@:noCompletion function __onpostrender(e)  	onpostrender();
	@:noCompletion function __ontickstart(e)  	ontickstart();
	@:noCompletion function __ontickend(e)    	ontickend();
	@:noCompletion function __onforeground(e) 	onforeground();
	@:noCompletion function __onbackground(e) 	onbackground();
	@:noCompletion function __onpause(e)      	onpause();
	@:noCompletion function __onresume(e)     	onresume();

	@:noCompletion inline function get_priority():Int {

		return _priority;

	}

	@:access(clay.core.ecs.Processors)
	@:noCompletion inline function set_priority(value:Int) : Int {

		_priority = value;

		onprioritychanged(_priority);

		if(world != null && _active) {
			__unlisten_emitter();
			__listen_emitter();
		}

		return _priority;

	}

	@:noCompletion inline function get_active():Bool {

		return _active;

	}

	@:noCompletion inline function get_world():World {

		return _world;

	}


}
