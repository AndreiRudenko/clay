package clay;


import clay.core.ecs.Tags;
import clay.core.ecs.Groups;

import clay.core.ecs.Entities;
import clay.core.ecs.Components;
import clay.core.ecs.Processors;
import clay.core.ecs.Families;
import clay.core.ecs.Worlds;
import clay.events.Emitter;

@:allow(clay.core.ecs.Worlds)
class World {


	public var name       	(default, null):String;
	public var inited     	(default, null):Bool = false;
	public var active     	(get, set):Bool;

	public var tags         (default, null):Tags;
	public var groups       (default, null):Groups;
	
	public var entities   	(default, null):Entities;
	public var components 	(default, null):Components;
	public var processors 	(default, null):Processors;
	public var families     (default, null):Families;
	
	public var emitter      (default, null):Emitter;

	#if !no_debug_console

	@:noCompletion public var has_changed:Bool = false;

	#end

	var _active:Bool = false;
	var worlds:Worlds;
	var priority:Int = 0;


	public function new(_name:String, _capacity:Int, _comp_types:Int) {

		name = _name;

		emitter = new Emitter();

		tags = new Tags(_capacity);
		groups = new Groups();
		
		entities = new Entities(this, _capacity);
		components = new Components(this, _comp_types);
		families = new Families(this);
		processors = new Processors(this);
		
	}

	public function empty() {

		tags.empty();
		groups.empty();
		entities.empty();
		components.empty();
		families.empty();
		processors.empty();

		changed();

	}

		/* update changed entities and remove destroyed */
	public inline function update() {
		
		entities.update();
		families.update();

	}

	@:noCompletion public function init() {

		if(inited) {
			return;
		}

		inited = true;
		families.init();
		processors.init();
		
	}

	@:noCompletion public inline function changed() {
		
		#if !no_debug_console

		has_changed = true;
		
		#end

	}

	function destroy() {
		
		empty();

		// emitter.destroy();

		tags = null;
		groups = null;
		entities = null;
		components = null;
		families = null;
		processors = null;
		emitter = null;

	}

	inline function get_active():Bool {

		return _active;

	}
	
	inline function set_active(value:Bool):Bool {

		_active = value;

		if(worlds != null) {
			if(_active){
				worlds.enable(this);
			} else {
				worlds.disable(this);
			}
		}
		
		return _active;

	}

}
