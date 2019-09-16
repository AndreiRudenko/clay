package clay.ds;


import haxe.ds.Vector;

// dynamic pool
@:generic
class Pool<T> {


	public var items:Vector<T>;
	public var createFunc:()->T;
	public var sizeLimit:Int;
	public var size:Int;


	public function new(initSize:Int, sizeLimit:Int = 0, createCallback:()->T){

		this.sizeLimit = initSize > sizeLimit ? initSize : sizeLimit;
		size = initSize;

		items = new Vector(this.sizeLimit);

		createFunc = createCallback;

		for (i in 0...size) {
			items[i] = createFunc();
		}

	}

	public inline function get():T {

		if(size > 0) {
			size--;
			var item:T = items[size];
			items[size] = null;
			return item;
		}

		return createFunc();

	}

	public inline function put(item:T) {

		if(size < sizeLimit) {
			items[size] = item;
			size++;
		}

	}

}

