package clay.ds;


#if js
private typedef IntArray = js.html.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end

// 0..15
abstract Uint4Vector(IntArray) from IntArray {
	

	public inline function new(count:Int) {
	
		this = new IntArray(Math.ceil(count / 8));
	
	}

	@:arrayAccess
	public inline function get(i:Int):UInt {

		return ((1 << 4) - 1) & (this[i >> 3] >> (i*4));
	
	}

	@:arrayAccess
	public inline function set(i:Int, v:UInt) {

		var adress:Int = i >> 3;
		var _i:Int = i*4;
		var cv:Int = this[adress] & ~(((1 << _i+3) ^ (1 << _i))); // clear
		this[adress] = cv | (v << _i); // set
	
	}

	public inline function for_each(cb:Int->Int->Void) {

		var p:Int = 0;
		var bitset:Int = 0;
		var bsv:Int = 0;
		for (i in 0...this.length) {
			p = i * 32;
			bitset = this[i];
			while (bitset != 0) {
				bsv = bitset & 0xf;
				if (bsv != 0) {
					cb(p, bsv);
				}
				bitset >>= 4;
				p++;
			}
		}
	    
	}

	public inline function clear() {

		for (i in 0...this.length) {
			this[i] = 0;
		}
		
	}

	public inline function size():Int {

		return this.length << 2;
	
	}

	inline function toString() {

		var _list = []; 

		for (i in 0...(this.length << 3)) {
			_list.push(get(i));
		}

		return '[${_list.join(", ")}]';

	}

}
