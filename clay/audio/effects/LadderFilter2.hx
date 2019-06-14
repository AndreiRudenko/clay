package clay.audio.effects;


import clay.math.Mathf;
import clay.utils.Log.*;
import clay.Sound;

// https://github.com/ddiakopoulos/MoogLadders/blob/master/src/ImprovedModel.h

class LadderFilter2 extends AudioEffect {


	public var cutoff   	(default, set): Float;
	public var resonance	(default, set): Float;

	var v_l: Array<Float>;
	var dv_l: Array<Float>;
	var tv_l: Array<Float>;

	var v_r: Array<Float>;
	var dv_r: Array<Float>;
	var tv_r: Array<Float>;

	var x: Float;
	var g: Float;
	var drive: Float;

	var sample_rate: Float;
	var vt: Float = 0.312; // Thermal voltage (26 milliwats at room temperature)


	public function new(_cut: Float, _res: Float, _drive: Float = 1, _sample_rate: Int = 44100) {

		v_l = [0,0,0,0];
		dv_l = [0,0,0,0];
		tv_l = [0,0,0,0];
		v_r = [0,0,0,0];
		dv_r = [0,0,0,0];
		tv_r = [0,0,0,0];

		x = 0;
		g = 0;
		drive = _drive;

		sample_rate = _sample_rate;

		cutoff = _cut;
		resonance = _res;

	}

	override function process(samples: Int, buffer: kha.arrays.Float32Array, sample_rate: Int) {

		for (i in 0...Std.int(samples/2)) {
			buffer[i*2] = filter(buffer[i*2], v_l, dv_l, tv_l);
			buffer[i*2+1] = filter(buffer[i*2+1], v_r, dv_r, tv_r);
		}

	}

	function filter(input: Float, v: Array<Float>, dv: Array<Float>, tv: Array<Float>):Float {

			var dv0 = -g * (tanh((drive * input + resonance * v[3]) / (2.0 * vt)) + tv[0]);
			v[0] += (dv0 + dv[0]) / (2.0 * sample_rate);
			dv[0] = dv0;
			tv[0] = tanh(v[0] / (2.0 * vt));
			
			var dv1 = g * (tv[0] - tv[1]);
			v[1] += (dv1 + dv[1]) / (2.0 * sample_rate);
			dv[1] = dv1;
			tv[1] = tanh(v[1] / (2.0 * vt));
			
			var dv2 = g * (tv[1] - tv[2]);
			v[2] += (dv2 + dv[2]) / (2.0 * sample_rate);
			dv[2] = dv2;
			tv[2] = tanh(v[2] / (2.0 * vt));
			
			var dv3 = g * (tv[2] - tv[3]);
			v[3] += (dv3 + dv[3]) / (2.0 * sample_rate);
			dv[3] = dv3;
			tv[3] = tanh(v[3] / (2.0 * vt));
			
			return v[3];

	}


	inline function tanh(num: Float): Float {

		return (Math.exp(num) - Math.exp(-num)) / (Math.exp(num) + Math.exp(-num));

	}

	public function calc_coef() {
		
		x = (Math.PI * cutoff) / sample_rate;
		g = 4.0 * Math.PI * vt * cutoff * (1.0 - x) / (1.0 + x);

	}

	function set_cutoff(v: Float): Float {

		cutoff = v;
		calc_coef();

		return cutoff;

	}

	function set_resonance(v: Float): Float {

		resonance = v;
		calc_coef();

		return resonance;

	}


}