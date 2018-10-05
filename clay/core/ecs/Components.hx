package clay.core.ecs;

import haxe.ds.Vector;

import clay.Entity;
import clay.World;
import clay.core.ecs.Entities;
import clay.types.ComponentType;
import clay.ds.BitFlag;
import clay.ds.BitVector;
import clay.ComponentMapper;


@:allow(clay.ComponentMapper)
class Components {


	var components:Array<ComponentMapper<Dynamic>>;
	var world:World;
	var flags:Vector<BitFlag>;
	var types:Map<String, ComponentType>;
	var id:Int = 0;
	var max_comptypes:Int;


	public function new(_world:World, _comptypes:Int = 64) {

		world = _world;
		world.entities.oncreate = onentitiycreate;
		world.entities.ondestroy = onentitiydestroy;
		max_comptypes = _comptypes;

		types = new Map();
		flags = new Vector(world.entities.capacity);
		components = [];

	}

		/** get a components array from class type.
			@param _component_class The class of the components requested.
			@return The component array, or null if none was found. */
	public function get_mapper<T>(_component_class:Class<T>):ComponentMapper<T> {
		
		var ct:ComponentType = get_type(_component_class);
		return cast components[ct.id];

	}

		/** add a component to the entity.
			@param _entity The entity.
			@param _component The component object to add.
			@param _component_class The class of the component. This is only necessary if the component
			extends another component class and you want the framework to treat the component as of
			the base class type. If not set, the class type is determined directly from the component.
			@return A reference to component. */
	public inline function set<T>(_entity:Entity, _component:T, ?_component_class:Class<Dynamic>):T {

		if(_component_class == null){
			_component_class = Type.getClass(_component);
		}

		var ct:ComponentType = get_type(_component_class);
		return cast components[ct.id].set(_entity, _component);

	}

		/** add a array of components to the entity.
			@param _entity The entity.
			@param _components Array of components to add. */
	public inline function set_many(_entity:Entity, _components:Array<Dynamic>) {

		var ct:ComponentType = new ComponentType(-1);
		for (c in _components) {
			ct = get_type(Type.getClass(c));
			components[ct.id]._set(_entity, c); // don't notify families
		}
		// now we can send events, immediate
		entity_changed(_entity);

	}

		/** get a component from the entity.
			@param _entity The entity.
			@param _component_class The class of the component requested.
			@return The component, or null if none was found. */
	public inline function get<T>(_entity:Entity, _component_class:Class<T>):T {

		var ct:ComponentType = get_type(_component_class);
		return cast components[ct.id].get(_entity);

	}	

		/** get all components from the entity. */
	public function get_all(_entity:Entity):Array<Dynamic> {

		var ret:Array<Dynamic> = [];

		for (c in components) {
			var comp = c.get(_entity);
			if(comp != null) {
				ret.push(comp);
			}
		}

		return ret;

	}

		/** check if entity has component.
			@param _entity The entity.
			@param _component_class The class of the component requested.
			@return true, or false if none was found. */
	public inline function has(_entity:Entity, _component_class:Class<Dynamic>):Bool {

		var ct:ComponentType = get_type(_component_class);
		return _has(_entity, ct.id);

	}

		/** remove a component from the entity.
			@param _entity The entity.
			@param _component_class The class of the component to be removed.
			@return true if component removed. */
	public inline function remove(_entity:Entity, _component_class:Class<Dynamic>):Bool {

		var ct:ComponentType = get_type(_component_class);
		return components[ct.id].remove(_entity);

	}

		/** remove all components from the entity */
	public function remove_all(_entity:Entity) {

		for (c in components) {
			c.remove(_entity);
		}

	}

		/** remove all components */
	public function empty() {

		for (e in world.entities) {
			remove_all(e);
		}

	}

	@:noCompletion public function clear_flags(e:Entity) {

		flags[e.id].clear();
		entity_changed_delayed(e);

	}

	@:noCompletion public function get_type<T>(_component:Class<T>):ComponentType {

		var ct:ComponentType = new ComponentType(-1);
		var tname:String = Type.getClassName(_component);
		if(types.exists(tname)) {
			ct = types.get(tname);
		} else {
			if(id >= max_comptypes) {
				throw('To many Component types, max allowed ${max_comptypes}');
			}
			ct = new ComponentType(id++);
			types.set(tname, ct);
			components[ct.id] = new ComponentMapper<T>(this, ct);
		}

		return ct;
		
	}

	@:allow(clay.FamilyData)
	inline function get_tid<T>(_entity:Entity, _ctid:Int):T {

		return cast components[_ctid].get(_entity);

	}
	
	function onentitiycreate(e:Entity) {

		flags[e.id] = new BitFlag(max_comptypes);

	}

	function onentitiydestroy(e:Entity) {

		remove_all(e);
		flags[e.id] = null;

	}

	inline function entity_changed(e:Entity) {

		if(world.entities.has(e)) {
			world.families.check_entity(e);
		}

	}

	inline function entity_changed_delayed(e:Entity) {

		if(world.entities.has(e)) {
			world.families.check_entity_delayed(e);
		}

	}

	inline function _has(e:Entity, cid:Int):Bool {

		return components[cid].has(e);
		
	}

	@:noCompletion public function toString() {

		var _list = []; 

		var len:Int = components.length;
		var comps:Int = 0;

		for (i in 0...len) {
			var cd = components[i];
			if(cd != null) { 
				_list.push(cd.toString());
			}
		}

		return 'types:$len / components: $comps / ${_list.join(", ")}';

	}

	@:noCompletion public inline function iterator():Iterator<ComponentMapper<Dynamic>> {

		return components.iterator();

	}


}
