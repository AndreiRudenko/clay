package clay.ds;


#if js
private typedef IntArray = js.html.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end

// 0..3
abstract Uint2Vector(IntArray) from IntArray {
	

	public inline function new(count:Int) {
	
		this = new IntArray(Math.ceil(count / 16));
	
	}

	@:arrayAccess
	public inline function get(i:Int):UInt {

		return ((1 << 2) - 1) & (this[i >> 4] >> (i*2));
	
	}

	@:arrayAccess
	public inline function set(i:Int, v:UInt) {

		var adress:Int = i >> 4;
		var _i:Int = i*2;
		var cv:Int = this[adress] & ~(((1 << _i+1) ^ (1 << _i))) // clear
		this[adress] = cv | (v << _i) // set
	
	}
	
	public inline function for_each(cb:Int->Int->Void) {

		var p:Int = 0;
		var bitset:Int = 0;
		var bsv:Int = 0;
		for (i in 0...this.length) {
			p = i * 32;
			bitset = this[i];
			while (bitset != 0) {
				bsv = bitset & 0x3;
				if (bsv != 0) {
					cb(p, bsv);
				}
				bitset >>= 2;
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

		for (i in 0...(this.length << 4)) {
			_list.push(get(i));
		}

		return '[${_list.join(", ")}]';

	}

}
