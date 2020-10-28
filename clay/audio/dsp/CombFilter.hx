package clay.audio.dsp;

import clay.utils.Math;

class CombFilter {

	public var feedback:Float;
	public var damping(default, set):Float;
	public var length(get, never):Int;

	var _buffer:FloatRingBuffer;
	var _filter:Float;
	var _dampingInv:Float;

	public function new(length:Int, feedback:Float = 0, damping:Float = 0) {
		_filter = 0;
		_dampingInv = 0;
		this.feedback = feedback;
		this.damping = damping;
		_buffer = new FloatRingBuffer(length);
	}

	public function process(input:Float):Float {
		var output = _buffer.read();
		_filter = output * _dampingInv + _filter * damping;
		_buffer.insert(input + _filter * feedback);

		return output;
	}

	function set_damping(v:Float):Float {
		damping = Math.clamp(v, 0, 1);
		_dampingInv = 1.0 - damping;

		return damping;
	}

	inline function get_length():Int {
		return _buffer.length;
	}

}


