package clay;


import clay.World;
import clay.core.Processors;
import clay.types.AppEvent;

import clay.input.Key;
import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;


#if !macro
@:autoBuild(clay.types.macro.ProcessorMacro.build())
#end

@:allow(clay.core.Processors)
class Processor {


	public var name(default, null):String;
	public var priority (default, set):Int;
	public var active (get, set):Bool;
	@:noCompletion var _active:Bool = false;

	@:noCompletion var world:World;
	

	public function new() {

		priority = 0;
		_active = false;
		name = Type.getClassName(Type.getClass(this));

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

	@:noCompletion function update(dt:Float) {}

	@:noCompletion function onkeydown(e:KeyEvent) {}
	@:noCompletion function onkeyup(e:KeyEvent) {}

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

	// todo: make another emitter ?
	@:noCompletion function __tickstart(_)  { ontickstart();  }
	@:noCompletion function __tickend(_)    { ontickend();    }
	@:noCompletion function __prerender(_)  { onprerender();  }
	@:noCompletion function __render(_)     { onrender();     }
	@:noCompletion function __postrender(_) { onpostrender(); }

	@:access(clay.core.Processors)
	@:noCompletion inline function set_priority(value:Int) : Int {

		priority = value;

		onprioritychanged(priority);

		if(world != null && active) {
			__unlisten_emitter();
			__listen_emitter();
		}

		return priority;

	}

	@:noCompletion inline function get_active():Bool {

		return _active;

	}
	
	@:noCompletion inline function set_active(value:Bool):Bool {

		_active = value;

		if(world != null) {
			if(_active){
				__listen_emitter();
			} else {
				__unlisten_emitter();
			}
		}
		
		return _active;

	}


}
