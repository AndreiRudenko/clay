package clay.audio.dsp;

import clay.Clay;
import clay.utils.Mathf;

class AllPassFilter {

	public var feedback:Float;
	var _buffer:FloatRingBuffer;

	public function new(length:Int, feedback:Float = 0) {
		this.feedback = feedback;
		_buffer = new FloatRingBuffer(length);
	}

	public inline function process(input:Float):Float {
		var delayed = _buffer.read();
		var output = -input + delayed;
		_buffer.insert(input + delayed * feedback);
			
		return output;
	}

}


