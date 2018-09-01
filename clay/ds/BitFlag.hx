package clay.ds;



#if js
private typedef IntArray = js.html.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end


class BitFlag {


	public var bits(default, null):IntArray;

	
	public function new(capacity:Int) {

		bits = new IntArray(Math.ceil(capacity/32));

	}

	public function flip() {

		for (i in 0...bits.length) {
			bits[i] = ~bits[i];
		}

	}

	public inline function get(i:Int):Bool { 

		var bit:Int = i % 32;
		return (bits[i >> 5] & (1 << bit)) >> bit == 1;
		
	}

	public inline function enable(i:Int) { 

		bits[i >> 5] |= (1 << (i % 32));
		
	}

	public inline function disable(i:Int) { 
		
		bits[i >> 5] &= (~(1 << (i % 32)));
		
	}

	public function and(other:BitFlag) {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			bits[i] &= other.bits[i];
		}

		if(bits.length > len) {
			for (i in len...bits.length) {
				bits[i] = 0;
			}
		}

	}

	public function and_not(other:BitFlag) {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			bits[i] &= ~other.bits[i];
		}

	}

	public function or(other:BitFlag) {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			bits[i] |= other.bits[i];
		}

	}

	public function xor(other:BitFlag) {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			bits[i] ^= other.bits[i];
		}

	}

	public function contains(other:BitFlag):Bool {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			if (bits[i] & other.bits[i] != other.bits[i]) {
				return false;
			}
		}

		return true;

	}

	public function intersects(other:BitFlag):Bool {

		var len:Int = bits.length < other.bits.length ? bits.length : other.bits.length;
		for (i in 0...len) {
			if (bits[i] & other.bits[i] != 0) {
				return true;
			}
		}

		return false;

	}

	public function clear() {
		
		for (i in 0...bits.length) {
			bits[i] = 0;
		}

	}

	@:noCompletion public function toString() {

		var output = "";
		for (b in bits) {
			for (i in 0...32) {
				output = Std.string((b >> i) & 1) + output;
			}
		}
		return output;
	}

	
}