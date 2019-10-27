package clay.audio.dsp;


import kha.arrays.Float32Array;


class FloatRingBuffer {


	public var length(get, never):Int;

	var _buffer:Float32Array;
	var _pos:Int;


	public function new(length:Int) {
		
		_pos = 0;
		_buffer = new Float32Array(length);

		for (i in 0...length) { // cpp target not 0 ?
			_buffer[i] = 0;
		}

	}

	public inline function insert(v:Float) {
		
		_buffer[_pos] = v;
		shift(1);

	}

	public inline function get(i:Int):Float {

		return _buffer[modLength(getIndex(i))];
		
	}

	public inline function set(i:Int, v:Float) {

		_buffer[modLength(getIndex(i))] = v;
		
	}

	public inline function read():Float {

		return _buffer[_pos];
		
	}

	public inline function shift(n:Int) {
		
		_pos = modLength(_pos+n);

	}

	public function clear() {

		for (i in 0..._buffer.length) {
			_buffer[i] = 0;
		}
		
		_pos = 0;

	}

	inline function modLength(i:Int):Int {
		
		return clay.utils.Mathf.mod(i, _buffer.length);

	}

	inline function getIndex(i:Int):Int {

		return _pos + i;
		
	}

	inline function get_length():Int {
		
		return _buffer.length;

	}


}


