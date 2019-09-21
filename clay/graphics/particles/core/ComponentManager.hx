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

	public macro function get<T>(self:Expr, componentClass:Expr):ExprOf<Components<T>> {

		var type = Context.typeof(componentClass);

		var cname = switch (componentClass.expr) {
			case EConst(c):
				switch (c) {
					case CIdent(s): s;
					default: '';
				}
			default: '';
		}

		var typeName = '';

		switch (type) {
			case TType(ref, types):
				var name = ref.get().name;
				if(StringTools.startsWith(name, 'Abstract')) {
					typeName = name.substring(9, name.length-1);
				} else if(StringTools.startsWith(name, 'Class')) {
					typeName = name.substring(6, name.length-1);
				} else {
					throw ('$name must be Class<T> or Abstract');
				}

			default: throw 'Invalid type';
		}


		switch (typeName) {
			case 'Bool': 
				return macro {
					var comps = $self._getBool($v{cname});
					if(comps != null) {
						comps;
					} else {
						$self._setBool(particles, $v{cname}, function() {return false;});
					}
				}
			case 'Int': 
				return macro {
					var comps = $self._getInt($v{cname});
					if(comps != null) {
						comps;
					} else {
						$self._setInt(particles, $v{cname}, function() {return 0;});
					}
				}
			case 'Float': 
				return macro {
					var comps = $self._getFloat($v{cname});
					if(comps != null) {
						comps;
					} else {
						$self._setFloat(particles, $v{cname}, function() {return 0;});
					}
				}
			case 'String': 
				return macro {
					var comps = $self._getString($v{cname});
					if(comps != null) {
						comps;
					} else {
						$self._setString(particles, $v{cname}, function() {return '';});
					}
				}
			default: 
	    		var tp = MacroUtils.getClassTypePath(type);
				return macro {
					var comps = $self._getClass($v{cname}, $componentClass);
					if(comps != null) {
						comps;
					} else {
						$self._setClass(
							particles, 
							$v{cname}, 
							$componentClass, 
							function() {
								return new $tp();
							}
						);
					}
				}
		}

	}

	public function remove<T>(_componentClass:Class<T>):Bool {

		var cp = getComponents(Type.getClassName(_componentClass));

		if(cp != null) {
			cp.clear();
			return true;
		}

		return false;

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

	@:noCompletion public function swap(a:Int, b:Int) {
		
		for (c in _components) {
			c.swap(a, b);
		}

	}

	@:noCompletion public function _getBool(cn:String):Components<Bool> return cast getComponents(cn);
	@:noCompletion public function _getInt(cn:String):Components<Int> return cast getComponents(cn);
	@:noCompletion public function _getFloat(cn:String):Components<Float> return cast getComponents(cn);
	@:noCompletion public function _getString(cn:String):Components<String> return cast getComponents(cn);
	@:noCompletion public function _getClass<T>(cn:String, _:Class<T>):Components<T> return cast getComponents(cn);

	@:noCompletion public function _setBool<T>(p:ParticleVector, cn:String, f:()->Bool):Components<Bool> return createComponents(p, cn, f);
	@:noCompletion public function _setInt<T>(p:ParticleVector, cn:String, f:()->Int):Components<Int> return createComponents(p, cn, f);
	@:noCompletion public function _setFloat<T>(p:ParticleVector, cn:String, f:()->Float):Components<Float> return createComponents(p, cn, f);
	@:noCompletion public function _setString<T>(p:ParticleVector, cn:String, f:()->String):Components<String> return createComponents(p, cn, f);
	@:noCompletion public function _setClass<T>(p:ParticleVector, cn:String, t:Class<T>, f:()->T):Components<T> return createComponents(p, cn, f);

	function createComponents<T>(particles:ParticleVector, componentName:String, f:()->T):Components<T> {
		
		var cp:Components<T> = cast getComponents(componentName);

		if(cp == null) {
			cp = new Components<T>(componentName, _capacity);
			_components.push(cp);
		} else {
			if(cp.length > 0) {
				throw("type: " + componentName + " components is not empty");
			}
		}

		for (i in 0...particles.capacity) {
			cp.set(i, f());
		}

		return cp;

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