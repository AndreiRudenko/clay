package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;


class Filter extends AudioEffect {


	public var cutoff(default, set):Float;
	public var resonance(default, set):Float;
	public var filterType:FilterType;

	var freq:Float;
	var damp:Float;

	var sampleRate:Float;

	var f:Array<Float>;


	public function new(_type:FilterType, _cut:Float, _res:Float, _sampleRate:Int = 44100) {

		filterType = _type;

		f = [];

		f[0] = 0;
		f[1] = 0;
		f[2] = 0;
		f[3] = 0;

		freq = 0;
		damp = 0;

		sampleRate = _sampleRate;

		cutoff = _cut;
		resonance = _res;

		calcCoef();

	}

	override function process(samples:Int, buffer:kha.arrays.Float32Array, sampleRate:Int) {

		var input:Float = 0;
		var output:Float = 0;
		for (i in 0...samples) {
			input = buffer[i];
			// first pass
			f[3] = input - damp * f[2];
			f[0] = f[0] + freq * f[2];
			f[1] = f[3] - f[0];
			f[2] = freq * f[1] + f[2];
			output = 0.5 * f[filterType];

			// second pass
			f[3] = input - damp * f[2];
			f[0] = f[0] + freq * f[2];
			f[1] = f[3] - f[0];
			f[2] = freq * f[1] + f[2];
			output += 0.5 * f[filterType];
			buffer[i] = output;
		}

	}

	function calcCoef() {

		freq = 2 * Math.sin(Math.PI * Math.min(0.25, cutoff/(sampleRate*2)));  
		damp = Math.min(2 * (1 - Math.pow(resonance, 0.25)), Math.min(2, 2/freq - freq * 0.5));

	}

	function set_cutoff(v:Float):Float {

		cutoff = v;
		calcCoef();

		return cutoff;

	}

	function set_resonance(v:Float):Float {

		resonance = Mathf.clamp(v, 0, 1);
		calcCoef();

		return resonance;

	}


}



@:enum abstract FilterType(Int) from Int to Int {

	var lowpass = 0;
	var highpass = 1;
	var bandpass = 2;
	var notch = 3;

}