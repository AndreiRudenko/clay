package clay;


import clay.Entity;
import clay.core.ecs.Components;
import clay.core.ecs.ComponentType;
import haxe.ds.Vector;


@:access(clay.core.ecs.Components)
class ComponentMapper<T> {


	var manager:Components;
	var type:ComponentType;
	var components:Vector<T>;
	

	public function new(_manager:Components, _ctype:ComponentType) {

		type = _ctype;
		manager = _manager;
		components = new Vector(manager.world.entities.capacity);

	}

	public function set(e:Entity, c:T):T {

		_set(e, c);

		manager.entity_changed(e);

		return c;

	}

	public function copy(from:Entity, to:Entity) {

		var c = components[from.id];
		components[to.id] = c;
		manager.flags[to.id].enable(type.id);
		manager.entity_changed(to);

	}

	public inline function get(e:Entity):T {

		return components[e.id];

	}

	public inline function has(e:Entity):Bool {
		
		return components[e.id] != null;

	}

	public function remove(e:Entity):Bool {

		var _has:Bool = has(e);
		
		if(_has) {
			manager.flags[e.id].disable(type.id);
			manager.entity_changed_delayed(e);
			components[e.id] = null;
		}

		return _has;

	}

	@:access(clay.Entity)
	public function clear() {
		
		for (i in 0...components.length) {
			if(components[i] != null) {
				manager.flags[i].disable(type.id);
				manager.entity_changed_delayed(new Entity(i));
				components[i] = null;
			}
		}

	}

	@:noCompletion public inline function _set(e:Entity, c:T) {
		
		remove(e);

		components[e.id] = c;
		manager.flags[e.id].enable(type.id);

	}

	@:noCompletion public function toString() {

		var cname:String = '';
		for (k in manager.types.keys()) {
			var ct = manager.types.get(k);
			if(ct.id == type.id) {
				cname = k;
				break;
			}
		}

		var entslen:Int = manager.world.entities.capacity;
		var comps:Int = 0;

		var arr = [];
		for (j in 0...entslen) {
			if(components[j] != null) {
				arr.push(j);
				comps++;
			}
		}

		return '${cname}: count: $comps [${arr.join(", ")}]';

	}


}


