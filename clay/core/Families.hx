package clay.core;


import clay.Entity;
import clay.Family;
import clay.ds.BitVector;
import clay.World;
import clay.core.Components;


@:access(clay.core.Components, clay.FamilyData)
class Families {


	var world:World;
	var families:Array<FamilyData>;
	var inited:Bool = false;

	var changed:Array<Entity>;
	var changed_mask:BitVector;


	public function new(_world:World) {
		
		world = _world;

		families = [];

		changed_mask = new BitVector(world.entities.capacity);
		changed = [];

	}

	@:noCompletion public function get<T:FamilyData>(_family_class:Class<T>):T {

		var _class_name = Type.getClassName(_family_class);
		var _family:T = null;

		for (f in families) {
			if(f.name == _class_name) {
				_family = cast f;
				break;
			}
		}

		if(_family == null) {
			_family = Type.createEmptyInstance(_family_class);
			_family.setup(world);
			if(inited) {
				_family.init();
			}
			families.push(_family);
		}

		return _family;
		
	}
	
	public function update() {
		
		if(changed.length > 0) {
			for (e in changed) {
				check_entity(e);
				changed_mask.disable(e.id);
			}
			changed.splice(0, changed.length);
		}
		
	}

		/** check entity if it match families */
	public function check_entity(e:Entity) {
		
		for (f in families) {
			f.check(e);
		}

	}

		/** remove all families */
	@:noCompletion public function empty() {

		families.splice(0, families.length);

	}

	@:noCompletion public function init() {

		for (f in families) {
			f.init();
		}
		inited = true;
		
	}

	@:noCompletion public function check_entity_delayed(e:Entity) {

		if(!changed_mask.get(e.id)) {
			changed.push(e);
			changed_mask.enable(e.id);
		}

	}

	@:noCompletion public function toString() {

		var _list = []; 

		for (f in families) {
			_list.push(f.toString());
		}

		return 'families: [${_list.join(", ")}]';

	}

	@:noCompletion public inline function iterator():Iterator<FamilyData> {

		return families.iterator();

	}


}