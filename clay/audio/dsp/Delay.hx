package clay.audio.dsp;


import clay.Clay;
import clay.utils.Mathf;

// Simple delay

class Delay {


	public var feedback:Float;

	var _buffer:FloatRingBuffer;


	public function new(length:Int, feedback:Float = 0) {
		
		this.feedback = feedback;
		_buffer = new FloatRingBuffer(length);
		
	}

	public inline function process(input:Float):Float {

		var output = _buffer.read();
		_buffer.insert(input * feedback);

		return output;

	}


}

