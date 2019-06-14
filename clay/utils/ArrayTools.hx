package clay.utils;


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

	public static function insert_sorted_key<T>(list:Array<T>, key:T, compare:T->T->Int):Void {

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
/*
	public static function merge_sort<T>(a:Array<T>, l:Int, r:Int, compare:T->T->Int, ?aux:Array<T>) {

		if(aux == null) {
			aux = [];
		}
		
		sort(a, aux, l, r);
		
	}
	
	static function sort<T>(a:Array<T>, aux:Array<T>, l:Int, r:Int) { 
		
		if (l < r) {
			
			var m = Std.int(l + (r - l) / 2);
			_sort(a, aux, l, m);
			_sort(a, aux, m + 1, r);
			_merge(a, aux, l, m, r);

		}

	}

	inline static function merge<T>(a:Array<T>, aux:Array<T>, l:Int, m:Int, r:Int, compare:T->T->Int) { 

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
*/

}