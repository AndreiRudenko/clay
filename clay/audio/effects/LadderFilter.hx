package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;


class LadderFilter extends AudioEffect {


	public var cutoff   	(default, set): Float;
	public var resonance	(default, set): Float;

	var stage_l: Array<Float>;
	var stage_r: Array<Float>;
	var delay_l: Array<Float>;
	var delay_r: Array<Float>;

	var p: Float;
	var k: Float;
	var t1: Float;
	var t2: Float;
	var r: Float;

	var sample_rate: Float;


	public function new(_cut: Float, _res: Float, _sample_rate: Int = 44100) {

		stage_l = [0,0,0,0];
		stage_r = [0,0,0,0];
		delay_l = [0,0,0,0];
		delay_r = [0,0,0,0];

		p = 0;
		k = 0;
		t1 = 0;
		t2 = 0;

		sample_rate = _sample_rate;

		cutoff = _cut;
		resonance = _res;

	}

	override function process(samples: Int, buffer: kha.arrays.Float32Array, sample_rate: Int) {

		for (i in 0...Std.int(samples/2)) {
			buffer[i*2] = filter(buffer[i*2], stage_l, delay_l);
			buffer[i*2+1] = filter(buffer[i*2+1], stage_r, delay_r);
		}

	}

	function filter(input: Float, stage: Array<Float>, delay: Array<Float>):Float {

		var x = input - r * stage[3];

		// Four cascaded one-pole filters (bilinear transform)
		stage[0] = x * p + delay[0]  * p - k * stage[0];
		stage[1] = stage[0] * p + delay[1] * p - k * stage[1];
		stage[2] = stage[1] * p + delay[2] * p - k * stage[2];
		stage[3] = stage[2] * p + delay[3] * p - k * stage[3];
		
		// Clipping band-limited sigmoid
		stage[3] -= (stage[3] * stage[3] * stage[3]) / 6.0;
		
		delay[0] = x;
		delay[1] = stage[0];
		delay[2] = stage[1];
		delay[3] = stage[2];

		return stage[3];
	}

	public function calc_coef() {
		
		var c = 2.0 * cutoff / sample_rate;

		p = c * (1.8 - 0.8 * c);
		k = 2.0 * Math.sin(c * Math.PI * 0.5) - 1.0;
		t1 = (1.0 - p) * 1.386249;
		t2 = 12.0 + t1 * t1;

		r = resonance * (t2 + 6.0 * t1) / (t2 - 6.0 * t1);

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