package clay.core.ecs;


import clay.World;
import clay.Entity;
import clay.ds.Int32RingBuffer;
import clay.ds.BitVector;
import clay.core.ecs.EntityVector;


class Entities {


	public var capacity (default, null):Int; // 16384, 65536
	public var used (default, null):Int;
	public var available(get, never):Int;

	@:noCompletion public var oncreate:Entity->Void;
	@:noCompletion public var ondestroy:Entity->Void;
	@:noCompletion public var onactivate:Entity->Void;
	@:noCompletion public var ondeactivate:Entity->Void;

	var _id_pool:Int32RingBuffer;
	
	var _alive_mask:BitVector;
	var _active_mask:BitVector;
	var _entities:EntityVector;

	var _destroyed_entities:Array<Entity>;
	var world:World;


	public function new(_world:World, _capacity:Int) {

		if((_capacity & (_capacity - 1)) != 0) {
			throw('Entities capacity: $_capacity must be power of two');
		}

		world = _world;

		capacity = _capacity;
		used = 0;

		_id_pool = new Int32RingBuffer(capacity);

		_entities = new EntityVector(capacity);
		_alive_mask = new BitVector(capacity);
		_active_mask = new BitVector(capacity);

		_destroyed_entities = [];

	}

	public function create(_active:Bool = true):Entity {

		var id:Int = pop_entity_id();
		var e:Entity = new Entity(id); 

		_alive_mask.enable(id);

		if(_active) {
			_active_mask.enable(id);
		}

		_entities.add_unsafe(e);

		if(oncreate != null) {
			oncreate(e);
		}
		
		world.changed();

		return e;

	}

	public function destroy(e:Entity) {

		if(!has(e)) {
			var _comps = world.components.get_all(e);
			var _list = [];
			for (c in _comps) {
				_list.push(Type.getClassName(Type.getClass(c)));
			}
			throw('entity ${e.id} destroying repeatedly / components: [${_list.join(',')}]');
		}

		world.components.clear_flags(e);

		_alive_mask.disable(e.id);
		_active_mask.disable(e.id);

		_destroyed_entities.push(e);

		world.changed();

	}

	public inline function has(e:Entity):Bool {

		return _alive_mask.get(e.id);

	}

	public inline function get(id:Int):Entity {

		return _alive_mask.get(id) ? new Entity(id) : Entity.NULL;

	}

	public inline function is_active(e:Entity):Bool {

		return has(e) ? _active_mask.get(e.id):false;
		
	}

	public inline function activate(e:Entity) {

		if(has(e)) {
			_active_mask.enable(e.id);

			if(onactivate != null) {
				onactivate(e);
			}
			world.changed();
		}

	}

	public inline function deactivate(e:Entity) {

		if(has(e)) {
			_active_mask.disable(e.id);

			if(ondeactivate != null) {
				ondeactivate(e);
			}
			world.changed();
		}

	}

	public function empty() {

		for (e in _entities) {
			destroy(e);
		}
		world.changed();

	}

	@:noCompletion public function delayed_destroy() {

		if(_destroyed_entities.length > 0) {
			for (e in _destroyed_entities) {
				_destroy(e);
			}
			_destroyed_entities.splice(0, _destroyed_entities.length);
		}
		
	}

	function _destroy(e:Entity) {
		
		_entities.remove_unsafe(e);
		push_entity_id(e.id);
		
		world.tags.unregister_entity(e);
		world.groups.unregister_entity(e);

		if(ondestroy != null) { // todo: is there right place?
			ondestroy(e);
		}

	}

	function get_available():Int {

		return capacity - used;

	}

	function pop_entity_id():Int {

		if(used >= capacity) {
			throw('Out of entities, max allowed ${capacity}');
		}

		++used;
		return _id_pool.pop();

	}

	function push_entity_id(_id:Int) {

		--used;
		_id_pool.push(_id);

	}

	@:noCompletion public function toString() {

		var _list = []; 

		for (e in _entities) {
			_list.push(e);
		}

		return 'entities: [${_list.join(", ")}]';

	}

	@:noCompletion public inline function iterator():EntityVectorIterator {

		return _entities.iterator();

	}


}