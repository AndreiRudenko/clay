package clay.ds;


// https://github.com/eliasku/ecx/blob/develop/src/ecx/ds/CInt32RingBuffer.hx
// https://github.com/zeliard/Dispatcher/blob/master/JobDispatcher/ObjectPool.h

#if js
private typedef IntArray = js.html.Int32Array;
#else
private typedef IntArray = haxe.ds.Vector<Int>;
#end


class IntBuffer {


	public var length(get, never):Int;

	var _buffer:IntArray;
	var _mask:Int;
	var _head:Int = 0;
	var _tail:Int = 0;
	var _used:Int = 0;


	public function new(capacity:Int) {

		_mask = capacity - 1;

		#if clay_debug
			if(capacity == 0) throw 'non-zero capacity is required';
			if((_mask & capacity) != 0) throw 'capacity $capacity must be power of two';
		#end

		_buffer = new IntArray(capacity);
		
		for (i in 0...capacity) {
			_buffer[i] = i;
		}

	}

	public inline function pop():Int {

		if(_used > _mask) {
			throw('Out of ids, max allowed ${_mask+1}');
		}
		
		var popAt = _head;
		_head = popAt + 1;
		_head &= _mask;

		_used++;

		return _buffer[popAt];

	}

	public inline function push(value:Int) {

		var placeAt = _tail;
		_buffer[placeAt] = value;
		++placeAt;
		_tail = placeAt & _mask;

		_used--;

	}

	public inline function clear() {

		_head = 0;
		_tail = 0;
		_buffer = new IntArray(_mask + 1);
		for (i in 0..._buffer.length) {
			_buffer[i] = i;
		}
		_used = 0;

	}

	inline function get_length() {

		return _buffer.length;

	}
	

}