package clay.utils;

import haxe.ds.Vector;

// dynamic pool
@:generic
class DynamicPool<T> {

	public var items:Vector<T>;
	public var createFunc:()->T;
	public var sizeLimit:Int;
	public var size:Int;

	public function new(sizeLimit:Int, createCallback:()->T, populate:Bool = true){
		this.sizeLimit = sizeLimit;
		size = 0;

		items = new Vector(this.sizeLimit);

		createFunc = createCallback;

		if(populate) {
			for (i in 0...sizeLimit) {
				items[i] = createFunc();
			}
			size= sizeLimit;
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