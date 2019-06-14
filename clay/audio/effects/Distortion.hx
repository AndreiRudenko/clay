package clay.audio.effects;



class Distortion extends AudioEffect {


	public var gain: Float;


	public function new(_gain:Float = 1) {

		gain = _gain;

	}

	override function process(samples: Int, buffer: kha.arrays.Float32Array, sample_rate: Int) {

		var x: Float = 0;

		for (i in 0...samples) {
			x = buffer[i] * gain;
			if(x > 0) {
				buffer[i] = 1 - Math.exp(-x);
			} else {
				buffer[i] = -1 + Math.exp(x);

			}
		}

	}


}