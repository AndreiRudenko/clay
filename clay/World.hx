package clay;


import clay.core.Entities;
import clay.core.Components;
import clay.core.Processors;
import clay.core.Families;
import clay.core.Worlds;
import clay.core.TagSystem;
import clay.core.GroupSystem;
import clay.core.EngineSignals;

@:allow(clay.core.Worlds)
class World {


	public var name       	(default, null):String;
	public var inited     	(default, null):Bool = false;
	public var active     	(get, set):Bool;

	public var tags         (default, null):TagSystem;
	public var groups       (default, null):GroupSystem;
	
	public var entities   	(default, null):Entities;
	public var components 	(default, null):Components;
	public var processors 	(default, null):Processors;
	public var families     (default, null):Families;
	
	public var signals      (default, null):EngineSignals;

	var _active:Bool = false;
	var worlds:Worlds;
	var priority:Int = 0;


	public function new(_name:String, _capacity:Int, _comp_types:Int) {

		name = _name;

		signals = new EngineSignals();

		tags = new TagSystem(_capacity);
		groups = new GroupSystem();
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

	}

	@:noCompletion public function init() {

		if(inited) {
			return;
		}

		inited = true;
		families.init();
		processors.init();
		
	}

	function destroy() {
		
		empty();

		signals.destroy();

		tags = null;
		groups = null;
		entities = null;
		components = null;
		families = null;
		processors = null;
		signals = null;

	}

	inline function update(dt:Float) {
		
		families.update();
		signals.update.emit(dt);
		entities.delayed_destroy();

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
