package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;

// https://github.com/ddiakopoulos/MoogLadders/blob/master/src/ImprovedModel.h

class LadderFilter2 extends AudioEffect {


	public var cutoff(default, set):Float;
	public var resonance(default, set):Float;

	var vL:Array<Float>;
	var dvL:Array<Float>;
	var tvL:Array<Float>;

	var vR:Array<Float>;
	var dvR:Array<Float>;
	var tvR:Array<Float>;

	var x:Float;
	var g:Float;
	var drive:Float;

	var sampleRate:Float;
	var vt:Float = 0.312; // Thermal voltage (26 milliwats at room temperature)


	public function new(_cut:Float, _res:Float, _drive:Float = 1, _sampleRate:Int = 44100) {

		vL = [0,0,0,0];
		dvL = [0,0,0,0];
		tvL = [0,0,0,0];
		vR = [0,0,0,0];
		dvR = [0,0,0,0];
		tvR = [0,0,0,0];

		x = 0;
		g = 0;
		drive = _drive;

		sampleRate = _sampleRate;

		cutoff = _cut;
		resonance = _res;

	}

	override function process(samples:Int, buffer:kha.arrays.Float32Array, sampleRate:Int) {

		for (i in 0...Std.int(samples/2)) {
			buffer[i*2] = filter(buffer[i*2], vL, dvL, tvL);
			buffer[i*2+1] = filter(buffer[i*2+1], vR, dvR, tvR);
		}

	}

	function filter(input:Float, v:Array<Float>, dv:Array<Float>, tv:Array<Float>):Float {

			var dv0 = -g * (tanh((drive * input + resonance * v[3]) / (2.0 * vt)) + tv[0]);
			v[0] += (dv0 + dv[0]) / (2.0 * sampleRate);
			dv[0] = dv0;
			tv[0] = tanh(v[0] / (2.0 * vt));
			
			var dv1 = g * (tv[0] - tv[1]);
			v[1] += (dv1 + dv[1]) / (2.0 * sampleRate);
			dv[1] = dv1;
			tv[1] = tanh(v[1] / (2.0 * vt));
			
			var dv2 = g * (tv[1] - tv[2]);
			v[2] += (dv2 + dv[2]) / (2.0 * sampleRate);
			dv[2] = dv2;
			tv[2] = tanh(v[2] / (2.0 * vt));
			
			var dv3 = g * (tv[2] - tv[3]);
			v[3] += (dv3 + dv[3]) / (2.0 * sampleRate);
			dv[3] = dv3;
			tv[3] = tanh(v[3] / (2.0 * vt));
			
			return v[3];

	}


	inline function tanh(num:Float):Float {

		return (Math.exp(num) - Math.exp(-num)) / (Math.exp(num) + Math.exp(-num));

	}

	public function calcCoef() {
		
		x = (Math.PI * cutoff) / sampleRate;
		g = 4.0 * Math.PI * vt * cutoff * (1.0 - x) / (1.0 + x);

	}

	function set_cutoff(v:Float):Float {

		cutoff = v;
		calcCoef();

		return cutoff;

	}

	function set_resonance(v:Float):Float {

		resonance = v;
		calcCoef();

		return resonance;

	}


}