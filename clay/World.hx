package clay;


import clay.core.Entities;
import clay.core.Components;
import clay.core.Processors;
import clay.core.Families;
import clay.core.Worlds;
import clay.core.TagSystem;
import clay.core.GroupSystem;
import clay.types.AppEvent;
import clay.emitters.OrderedEmitter;

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

	var worlds:Worlds;
	var emitter:OrderedEmitter<AppEvent>;
	var _active:Bool = false;
	var priority:Int = 0;


	public function new(_name:String, _capacity:Int, _comp_types:Int) {

		name = _name;

		emitter = new OrderedEmitter<AppEvent>();

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

    public inline function on<T>(event:AppEvent, handler:T->Void, order:Int = 0) {

        emitter.on(event, handler, order);

    }

    public inline function off<T>(event:AppEvent, handler:T->Void) {

        return emitter.off(event, handler);

    }

    inline function emit<T>(event:AppEvent, ?data:T) {

        return emitter.emit(event, data);

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

		emitter.destroy();

		tags = null;
		groups = null;
		entities = null;
		components = null;
		families = null;
		processors = null;
		emitter = null;

	}

	inline function update(dt:Float) {
		
		families.update();
		emitter.emit(AppEvent.update, dt);
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
