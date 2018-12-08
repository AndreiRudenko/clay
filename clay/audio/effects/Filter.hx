package clay.audio.effects;


import clay.math.Mathf;
import clay.utils.Log.*;
import clay.Sound;


class Filter extends AudioEffect {


	public var cutoff   	(default, set): Float;
	public var resonance	(default, set): Float;
	public var filter_type: FilterType;

	var freq: Float;
	var damp: Float;

	var sample_rate: Float;

	var f:Array<Float>;


	public function new(_type: FilterType, _cut: Float, _res: Float, _sample_rate: Int = 44100) {

		filter_type = _type;

		f = [];

		f[0] = 0;
		f[1] = 0;
		f[2] = 0;
		f[3] = 0;

		freq = 0;
		damp = 0;

		sample_rate = _sample_rate;

		cutoff = _cut;
		resonance = _res;

		calc_coef();

	}

	override function process(samples: Int, buffer: kha.arrays.Float32Array, sample_rate: Int) {

		var input:Float = 0;
		var output:Float = 0;
		for (i in 0...samples) {
			input = buffer[i];
			// first pass
			f[3] = input - damp * f[2];
			f[0] = f[0] + freq * f[2];
			f[1] = f[3] - f[0];
			f[2] = freq * f[1] + f[2];
			output = 0.5 * f[filter_type];

			// second pass
			f[3] = input - damp * f[2];
			f[0] = f[0] + freq * f[2];
			f[1] = f[3] - f[0];
			f[2] = freq * f[1] + f[2];
			output += 0.5 * f[filter_type];
			buffer[i] = output;
		}

	}

	function calc_coef() {

		freq = 2 * Math.sin(Math.PI * Math.min(0.25, cutoff/(sample_rate*2)));  
		damp = Math.min(2 * (1 - Math.pow(resonance, 0.25)), Math.min(2, 2/freq - freq * 0.5));

	}

	function set_cutoff(v: Float): Float {

		cutoff = v;
		calc_coef();

		return cutoff;

	}

	function set_resonance(v: Float): Float {

		resonance = Mathf.clamp(v, 0, 1);
		calc_coef();

		return resonance;

	}


}



@:enum abstract FilterType(Int) from Int to Int {

	var lowpass = 0;
	var highpass = 1;
	var bandpass = 2;
	var notch = 3;

}