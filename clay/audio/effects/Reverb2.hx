package clay.audio.effects;


import clay.math.Mathf;
import clay.utils.Log.*;
import clay.Sound;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;


class Reverb2 extends AudioEffect {

	static var FIXED_GAIN: Float = 0.015;

	static var SCALE_WET: Float = 3.0;
	static var SCALE_DAMPENING: Float = 0.4;
	static var SCALE_ROOM: Float = 0.28;
	static var OFFSET_ROOM: Float = 0.7;

	static var STEREO_SPREAD: Int = 23;

	static var COMB_TUNING_L: Array<Int> = [
		1116, 
		1188, 
		1277, 
		1356, 
		1422, 
		1491, 
		1557, 
		1617
	];

	static var COMB_TUNING_R: Array<Int> = [
		1116 + STEREO_SPREAD, 
		1188 + STEREO_SPREAD, 
		1277 + STEREO_SPREAD, 
		1356 + STEREO_SPREAD, 
		1422 + STEREO_SPREAD, 
		1491 + STEREO_SPREAD, 
		1557 + STEREO_SPREAD, 
		1617 + STEREO_SPREAD
	];

	static var ALLPASS_TUNING_L: Array<Int> = [
		556, 
		441, 
		341, 
		225
	];

	static var ALLPASS_TUNING_R: Array<Int> = [
		556 + STEREO_SPREAD,  
		441 + STEREO_SPREAD,  
		341 + STEREO_SPREAD,  
		225 + STEREO_SPREAD
	];

	// amount of dry signal fed into main line
	public var wet      	(get, set): Float;
	public var dampening	(get, set): Float;
	public var room_size	(get, set): Float;
	public var width    	(default, set): Float;
	public var frozen   	(default, set): Bool;
	public var dry          (default, set): Float;


	var _wet: Float;
	var _dampening: Float;
	var _room_size: Float;
	var input_gain: Float;
	var wet0: Float;
	var wet1: Float;

	var combs_l: Array<Comb>;
	var combs_r: Array<Comb>;
	var allpasses_l: Array<AllPass>;
	var allpasses_r: Array<AllPass>;

	var combs_num: Int = 8;
	var allpass_num: Int = 4;


	public function new(_options: Reverb2Options) {

		combs_l = [];
		combs_r = [];
		allpasses_l = [];
		allpasses_r = [];

		for (i in 0...combs_num) {
			combs_l.push(new Comb(COMB_TUNING_L[i]));
			combs_r.push(new Comb(COMB_TUNING_R[i]));
		}

		for (i in 0...allpass_num) {
			allpasses_l.push(new AllPass(ALLPASS_TUNING_L[i]));
			allpasses_r.push(new AllPass(ALLPASS_TUNING_R[i]));
		}

		input_gain = 0;
		wet = def(_options.wet, 1);
		dry = def(_options.dry, 0);
		width = def(_options.width, 0.5);
		dampening = def(_options.dampening, 0.5);
		room_size = def(_options.room_size, 0.5);
		frozen = def(_options.frozen, false);

	}

	override function process(samples: Int, buffer: Float32Array, sample_rate: Int) {

		var in_l: Float;
		var in_r: Float;
		var out_l: Float;
		var out_r: Float;
		var input_mixed: Float;

		for (i in 0...Std.int(samples/2)) {
			in_l = buffer[i*2];
			in_r = buffer[i*2+1];
			input_mixed = (in_l + in_r) * FIXED_GAIN * input_gain;
			out_l = 0;
			out_r = 0;

			for (i in 0...combs_num) {
				out_l += combs_l[i].tick(input_mixed);
				out_r += combs_r[i].tick(input_mixed);
			}

			for (i in 0...allpass_num) {
				out_l += allpasses_l[i].tick(out_l);
				out_r += allpasses_r[i].tick(out_r);
			}

			// trace(out_l);
			buffer[i*2] = out_l * wet0 + out_r * wet1 + in_l * dry;
			buffer[i*2+1] = out_r * wet0 + out_l * wet1 + in_r * dry;

            // out.0 * self.wet_gains.0 + out.1 * self.wet_gains.1 + input.0 * self.dry,
            // out.1 * self.wet_gains.0 + out.0 * self.wet_gains.1 + input.1 * self.dry,
		}

	}

	function update_wet_gains() {
		
		wet0 = _wet * SCALE_WET * (width / 2.0 + 0.5);
		wet1 = _wet * SCALE_WET * ((1.0 - width) / 2.0);

	}
	
	function update_combs() {

		var feed = frozen ? 1 : _room_size;
		var damp = frozen ? 0 : _dampening;

		for (i in 0...combs_num) {
			combs_l[i].feedback = feed;
			combs_r[i].feedback = feed;
			combs_l[i].dampening = damp;
			combs_r[i].dampening = damp;
		}

	}

	function get_wet(): Float {

		return _wet / SCALE_WET;

	}

	function set_wet(v: Float): Float {

		_wet = Mathf.clamp(v, 0, 1) * SCALE_WET;
		
		update_wet_gains();

		return _wet;

	}

	function set_dry(v: Float): Float {

		dry = Mathf.clamp(v, 0, 1);
		
		return dry;

	}

	function set_width(v: Float): Float {

		width = Mathf.clamp(v, 0, 1);

		update_wet_gains();

		return width;

	}

	function get_dampening(): Float {

		return _dampening / SCALE_DAMPENING;

	}

	function set_dampening(v: Float): Float {

		_dampening = v * SCALE_DAMPENING;

		update_combs();

		return _dampening;

	}

	function get_room_size(): Float {

		return (_room_size - OFFSET_ROOM) / SCALE_ROOM;

	}

	function set_room_size(v: Float): Float {

        _room_size = (v * SCALE_ROOM) + OFFSET_ROOM;

		update_combs();

		return _room_size;

	}

	function set_frozen(v: Bool): Bool {

		frozen = v;

        input_gain = frozen ? 0.0 : 1.0 ;

		update_combs();

		return v;

	}


}


typedef Reverb2Options = {

	@:optional var wet: Float;
	@:optional var width: Float;
	@:optional var dry: Float;
	// @:optional var input_gain: Float;
	@:optional var dampening: Float;
	@:optional var room_size: Float;
	@:optional var frozen: Bool;

}

private class DelayLine {

	var buffer: Float32Array;
	var index: Int;

	public function new(_len: Int) {

		buffer = new Float32Array(_len);
		index = 0;
		
	}

	public inline function read(): Float {

		return buffer[index];
		
	}

	public function write_and_advance(value: Float) {

		buffer.set(index, value);

		if(index == buffer.length - 1) {
			index = 0;
		} else {
			index += 1;
		}
		
	}

}

private class Comb {

	public var feedback 	(default, set): Float;
	public var dampening	(default, set): Float;

	var delay_line: DelayLine;
	var filter_state: Float;
	var dampening_inverse: Float;

	public function new(delay_length: Int) {

		delay_line = new DelayLine(delay_length);
		feedback = 0.5;
		filter_state = 0.0;
		dampening = 0.5;
		dampening_inverse = 0.5;
		
	}

	public function tick(input: Float): Float {

		var output = delay_line.read();

		filter_state = output * dampening_inverse + filter_state * dampening;

		delay_line.write_and_advance(input + filter_state * feedback);

		return output;
	}

	function set_feedback(v: Float): Float {

		feedback = v;

		return feedback;

	}

	function set_dampening(v: Float): Float {

		dampening = Mathf.clamp(v, 0, 1);
		dampening_inverse = 1.0 - dampening;

		return dampening;

	}
	
	// function undenormalize(s: Float): Float { 

	//     s += 9.8607615E-32; 
	//     return s - 9.8607615E-32; 

	// }
	

}


private class AllPass {


	var delay_line: DelayLine;


	public function new(delay_length: Int) {

		delay_line = new DelayLine(delay_length);
		
	}

	public function tick(input: Float): Float {

		var delayed = delay_line.read();
		var output = -input + delayed;

		// in the original version of freeverb this is a member which is never modified
		var feedback = 0.5;

		delay_line.write_and_advance(input + delayed * feedback);


		return output;
	}

}

