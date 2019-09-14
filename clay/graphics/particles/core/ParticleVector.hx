package clay.graphics.particles.core;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ComponentManager;
import haxe.ds.Vector;


@:final @:unreflective @:dce
class ParticleVector {


	public var length(default, null):Int;
	public var capacity(default, null):Int;

	public var buffer(default, null):Vector<Particle>;

	var _sorted:Vector<Particle>;
	var _sortTmp:Vector<Particle>;
	var _components:ComponentManager;
	var _wrapIndex:Int = 0;
	var _needSort:Bool = true;


	public inline function new(components:ComponentManager, _capacity:Int) {

		length = 0;
		capacity = _capacity;
		_components = components;
		
		buffer = new Vector(capacity);
		_sorted = new Vector(capacity);

		_sortTmp = new Vector(capacity);

		for (i in 0...capacity) {
			buffer[i] = new Particle(i);
		}

	}

	public inline function get(idx:Int):Particle {

		return buffer[idx];
	    
	}

	public inline function ensure():Particle {

		_needSort = true;

		return buffer[length++];

	}

	public inline function wrap():Particle {

		_needSort = true;

		_wrapIndex %= length - 1;
		var lastIdx:Int = length - 1;
		swap(_wrapIndex, lastIdx);
		_wrapIndex++;

		return buffer[lastIdx];

	}

	public inline function remove(p:Particle) {

		_needSort = true;

		var idx:Int = p.id;

		var lastIdx:Int = length - 1;
		if(idx != lastIdx) {
			swap(idx, lastIdx);
		}

		length--;

	}

	public inline function reset() {

		_needSort = true;

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

	public function sort(compare:(p1:Particle, p2:Particle)->Int):Vector<Particle> {

		if(_needSort) {
			for (i in 0...length) {
				_sorted[i] = buffer[i];
			}

			_sort(_sorted, _sortTmp, 0, length-1, compare);
			_needSort = false;
		}

		return _sorted;

	}
	
	// merge sort
	function _sort(a:Vector<Particle>, aux:Vector<Particle>, l:Int, r:Int, compare:(p1:Particle, p2:Particle)->Int) { 
		
		if (l < r) {
			var m = Std.int(l + (r - l) / 2);
			_sort(a, aux, l, m, compare);
			_sort(a, aux, m + 1, r, compare);
			_merge(a, aux, l, m, r, compare);
		}

	}

	inline function _merge(a:Vector<Particle>, aux:Vector<Particle>, l:Int, m:Int, r:Int, compare:(p1:Particle, p2:Particle)->Int) { 

		var k = l;
		while (k <= r) {
			aux[k] = a[k];
			k++;
		}

		k = l;
		var i = l;
		var j = m + 1;
		while (k <= r) {
			if (i > m) a[k] = aux[j++];
			else if (j > r) a[k] = aux[i++];
			else if (compare(aux[j], aux[i]) < 0) a[k] = aux[j++];
			else a[k] = aux[i++];
			k++;
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

