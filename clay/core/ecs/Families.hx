package clay.core.ecs;


import clay.Entity;
import clay.Family;
import clay.World;
import clay.core.ecs.Components;
// import clay.types.macro.MacroUtils;

import clay.ds.BitVector;


@:access(clay.core.ecs.Components, clay.FamilyData)
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
	
	public function get<T:FamilyData>(family_class:Class<T>):T {

		var class_name = Type.getClassName(family_class);
		var family:T = null;

		for (f in families) {
			if(f.name == class_name) {
				family = cast f;
				break;
			}
		}

		return family;

	}

	public function add<T:FamilyData>(family:T):T {

		family.setup(world);
		if(inited) {
			family.init();
		}
		families.push(family);

		return family;

	}
	

	public function update() {
		
		if(changed.length > 0) {
			for (e in changed) {
				for (f in families) {
					f.check(e);
				}
				changed_mask.disable(e.id);
			}
			changed.splice(0, changed.length);
		}
		
	}

	@:allow(clay.core.ecs.Components)
	function mark_check_entity(e:Entity) {
		
		if(!changed_mask.get(e.id)) {
			changed.push(e);
			changed_mask.enable(e.id);
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