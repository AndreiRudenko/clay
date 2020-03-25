package clay.audio.effects;

import clay.Clay;
import clay.utils.Log.*;
import clay.audio.AudioEffect;
import kha.arrays.Float32Array;
import clay.utils.Mathf;
import clay.utils.DSP;
import clay.audio.dsp.AllPassFilter;
import clay.audio.dsp.CombFilter;
import clay.audio.dsp.Delay;
import clay.audio.dsp.HighPassFilter;
import clay.audio.dsp.LowPassFilter;

// based on FreeVerb3
class Reverb extends AudioEffect {

	static var FIXED_GAIN:Float = 0.05; // 0.015

	static var SCALE_WET:Float = 3.0;
	static var SCALE_DAMPING:Float = 0.4;
	static var SCALE_ROOM:Float = 0.28;
	static var OFFSET_ROOM:Float = 0.7;

	static var STEREO_SPREAD:Float = 0.5215419501133786848073; // ms, 23 samples in 44100
	static var ALLPASS_FEEDBACK:Float = 0.5;
	static var CROSS_DELAY_L:Float = 37;
	static var CROSS_DELAY_R:Float = 58;

	static var COMBS:Int = 8;
	static var ALLPASSES:Int = 4;
	static var ALLPASSES_CROSS:Int = 4;
	static var SCALE:Float = 1; // TODO: to non static variable
	static var CROSSFEED:Float = 0.4;

	// in ms
	static var COMB_TUNING:Array<Float> = [
		25.30612244897959183674,
		26.93877551020408163265,
		28.95691609977324263039,
		30.74829931972789115646,
		32.24489795918367346939,
		33.80952380952380952381,
		35.30612244897959183674,
		36.66666666666666666667
	];

	static var ALLPASS_TUNING:Array<Float> = [
		12.60770975056689342404, 
		10, 
		7.732426303854875283447, 
		5.102040816326530612245
	];

	public var dry(default, set):Float;
	public var wet(get, set):Float;
	public var preDelay(default, set):Float;
	public var damping(get, set):Float;
	public var roomSize(get, set):Float;
	public var highCut(default, set):Float;
	public var lowCut(default, set):Float;
	public var width(default, set):Float;
	public var frozen(default, set):Bool;

	var _wet:Float;
	var _damping:Float;
	var _roomSize:Float;
	var _wet0:Float;
	var _wet1:Float;

	var _combsL:Array<CombFilter>;
	var _combsR:Array<CombFilter>;

	var _allpassesL:Array<AllPassFilter>;
	var _allpassesR:Array<AllPassFilter>;

	var _preDelayLR:Delay;

	var _crossDelayL:Delay;
	var _crossDelayR:Delay;

	var _lowPassL:LowPassFilter;
	var _lowPassR:LowPassFilter;
	var _highPassL:HighPassFilter;
	var _highPassR:HighPassFilter;

	public function new(options:ReverbOptions) {
		super();
		
		_combsL = [];
		_combsR = [];
		_allpassesL = [];
		_allpassesR = [];

		for (i in 0...COMBS) {
			_combsL.push(new CombFilter(toSamples(COMB_TUNING[i] * SCALE)));
			_combsR.push(new CombFilter(toSamples((COMB_TUNING[i] + STEREO_SPREAD) * SCALE)));
		}

		for (i in 0...ALLPASSES) {
			_allpassesL.push(new AllPassFilter(toSamples(ALLPASS_TUNING[i] * SCALE), ALLPASS_FEEDBACK));
			_allpassesR.push(new AllPassFilter(toSamples((ALLPASS_TUNING[i] + STEREO_SPREAD) * SCALE), ALLPASS_FEEDBACK));
		}

		_crossDelayL = new Delay(toSamples(CROSS_DELAY_L * SCALE), 1);
		_crossDelayR = new Delay(toSamples(CROSS_DELAY_R * SCALE), 1);
		_lowPassL = new LowPassFilter(0, Clay.audio.sampleRate);
		_lowPassR = new LowPassFilter(0, Clay.audio.sampleRate);
		_highPassL = new HighPassFilter(0, Clay.audio.sampleRate);
		_highPassR = new HighPassFilter(0, Clay.audio.sampleRate);

		wet = def(options.wet, 0.5);
		dry = def(options.dry, 1);
		preDelay = def(options.preDelay, 10);
		width = def(options.width, 0.5);
		highCut = def(options.highCut, 0);
		lowCut = def(options.highCut, 0);
		damping = def(options.damping, 0.5);
		roomSize = def(options.roomSize, 0.5);
		frozen = def(options.frozen, false);
	}

	override function process(samples:Int, buffer:Float32Array, sampleRate:Int) {
		var inL:Float;
		var inR:Float;
		var outL:Float;
		var outR:Float;
		var earlyL:Float;
		var earlyR:Float;
		var fL:Float;
		var fR:Float;

		var i:Int = 0;
		var j:Int = 0;
		while(i < samples) {
			inL = buffer[i];
			inR = buffer[i+1];

			outL = 0;
			outR = 0;

			fL = inL;
			fR = inR;

			if(highCut > 0) {
				fL = _lowPassL.process(fL);
				fR = _lowPassR.process(fR);
			}

			if(lowCut > 0) {
				fL = _highPassL.process(fL);
				fR = _highPassR.process(fR);
			}

			// input LR crossfeed
			earlyL = _crossDelayL.process(fL);
			earlyR = _crossDelayR.process(fR);

			earlyL = (fL + CROSSFEED * earlyR) * FIXED_GAIN;
			earlyR = (fR + CROSSFEED * earlyL) * FIXED_GAIN;

			// accumulate comb filters in parallel
			j = 0;
			while(j < COMBS) {
				outL += _combsL[j].process(earlyL);
				outR += _combsR[j].process(earlyR);
				j++;
			}

			// feed through allpasses in series
			j = 0;
			while(j < ALLPASSES) {
				outL = _allpassesL[j].process(outL);
				outR = _allpassesR[j].process(outR);
				j++;
			}

			// pre delay
			outL = _preDelayLR.process(outL);
			outR = _preDelayLR.process(outR);

			buffer[i] = outL * _wet0 + outR * _wet1 + inL * dry;
			buffer[i+1] = outR * _wet0 + outL * _wet1 + inR * dry;

			i += 2;
		}
	}

	function toSamples(ms:Float):Int {
		return DSP.toSamples(ms, Clay.audio.sampleRate);
	}

	function updateWetGains() {
		_wet0 = _wet * SCALE_WET * (width / 2.0 + 0.5);
		_wet1 = _wet * SCALE_WET * ((1.0 - width) / 2.0);
	}

	function updateFeedback() {
		var feed = frozen ? 1 : _roomSize * SCALE_ROOM + OFFSET_ROOM;
		for (i in 0...COMBS) {
			_combsL[i].feedback = feed;
			_combsR[i].feedback = feed;
		}
	}

	function updateDamping() {
		var damp = frozen ? 0 : _damping * SCALE_DAMPING;
		for (i in 0...COMBS) {
			_combsL[i].damping = damp;
			_combsR[i].damping = damp;
		}
	}

	function get_wet():Float {
		return _wet;
	}

	function set_wet(v:Float):Float {
		_wet = Mathf.clamp(v, 0, 1);
		updateWetGains();
		return _wet;
	}

	function set_dry(v:Float):Float {
		dry = Mathf.clamp(v, 0, 1);
		return dry;
	}

	function set_preDelay(v:Float):Float {
		preDelay = Mathf.clampBottom(v, 1);
		_preDelayLR = new Delay(toSamples(preDelay) * 2, 1);
		return preDelay;
	}

	function set_width(v:Float):Float {
		width = Mathf.clamp(v, 0, 1);
		updateWetGains();
		return width;
	}

	function set_highCut(v:Float):Float {
		highCut = Mathf.clamp(v, 0, 20000);
		_lowPassL.freq = highCut;
		_lowPassR.freq = highCut;
		return highCut;
	}

	function set_lowCut(v:Float):Float {
		lowCut = Mathf.clamp(v, 0, 20000);
		_highPassL.freq = lowCut;
		_highPassR.freq = lowCut;
		return lowCut;
	}

	function get_damping():Float {
		return _damping;
	}

	function set_damping(v:Float):Float {
		_damping = v;
		updateDamping();
		return _damping;
	}

	function get_roomSize():Float {
		return _roomSize;
	}

	function set_roomSize(v:Float):Float {
		_roomSize = Mathf.clamp(v, 0, 1);
		updateFeedback();
		return _roomSize;
	}

	function set_frozen(v:Bool):Bool {
		frozen = v;
		updateFeedback();
		updateDamping();
		return v;
	}

}

typedef ReverbOptions = {

	@:optional var wet:Float;
	@:optional var width:Float;
	@:optional var dry:Float;
	@:optional var preDelay:Float;
	@:optional var damping:Float;
	@:optional var roomSize:Float;
	@:optional var highCut:Float;
	@:optional var frozen:Bool;

}