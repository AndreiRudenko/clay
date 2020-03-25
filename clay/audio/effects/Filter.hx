package clay.audio.effects;

import clay.utils.Mathf;
import clay.audio.Sound;
import clay.audio.Audio;

class Filter extends AudioEffect {

	public var cutoff(default, set):Float;
	public var resonance(default, set):Float;
	public var filterType:FilterType;

	var freq:Float;
	var damp:Float;

	var sampleRate:Float;

	var f:Array<Float>;

	public function new(type:FilterType, cutoff:Float, resonance:Float, sampleRate:Int = 44100) {
		filterType = type;

		f = [];

		f[0] = 0;
		f[1] = 0;
		f[2] = 0;
		f[3] = 0;

		freq = 0;
		damp = 0;

		this.sampleRate = sampleRate;

		this.cutoff = cutoff;
		this.resonance = resonance;

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
		damp = Math.min(2 * (1 - Math.pow(resonance, 0.25)), Math.min(2, 2/freq - freq*0.5));
	}

	function set_cutoff(v:Float):Float {
		Audio.mutexLock();
		cutoff = v;
		calcCoef();
		Audio.mutexUnlock();

		return cutoff;
	}

	function set_resonance(v:Float):Float {
		Audio.mutexLock();
		resonance = Mathf.clamp(v, 0, 1);
		calcCoef();
		Audio.mutexUnlock();

		return resonance;
	}

}

enum abstract FilterType(Int){
	var LOWPASS;
	var HIGHPASS;
	var BANDPASS;
	var NOTCH;
}