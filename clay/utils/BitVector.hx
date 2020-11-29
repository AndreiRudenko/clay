package clay.utils;

// https://github.com/eliasku/ecx/blob/develop/src/ecx/ds/CInt32RingBuffer.hx

#if js
private typedef IntArray = js.lib.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end

abstract BitVector(IntArray) from IntArray {
	
	static public inline var BITS_PER_ELEMENT:Int = 32;
	static public inline var BIT_SHIFT:Int = 5;
	static public inline var BIT_MASK:Int = 0x1F;

	@:pure
	static public inline function address(index:Int):Int {
		return index >>> BIT_SHIFT;
	}

	@:pure
	static public inline function mask(index:Int):Int {
		return 0x1 << (index & BIT_MASK);
	}
	
	public inline function new(count:Int) {
		this = new IntArray(Math.ceil(count / BITS_PER_ELEMENT));
	
		#if neko
		for(i in 0...this.length) {
		    this[i] = 0;
		}
		#end
	}

	public inline function enable(index:Int) {
		this[address(index)] |= mask(index);
	}

	public inline function disable(index:Int) {
		this[address(index)] &= ~(mask(index));
	}

	@:arrayAccess
	public inline function get(index:Int):Bool {
		return (this[address(index)] & mask(index)) != 0;
	}

	@:arrayAccess
	public inline function set(index:Int, value:Bool):Void {
		value ? enable(index) : disable(index);
	}

	public inline function isFalse(index:Int):Bool {
		return (this[address(index)] & mask(index)) == 0;
	}

	public inline function enableIfNot(index:Int):Bool {
		var a = address(index);
		var m = mask(index);
		var v = this[a];
		if((v & m) == 0) {
			this[a] = v | m;
			return true;
		}
		return false;
	}

	public inline function enableAll() {
		for (i in 0...this.length) {
			this[i] = -1;
		}
	}
	
	public function disableAll() {
		for (i in 0...this.length) {
			this[i] = 0;
		}
	}

	public function forEach(cb:(b:Int)->Void) {
		var p:Int = 0;
		var bitset:Int = 0;
		for (i in 0...this.length) {
			p = i * 32;
			bitset = this[i];
			while (bitset != 0) {
				if (bitset & 0x1 == 1) {
					cb(p);
				}
				bitset >>= 1;
				p++;
			}
		}
	}

	public inline function size():Int {
		return this.length << 2;
	}

	inline function toString() {
		var _list = []; 

		for (i in 0...(this.length << BIT_SHIFT)) {
			_list.push(get(i));
		}

		return "[" + _list.join(", ") + "]";
	}

}
