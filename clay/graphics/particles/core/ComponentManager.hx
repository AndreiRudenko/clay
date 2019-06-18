package clay.graphics.particles.core;


import haxe.macro.Context;
import haxe.macro.Expr;
// import haxe.macro.Type;
import clay.utils.macro.MacroUtils;

import clay.graphics.particles.core.Components;
// import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.core.ParticleVector;


class ComponentManager {


	var _capacity:Int;
	var _components:Array<Components<Dynamic>>;


	public function new(capacity:Int) {

		_capacity = capacity;
		_components = [];

	}

	public macro function get<T>(self:Expr, component_class:ExprOf<Class<T>>):ExprOf<Components<T>> {

		var tp = MacroUtils.get_class_typepath(Context.typeof(component_class));

		return macro {
			var comps = $self._get($component_class);
			if(comps != null) {
				comps;
			} else {
				$self._set(
					particles, 
					$component_class, 
					function() {
						return new $tp();
					}
				);
			}
		};

	}

	@:noCompletion public function _get<T>(_component_class:Class<T>):Components<T> {

		return cast get_components(Type.getClassName(_component_class));

	}

	@:noCompletion public function _set<T>(_particles:ParticleVector, _component_class:Class<T>, _f:Void->T):Components<T> {

		var cname:String = Type.getClassName(_component_class);
		var cp:Components<T> = cast get_components(cname);

		if(cp == null) {
			cp = new Components<T>(cname, _capacity);
			_components.push(cp);
		} else {
			if(cp.length > 0) {
				throw('type: $cname components is not empty');
			}
		}

		for (i in 0..._particles.capacity) {
			cp.set(i, _f());
		}

		return cp;

	}

	public function remove<T>(_component_class:Class<T>):Bool {

		var cp = get_components(Type.getClassName(_component_class));

		if(cp != null) {
			cp.clear();
			return true;
		}

		return false;

	}

	@:noCompletion public function swap(a:Int, b:Int) {
		
		for (c in _components) {
			c.swap(a, b);
		}

	}

	public function remove_all(id:Int) {

		for (c in _components) {
			c.remove(id);
		}

	}

	public function clear() {

		for (c in _components) {
			c.clear();
		}

	}

	function get_components(name:String) {
		
		for (c in _components) {
			if(c.name == name) {
				return c;
			}
		}
		
		return null;

	}


}