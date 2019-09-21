package clay.graphics.particles.core;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ComponentManager;
import haxe.ds.Vector;


@:final @:unreflective @:dce
class ParticleVector {


	public var length(default, null):Int;
	public var capacity(default, null):Int;

	public var buffer(default, null):Vector<Particle>;

	var _components:ComponentManager;
	var _wrapIndex:Int = 0;


	public inline function new(components:ComponentManager, _capacity:Int) {

		length = 0;
		capacity = _capacity;
		_components = components;
		
		buffer = new Vector(capacity);

		for (i in 0...capacity) {
			buffer[i] = new Particle(i);
		}

	}

	public inline function get(idx:Int):Particle {

		return buffer[idx];
	    
	}

	public inline function ensure():Particle {

		return buffer[length++];

	}

	public inline function wrap():Particle {

		_wrapIndex %= length - 1;
		var lastIdx:Int = length - 1;
		swap(_wrapIndex, lastIdx);
		_wrapIndex++;

		return buffer[lastIdx];

	}

	public inline function remove(p:Particle) {

		var idx:Int = p.id;

		var lastIdx:Int = length - 1;
		if(idx != lastIdx) {
			swap(idx, lastIdx);
		}

		length--;

	}

	public inline function reset() {

		for (i in 0...capacity) {
			buffer[i].id = i;
		}

		length = 0;

	}

	@:access(clay.graphics.particles.ParticleVector)
	public function forEach(f:(p:Particle)->Void) {
		
		for (p in buffer) {
			f(p);
		}

	}

	inline function swap(a:Int, b:Int) {

		var pa = buffer[a];
		var pb = buffer[b];

		pa.id = b;
		pb.id = a;

		buffer[a] = pb;
		buffer[b] = pa;

		_components.swap(a, b);
		
	}

	inline function toString() {

		var _list = []; 

		for (i in this.iterator()) {
			_list.push(i.id);
		}

		return "[" + _list.join(", ") + "]";

	}

	@noCompletion public inline function iterator():ParticleVectorIterator {

		return new ParticleVectorIterator(buffer, length);

	}

}


@:final @:unreflective @:dce
@:access(clay.graphics.particles.ParticleVector)
class ParticleVectorIterator {


	public var index:Int;
	public var end:Int;
	public var data:Vector<Particle>;


	public inline function new(data:Vector<Particle>, length:Int) {

		index = 0;
		end = length;
		this.data = data;

	}

	public inline function hasNext():Bool {

		return index != end;

	}

	public inline function next():Particle {

		return data[index++];

	}


}

