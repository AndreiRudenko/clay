package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;


class LadderFilter extends AudioEffect {


	public var cutoff(default, set):Float;
	public var resonance(default, set):Float;

	var stageL:Array<Float>;
	var stageR:Array<Float>;
	var delayL:Array<Float>;
	var delayR:Array<Float>;

	var p:Float;
	var k:Float;
	var t1:Float;
	var t2:Float;
	var r:Float;

	var sampleRate:Float;


	public function new(_cut:Float, _res:Float, _sampleRate:Int = 44100) {

		stageL = [0,0,0,0];
		stageR = [0,0,0,0];
		delayL = [0,0,0,0];
		delayR = [0,0,0,0];

		p = 0;
		k = 0;
		t1 = 0;
		t2 = 0;

		sampleRate = _sampleRate;

		cutoff = _cut;
		resonance = _res;

	}

	override function process(samples:Int, buffer:kha.arrays.Float32Array, sampleRate:Int) {

		for (i in 0...Std.int(samples/2)) {
			buffer[i*2] = filter(buffer[i*2], stageL, delayL);
			buffer[i*2+1] = filter(buffer[i*2+1], stageR, delayR);
		}

	}

	function filter(input:Float, stage:Array<Float>, delay:Array<Float>):Float {

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

	public function calcCoef() {
		
		var c = 2.0 * cutoff / sampleRate;

		p = c * (1.8 - 0.8 * c);
		k = 2.0 * Math.sin(c * Math.PI * 0.5) - 1.0;
		t1 = (1.0 - p) * 1.386249;
		t2 = 12.0 + t1 * t1;

		r = resonance * (t2 + 6.0 * t1) / (t2 - 6.0 * t1);

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