package clay.core;


import clay.Entity;
import clay.ds.BitVector;


class GroupSystem {


	var group_entities:Map<String, Array<Entity>>;
	var entity_groups:Map<Entity, Array<String>>;


	@:noCompletion public function new() {

		group_entities = new Map();
		entity_groups = new Map();

	}

	public inline function get(name:String):Array<Entity> {

		return group_entities.get(name);
		
	}

	public inline function has(name:String):Bool {
		
		return group_entities.exists(name);

	}

	public inline function has_entity(e:Entity):Bool {
		
		return entity_groups.exists(e);

	}

	public function register(name:String, e:Entity) {

		if(entity_groups.exists(e)) {
			unregister_entity(e);
		}

		var arr:Array<Entity> = group_entities.get(name);
		if(arr == null) {
			arr = new Array<Entity>();
		}
		arr.push(e);
		group_entities.set(name, arr);

		var arr2:Array<String> = entity_groups.get(e);
		if(arr2 == null) {
			arr2 = new Array<String>();
		}
		arr2.push(name);
		entity_groups.set(e, arr2);

	}

	public function unregister(name:String) {

		var earr:Array<Entity> = group_entities.get(name);
		if(earr != null) {
			for (e in earr) {
				entity_groups.remove(e);
			}
			group_entities.remove(name);
		}

	}

	public function unregister_entity(e:Entity) {
		
		var garr:Array<String> = entity_groups.get(e);
		if(garr != null) {
			for (name in garr) {
				group_entities.remove(name);
			}
			entity_groups.remove(e);
		}

	}

	public function empty() {
		
		group_entities = new Map();
		entity_groups = new Map();

	}


}





