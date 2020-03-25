package clay.audio.effects;

import clay.audio.Audio;

class Distortion extends AudioEffect {

	public var gain(get, set):Float;
	var _gain:Float;

	public function new(gain:Float = 1) {
		_gain = gain;
	}

	override function process(samples:Int, buffer:kha.arrays.Float32Array, sampleRate:Int) {
		var x:Float = 0;

		for (i in 0...samples) {
			x = buffer[i] * gain;
			if(x > 0) {
				buffer[i] = 1 - Math.exp(-x);
			} else {
				buffer[i] = -1 + Math.exp(x);
			}
		}
	}

	function get_gain():Float {
		Audio.mutexLock();
		var v = _gain;
		Audio.mutexUnlock();

		return v;
	}

	function set_gain(v:Float):Float {
		Audio.mutexLock();
		_gain = v;
		Audio.mutexUnlock();

		return v;
	}

}