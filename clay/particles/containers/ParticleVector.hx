package clay.particles.containers;


import clay.particles.core.Particle;
import haxe.ds.Vector;


@:final @:unreflective @:dce
class ParticleVector {


	public var length(default, null):Int;
	public var capacity(default, null):Int;

	public var indexes(default, null):Vector<Int>;
	public var buffer(default, null):Vector<Int>;
	var wrap_index:Int = 0;


	public inline function new(_capacity:Int) {

		length = 0;
		capacity = _capacity;
		
		indexes = new Vector(capacity);
		buffer = new Vector(capacity);

		for (i in 0...capacity) {
			indexes[i] = i;
			buffer[i] = i;
		}

	}

	@:arrayAccess
	public inline function get(index:Int):Particle {

		return new Particle(buffer[index]);

	}

	public inline function ensure():Particle {

		var p:Particle = new Particle(buffer[length]);
		length++;

		return p;

	}

	public inline function wrap():Particle {

		var last_idx:Int = length - 1;
		swap_from_buffer(wrap_index, last_idx);
		wrap_index++;
		wrap_index %= capacity-1;

		return new Particle(buffer[last_idx]);

	}

	public inline function remove(p:Particle) {

		var idx:Int = indexes[p.id];

		var last_idx:Int = length - 1;
		if(idx != last_idx) {
			swap_from_buffer(idx, last_idx);
		}

		length--;

	}

	public inline function reset() {

		for (i in 0...capacity) {
			indexes[i] = i;
			buffer[i] = i;
		}

		length = 0;

	}

	@:access(clay.particles.ParticleVector)
	public function for_each(f:Particle->Void) {
		
		for (i in buffer) {
			f(new Particle(i));
		}

	}

	inline function swap_from_buffer(a:Int, b:Int) {

		var idx_a:Int = buffer[a];
		var idx_b:Int = buffer[b];

		indexes[idx_a] = b;
		indexes[idx_b] = a;
		buffer[a] = idx_b;
		buffer[b] = idx_a;
		
	}

	inline function toString() {

		var _list = []; 

		for (i in this.iterator()) {
			_list.push(i.id);
		}

		return '[${_list.join(", ")}]';

	}

	public inline function iterator():ParticleVectorIterator {

		return new ParticleVectorIterator(this);

	}


}


@:final @:unreflective @:dce
@:access(clay.particles.ParticleVector)
class ParticleVectorIterator {


	public var index:Int;
	public var end:Int;
	public var data:Vector<Int>;


	public inline function new(_vector:ParticleVector) {

		index = 0;
		end = _vector.length;
		data = _vector.buffer;

	}

	public inline function hasNext():Bool {

		return index != end;

	}

	@:access(clay.Particle)
	public inline function next():Particle {

		return new Particle(data[index++]);

	}


}

