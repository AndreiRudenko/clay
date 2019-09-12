package clay.ds;


import haxe.ds.Vector;

// dynamic pool
@:generic
class Pool<T> {


	public var items:Vector<T>;
	public var create_func:()->T;
	public var size_limit:Int;
	public var size:Int;


	public function new(_init_size:Int, _size_limit:Int = 0, create_callback:()->T){

		size_limit = _init_size > _size_limit ? _init_size : _size_limit;
		size = _init_size;

		items = new Vector(size_limit);

		create_func = create_callback;

		for (i in 0...size) {
			items[i] = create_func();
		}

	}

	public inline function get():T {

		if(size > 0) {
			size--;
			var item:T = items[size];
			items[size] = null;
			return item;
		}

		return create_func();

	}

	public inline function put(item:T) {

		if(size < size_limit) {
			items[size] = item;
			size++;
		}

	}

}

