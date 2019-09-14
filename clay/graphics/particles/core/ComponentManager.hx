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

	public macro function get<T>(self:Expr, componentClass:ExprOf<Class<T>>):ExprOf<Components<T>> {

		var tp = MacroUtils.getClassTypePath(Context.typeof(componentClass));

		return macro {
			var comps = $self._get($componentClass);
			if(comps != null) {
				comps;
			} else {
				$self._set(
					particles, 
					$componentClass, 
					function() {
						return new $tp();
					}
				);
			}
		};

	}

	@:noCompletion public function _get<T>(_componentClass:Class<T>):Components<T> {

		return cast getComponents(Type.getClassName(_componentClass));

	}

	@:noCompletion public function _set<T>(_particles:ParticleVector, _componentClass:Class<T>, _f:()->T):Components<T> {

		var cname:String = Type.getClassName(_componentClass);
		var cp:Components<T> = cast getComponents(cname);

		if(cp == null) {
			cp = new Components<T>(cname, _capacity);
			_components.push(cp);
		} else {
			if(cp.length > 0) {
				throw("type: " + cname + " components is not empty");
			}
		}

		for (i in 0..._particles.capacity) {
			cp.set(i, _f());
		}

		return cp;

	}

	public function remove<T>(_componentClass:Class<T>):Bool {

		var cp = getComponents(Type.getClassName(_componentClass));

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

	public function removeAll(id:Int) {

		for (c in _components) {
			c.remove(id);
		}

	}

	public function clear() {

		for (c in _components) {
			c.clear();
		}

	}

	function getComponents(name:String) {
		
		for (c in _components) {
			if(c.name == name) {
				return c;
			}
		}
		
		return null;

	}


}