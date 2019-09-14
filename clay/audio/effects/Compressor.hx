package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;


class Compressor extends AudioEffect {


	public var ratio(default, set):Float;

	public var threshold:Float;
	public var attackTime(default, set):Float; // sec
	public var releaseTime(default, set):Float; // sec

	public var preGain(default, set):Float;
	public var postGain(default, set):Float;

	var _slope:Float = 0;

	var _lookaheadTime:Float = 0.005; // sec, 5ms: this introduces lag

	var _delayBuffer:kha.arrays.Float32Array;
	var _envelopeBuffer:kha.arrays.Float32Array;

	var _delayReadPointer:Int;
	var _delayWritePointer:Int;
	var _envelopeSample:Float;
	var _sampleRate:Float;

	var _attackGain:Float;
	var _releaseGain:Float;

	var _preGainAmp:Float;
	var _postGainAmp:Float;


	public function new(ratio:Float = 3, threshold:Float = -2, attack:Float = 0, release:Float = 0.5, preGain:Float = 0, postGain:Float = 0) {

		_sampleRate = Clay.audio.sampleRate;
		
		var n = Std.int(_lookaheadTime * _sampleRate);
		_delayBuffer = new kha.arrays.Float32Array(n);

		for (i in 0...n) { // this fix click on start in cpp build
			_delayBuffer[i] = 0;
		}

		_envelopeBuffer = new kha.arrays.Float32Array(512);

		_delayReadPointer = 0;
		_delayWritePointer = n - 1;
		_envelopeSample = 0;

		_attackGain = 0;
		_releaseGain = 0;

		_preGainAmp = 0;
		_postGainAmp = 0;

		this.threshold = threshold;
		this.attackTime = attack;
		this.releaseTime = release;
		this.ratio = ratio;
		
		this.preGain = preGain;
		this.postGain = postGain;

	}

	override function process(samples:Int, data:kha.arrays.Float32Array, sampleRate:Int) {
		
		//apply pre gain to signal
		for (k in 0...samples) {
			data[k] = _preGainAmp * data[k];
		}

		var envelopeData = getEnvelope(samples, data);

		var len = Std.int(samples/2);

		if (_lookaheadTime > 0){
			//write signal into buffer and read delayed signal
			for (i in 0...len) {
				_delayBuffer.set((_delayWritePointer*2) % _delayBuffer.length, data[i*2]);
				_delayBuffer.set((_delayWritePointer*2+1) % _delayBuffer.length, data[i*2+1]);
				data[i*2] = _delayBuffer.get((_delayReadPointer*2) % _delayBuffer.length);
				data[i*2+1] = _delayBuffer.get((_delayReadPointer*2+1) % _delayBuffer.length);

				_delayWritePointer++;
				_delayReadPointer++;
			}
		}
		
		for (i in 0...len) {
			var gainDb = _slope * (threshold - ampToDb(envelopeData[i]));
			//is gain below zero?
			gainDb = Math.min(0, gainDb);
			var gain = dbToAmp(gainDb);
			data[i*2] *= (gain * _postGainAmp);
			data[i*2+1] *= (gain * _postGainAmp);
		}

	}

	function getEnvelope(samples:Int, data:kha.arrays.Float32Array):kha.arrays.Float32Array {

		var len = Std.int(samples/2);

		if(_envelopeBuffer.length < len) {
			_envelopeBuffer = new kha.arrays.Float32Array(len);
		}
		
		for (i in 0...len) {
				
			var envIn = Math.abs(toMono(data[i*2], data[i*2+1]));
			
			if (_envelopeSample < envIn){
				_envelopeSample = envIn + _attackGain * (_envelopeSample - envIn);
			} else {
				_envelopeSample = envIn + _releaseGain * (_envelopeSample - envIn);
			}
			
			_envelopeBuffer[i] = _envelopeSample;
			
		}
		
		return _envelopeBuffer;

	}

	function set_ratio(v:Float):Float {

		ratio = Mathf.clampBottom(v, 1);

		_slope = 1 - (1/ratio);

		return ratio;

	}

	function set_preGain(v:Float):Float {

		_preGainAmp = dbToAmp(v);

		return preGain = v;

	}

	function set_postGain(v:Float):Float {

		_postGainAmp = dbToAmp(v);

		return postGain = v;

	}

	function set_attackTime(v:Float):Float {

		//attack in milliseconds
		_attackGain = Math.exp(-1 / (_sampleRate * v));

		return attackTime = v;

	}

	function set_releaseTime(v:Float):Float {

		//release in milliseconds
		_releaseGain = Math.exp(-1 / (_sampleRate * v));	

		return releaseTime = v;

	}

	inline function toMono(l:Float, r:Float):Float {
		
		return (l + r) / 2;

	}

	inline function log10(x:Float):Float {

  		return Math.log(x) / 2.302585092994046; // Math.log(x) / Math.log(10);

	}

	inline function ampToDb(v:Float):Float {
		
		return 20 * log10(v);	

	}

	inline function dbToAmp(db:Float):Float {

		return Math.pow(10, db / 20);

	}


}