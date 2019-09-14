package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
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
	public var roomSize	(get, set): Float;
	public var width    	(default, set): Float;
	public var frozen   	(default, set): Bool;
	public var dry          (default, set): Float;


	var _wet: Float;
	var _dampening: Float;
	var _roomSize: Float;
	var inputGain: Float;
	var wet0: Float;
	var wet1: Float;

	var combsL: Array<Comb>;
	var combsR: Array<Comb>;
	var allpassesL: Array<AllPass>;
	var allpassesR: Array<AllPass>;

	var combsNum: Int = 8;
	var allpassNum: Int = 4;


	public function new(_options: Reverb2Options) {

		combsL = [];
		combsR = [];
		allpassesL = [];
		allpassesR = [];

		for (i in 0...combsNum) {
			combsL.push(new Comb(COMB_TUNING_L[i]));
			combsR.push(new Comb(COMB_TUNING_R[i]));
		}

		for (i in 0...allpassNum) {
			allpassesL.push(new AllPass(ALLPASS_TUNING_L[i]));
			allpassesR.push(new AllPass(ALLPASS_TUNING_R[i]));
		}

		inputGain = 0;
		wet = def(_options.wet, 1);
		dry = def(_options.dry, 0);
		width = def(_options.width, 0.5);
		dampening = def(_options.dampening, 0.5);
		roomSize = def(_options.roomSize, 0.5);
		frozen = def(_options.frozen, false);

	}

	override function process(samples: Int, buffer: Float32Array, sampleRate: Int) {

		var inL: Float;
		var inR: Float;
		var outL: Float;
		var outR: Float;
		var inputMixed: Float;

		for (i in 0...Std.int(samples/2)) {
			inL = buffer[i*2];
			inR = buffer[i*2+1];
			inputMixed = (inL + inR) * FIXED_GAIN * inputGain;
			outL = 0;
			outR = 0;

			for (i in 0...combsNum) {
				outL += combsL[i].tick(inputMixed);
				outR += combsR[i].tick(inputMixed);
			}

			for (i in 0...allpassNum) {
				outL += allpassesL[i].tick(outL);
				outR += allpassesR[i].tick(outR);
			}

			// trace(outL);
			buffer[i*2] = outL * wet0 + outR * wet1 + inL * dry;
			buffer[i*2+1] = outR * wet0 + outL * wet1 + inR * dry;

			// out.0 * self.wetGains.0 + out.1 * self.wetGains.1 + input.0 * self.dry,
			// out.1 * self.wetGains.0 + out.0 * self.wetGains.1 + input.1 * self.dry,
		}

	}

	function updateWetGains() {
		
		wet0 = _wet * SCALE_WET * (width / 2.0 + 0.5);
		wet1 = _wet * SCALE_WET * ((1.0 - width) / 2.0);

	}
	
	function updateCombs() {

		var feed = frozen ? 1 : _roomSize;
		var damp = frozen ? 0 : _dampening;

		for (i in 0...combsNum) {
			combsL[i].feedback = feed;
			combsR[i].feedback = feed;
			combsL[i].dampening = damp;
			combsR[i].dampening = damp;
		}

	}

	function get_wet(): Float {

		return _wet / SCALE_WET;

	}

	function set_wet(v: Float): Float {

		_wet = Mathf.clamp(v, 0, 1) * SCALE_WET;
		
		updateWetGains();

		return _wet;

	}

	function set_dry(v: Float): Float {

		dry = Mathf.clamp(v, 0, 1);
		
		return dry;

	}

	function set_width(v: Float): Float {

		width = Mathf.clamp(v, 0, 1);

		updateWetGains();

		return width;

	}

	function get_dampening(): Float {

		return _dampening / SCALE_DAMPENING;

	}

	function set_dampening(v: Float): Float {

		_dampening = v * SCALE_DAMPENING;

		updateCombs();

		return _dampening;

	}

	function get_roomSize(): Float {

		return (_roomSize - OFFSET_ROOM) / SCALE_ROOM;

	}

	function set_roomSize(v: Float): Float {

		_roomSize = (v * SCALE_ROOM) + OFFSET_ROOM;

		updateCombs();

		return _roomSize;

	}

	function set_frozen(v: Bool): Bool {

		frozen = v;

		inputGain = frozen ? 0.0 : 1.0 ;

		updateCombs();

		return v;

	}


}


typedef Reverb2Options = {

	@:optional var wet: Float;
	@:optional var width: Float;
	@:optional var dry: Float;
	// @:optional var inputGain: Float;
	@:optional var dampening: Float;
	@:optional var roomSize: Float;
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

	public function writeAndAdvance(value: Float) {

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

	var delayLine: DelayLine;
	var filterState: Float;
	var dampeningInverse: Float;

	public function new(delayLength: Int) {

		delayLine = new DelayLine(delayLength);
		feedback = 0.5;
		filterState = 0.0;
		dampening = 0.5;
		dampeningInverse = 0.5;
		
	}

	public function tick(input: Float): Float {

		var output = delayLine.read();

		filterState = output * dampeningInverse + filterState * dampening;

		delayLine.writeAndAdvance(input + filterState * feedback);

		return output;
	}

	function set_feedback(v: Float): Float {

		feedback = v;

		return feedback;

	}

	function set_dampening(v: Float): Float {

		dampening = Mathf.clamp(v, 0, 1);
		dampeningInverse = 1.0 - dampening;

		return dampening;

	}
	
	// function undenormalize(s: Float): Float { 

	//     s += 9.8607615E-32; 
	//     return s - 9.8607615E-32; 

	// }
	

}


private class AllPass {


	var delayLine: DelayLine;


	public function new(delayLength: Int) {

		delayLine = new DelayLine(delayLength);
		
	}

	public function tick(input: Float): Float {

		var delayed = delayLine.read();
		var output = -input + delayed;

		// in the original version of freeverb this is a member which is never modified
		var feedback = 0.5;

		delayLine.writeAndAdvance(input + delayed * feedback);


		return output;
	}

}

