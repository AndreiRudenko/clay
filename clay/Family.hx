package clay;


import clay.Entity;
import clay.World;
import clay.core.ecs.Components;
import clay.core.ecs.Families;
import clay.core.ecs.EntityVector;
import clay.types.ComponentType;

import clay.components.event.Signal;
import clay.ds.BitFlag;


#if js
private typedef IntArray = js.html.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end

#if !macro
@:genericBuild(clay.types.macro.FamilyMacro.build())
#end
class Family<Rest> {}


@:access(clay.core.ecs.Families, clay.core.ecs.Components)
class FamilyData {
	

	public var name         (default, null):String;
	public var inited       (default, null):Bool = false;
	public var length       (get, never):Int;

	public var onadded  	(default, null):Signal<Entity->Void>;
	public var onremoved	(default, null):Signal<Entity->Void>;

	var world:World;

	var entities:EntityVector;
	var cm:Components;

	var include_flags:BitFlag;
	var exclude_flags:BitFlag;
	// var one_flags:BitFlag;

	var include_flags_count:Int;
	var exclude_flags_count:Int;
	// var one_flags_count:Int;

	var ent_id:IntArray;       // [ comp_idx | ent_id    ]
	var comp_idx:IntArray;     // [ entity   | comp_idx  ]
	var count:Int;


	public function new() {}

	public function has(e:Entity):Bool {
		
		return entities.has(e);

	}

	@:noCompletion public function get_by_index(idx:Int):Entity {
		
		return entities.get(idx);

	}

	public function listen(_onadded:Entity->Void, _onremoved:Entity->Void) {
		
		onadded.add(_onadded);
		onremoved.add(_onremoved);

	}

	public function unlisten(_onadded:Entity->Void, _onremoved:Entity->Void) {

		onadded.remove(_onadded);
		onremoved.remove(_onremoved);

	}

	// dce issue 
	function setup(_world:World) {
		
		name = Type.getClassName(Type.getClass(this));

		include_flags_count = 0;
		exclude_flags_count = 0;
		// one_flags_count = 0;
		count = 0;

		world = _world;
		cm = world.components;

		var ecp:Int = world.entities.capacity;
		entities = new EntityVector(ecp);

		ent_id = new IntArray(ecp);
		comp_idx = new IntArray(ecp);

		for (i in 0...comp_idx.length) {
			comp_idx[i] = -1;
		}

		onadded = new Signal();
		onremoved = new Signal();

		var mct:Int = cm.max_comptypes;
		include_flags = new BitFlag(mct);
		exclude_flags = new BitFlag(mct);
		// one_flags = new BitFlag(mct);

	}

	function init() {}
	function add_components(e:Entity, idx:Int) {}
	function remove_components(idx:Int) {}
	function swap_components(from:Int, to:Int) {}

	function include(_comps:Array<Class<Dynamic>>) {

		var ct:ComponentType;
		for (c in _comps) {
			ct = cm.get_type(c);
			include_flags.enable(ct.id);
			include_flags_count++;
		}

	}

	function exclude(_comps:Array<Class<Dynamic>>) {

		var ct:ComponentType;
		for (c in _comps) {
			ct = cm.get_type(c);
			exclude_flags.enable(ct.id);
			exclude_flags_count++;
		}

	}

	// function one(_comps:Array<Class<Dynamic>>) {

	// 	var ct:ComponentType;
	// 	for (c in _comps) {
	// 		ct = cm.get_type(c);
	// 		one_flags.enable(ct.id);
	// 		one_flags_count++;
	// 	}

	// }

	function check(e:Entity) {

		if(!entities.has(e)) {
			if(_match_entity(e)) {
				_add(e);
			}
		} else if(!_match_entity(e)) {
			_remove(e);
		}
		
	}

	inline function _add(e:Entity) {

		entities.add_unsafe(e);

		comp_idx[e.id] = count;
		ent_id[count] = e.id;
		add_components(e, count);
		count++;

		onadded.emit(e);

	}

	inline function _remove(e:Entity) {

		onremoved.emit(e);

		var rem_id:Int = comp_idx[e.id];
		var last_idx:Int = count-1;
		if(rem_id < last_idx) {
			var swap_id:Int = ent_id[last_idx];
			swap_components(last_idx, rem_id);
			comp_idx[swap_id] = rem_id; 
			ent_id[rem_id] = swap_id;
		}
		comp_idx[e.id] = -1;
		ent_id[last_idx] = 0;
		remove_components(last_idx);
		count--;

		entities.remove_unsafe(e);

	}

	@:access(clay.core.ecs.Components)
	function _match_entity(e:Entity):Bool {

		var entity_flags = cm.flags[e.id];

		if(entity_flags == null) {
			return false;
		}

		if(include_flags_count > 0 && !entity_flags.contains(include_flags)) {
			return false;
		}

		if(exclude_flags_count > 0 && exclude_flags.intersects(entity_flags)) {
			return false;
		}

		// if(one_flags_count > 0 && !one_flags.intersects(entity_flags)) {
		// 	return false;
		// }

		return true;

	}

	@:access(clay.Entity)
	function empty() {

		var eid:Int = 0;
		for (i in 0...count) {
			eid = ent_id[i];
			comp_idx[eid] = -1;
			ent_id[i] = 0;
			remove_components(i);
		}
		entities.reset();
		count = 0;

	}

	inline function get_length():Int {

		return entities.length;
		
	}

	@:noCompletion public function toString() {

		var _list = []; 

		for (i in this.iterator()) {
			_list.push(i.id);
		}

		return '$name: [${_list.join(", ")}]';

	}

	@:noCompletion public inline function iterator():EntityVectorIterator {

		return entities.iterator();

	}


}


typedef Exclude<T> = T;
// typedef One<T> = T;
