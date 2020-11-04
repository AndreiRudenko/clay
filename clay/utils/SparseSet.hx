package clay.utils;

import haxe.ds.Vector;

class SparseSet {

	public var used(default, null):Int = 0;
	public final capacity:Int;

	var _sparse:Vector<Int>;
	var _dense:Vector<Int>;

	public function new(capacity:Int) {
		this.capacity = capacity;

		_sparse = new Vector(capacity);
		_dense  = new Vector(capacity);

		for (i in 0...capacity) {
			_sparse[i] = -1;
			_dense[i] = -1;
		}
	}

	public function has(num:Int):Bool {
		return _dense[_sparse[num]] == num;
	}

	public function insert(num:Int) {
		_dense[used] = num;
		_sparse[num] = used;

		used++;
	}

	public function remove(num:Int) {
		final temp = _dense[used-1];
		_dense[_sparse[num]] = temp;
		_sparse[temp] = _sparse[num];

		used--;
	}

	public inline function getDense(idx:Int) {
		return _dense[idx];
	}

	public inline function getSparse(num:Int) {
		return _sparse[num];
	}

	public function clear() {
		while(used > 0) {
			used--;
			_sparse[_dense[used]] = -1;
			_dense[used] = -1;
		}
	}

}
