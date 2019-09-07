package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;


class Osc extends AudioChannel {


	// public var cutoff   	(default, set): Float;
	// public var resonance	(default, set): Float;
	public var osc_type     (default, null): OscType;
	public var octave       (default, default): Int = 2;
	public var note         (default, default): Int = 0;

	var octaves: Array<Float> = [27.5, 55, 110, 220, 440, 880, 1760, 3520, 7040, 14080];
	// var notes: Array<Float> = [27.5, 55, 110, 220, 440, 880, 1760, 3520, 7040, 14080];

	var frequency: Float;
	var amplitude: Float = 1;

	public var attack 	(default, null): Float = 0;
	public var hold   	(default, null): Float = 0;
	public var decay  	(default, null): Float = 0;

	var _attack: Float = 0;
	var _hold: Float = 0;
	var _decay: Float = 0;
	var sample_rate: Float;

	var s: Float = 0;
	var samples_processed: Int = 0;
	var d12th_root_of2: Float = Math.pow(2.0, 1.0 / 12.0);

	var f:Array<Float>;



	public function new(_type: OscType = 0, _freq: Float = 440) {

		super();

		osc_type = _type;
		frequency = _freq;
		amplitude = 1;

		attack = 0.01;
		hold = 0;
		decay = 0.5;

		sample_rate = Clay.audio.sample_rate;

		calc_env();

	}

	function calc_env() {

		_attack = attack * sample_rate;
		_hold = _attack + hold * sample_rate;
		_decay = _hold + decay * sample_rate;

	}

	override function process(data: kha.arrays.Float32Array, samples: Int) {

		if(amplitude <= 0) {
			return;
		}

		frequency = octaves[octave] * Math.pow(d12th_root_of2, note);

		var snd:Float = 0;
		for (i in 0...Std.int(samples/2)) {
			s += frequency / sample_rate;
			samples_processed++;

			env();

			snd = triangle(s) * amplitude;

			data[i*2] += snd;
			data[i*2+1] += snd;
		}

	}

	public function note_on() {

		amplitude = 1;
		samples_processed = 0;
		s = 0;

	}

	public function note_off() {
		
	}

	function env() {

		amplitude = 0;

		if(samples_processed <= _attack && _attack > 0) {
			amplitude = samples_processed / _attack;
		} else if(samples_processed > _attack && samples_processed <= _hold) {
			amplitude = 1;
		} else if(samples_processed > _hold && samples_processed <= _decay) {
			amplitude = 1 - ((samples_processed - _hold) / (_decay - _hold));
		}
		
	}

	function sine(step:Float):Float {

		return Math.sin(2*Math.PI * step);

	}

	function saw(step:Float):Float {

		return 2 * (step - Math.round(step));

	}

	function triangle(step:Float):Float {

		return 1 - 4 * Math.abs(Math.round(step) - step);

	}

	function square(step:Float):Float { // bug

		return step < 0.5 ? 1 : -1;

	}

	function noise(step:Float):Float {

		return Math.random() * 2 - 1;

	}

	// function set_cutoff(v: Float): Float {

	// 	cutoff = v;
	// 	calc_coef();

	// 	return cutoff;

	// }

	// function set_resonance(v: Float): Float {

	// 	resonance = Mathf.clamp(v, 0, 1);
	// 	calc_coef();

	// 	return resonance;

	// }


}



@:enum abstract OscType(Int) from Int to Int {

	var sine = 0;
	var saw = 1;
	var triangle = 2;
	var square = 3;
	var noise = 4;

}