package clay.audio.effects;



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

		clay.system.Audio.mutexLock();
		var v = _gain;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_gain(v:Float):Float {

		clay.system.Audio.mutexLock();
		_gain = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}
	

}