package clay.utils;


import haxe.ds.Vector;


class ArrayTools {


	public static inline function clear<T>(array:Array<T>) {
#if cpp
		// splice causes Array allocation, so prefer pop for most arrays
		if (array.length > 256) {
			array.splice(0, array.length);
		} else {
			while (array.length > 0) array.pop();
		}
#else
		untyped array.length = 0;
#end
	}

	public static function shuffle<T>(a:Array<T>) {

		var i:Int = a.length, j:Int, t:T;
		while (--i > 0) {
			t = a[i];
			a[i] = a[j = Clay.random.int(i + 1)];
			a[j] = t;
		}

	}

	public static function insertSortedKey<T>(list:Array<T>, key:T, compare:(a:T, b:T)->Int):Void {

		var result:Int = 0;
		var mid:Int = 0;
		var min:Int = 0;
		var max:Int = list.length - 1;

		while (max >= min) {
			mid = min + Std.int((max - min) / 2);
			result = compare(list[mid], key);
			if (result > 0) max = mid - 1;
			else if (result < 0) min = mid + 1;
			else return;
		}

		list.insert(result > 0 ? mid : mid + 1, key);

	}


}