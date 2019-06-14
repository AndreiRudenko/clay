package clay.core.ecs;


import clay.Entity;
import clay.ds.BitVector;


class Tags {


	var tag_entity:Map<String, Entity>;
	var entity_tag:Map<Entity, String>;
	var registered:BitVector;


	@:noCompletion public function new(_capacity:Int) {

		tag_entity = new Map();
		entity_tag = new Map();
		registered = new BitVector(_capacity);

	}

	public inline function get(tag:String):Entity {

		return tag_entity.exists(tag) ? tag_entity.get(tag) : Entity.NULL;
		
	}

	public inline function has(tag:String):Bool {
		
		return tag_entity.exists(tag);

	}

	public inline function get_tag(e:Entity):String {

		return entity_tag.get(e);

	}

	public inline function has_entity(e:Entity):Bool {
		
		return registered.get(e.id);

	}

	public function register(tag:String, e:Entity) {

		if(registered.get(e.id)) {
			_unregister(tag, e);
		}

		tag_entity.set(tag, e);
		entity_tag.set(e, tag);
		registered.enable(e.id);

	}

	public function unregister(tag:String) {

		if(tag_entity.exists(tag)) {
			var e = tag_entity.get(tag);
			_unregister(tag, e);
		}
		
	}

	inline function _unregister(tag:String, e:Entity) {
		
		tag_entity.remove(tag);
		entity_tag.remove(e);
		registered.disable(e.id);

	}

	public function unregister_entity(e:Entity) {

		if(registered.get(e.id)) {
			_unregister(get_tag(e), e);
		}
		
	}

	public function empty() {
		
		tag_entity = new Map();
		entity_tag = new Map();
		registered.disable_all();

	}



}





