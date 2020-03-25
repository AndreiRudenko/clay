package clay.audio.effects;

import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.audio.Audio;

class Compressor extends AudioEffect {

	public var ratio(get, set):Float;

	public var threshold(get, set):Float;
	public var attackTime(get, set):Float; // sec
	public var releaseTime(get, set):Float; // sec

	public var preGain(get, set):Float;
	public var postGain(get, set):Float;

	var _ratio:Float;
	var _threshold:Float;
	var _attackTime:Float;
	var _releaseTime:Float;
	var _preGain:Float;
	var _postGain:Float;

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
		super();

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

		_threshold = threshold;
		_attackTime = _setAttackTime(attack);
		_releaseTime = _setReleaseTime(release);
		_ratio = _setRatio(ratio);
		
		_preGain = _setPreGain(preGain);
		_postGain = _setPostGain(postGain);
	}

	override function process(samples:Int, data:kha.arrays.Float32Array, sampleRate:Int) {
		//apply pre gain to signal
		for (k in 0...samples) {
			data[k] = _preGainAmp * data[k];
		}

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
		
		var envelopeData = getEnvelope(samples, data);

		for (i in 0...len) {
			var gainDb = _slope * (_threshold - ampToDb(envelopeData[i]));
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

	function get_ratio():Float {
		Audio.mutexLock();
		var v = _ratio;
		Audio.mutexUnlock();

		return v;
	}

	function set_ratio(v:Float):Float {
		Audio.mutexLock();
		v = _setRatio(v);
		Audio.mutexUnlock();

		return v;
	}

	function get_threshold():Float {
		Audio.mutexLock();
		var v = _threshold;
		Audio.mutexUnlock();

		return v;
	}

	function set_threshold(v:Float):Float {
		Audio.mutexLock();
		_threshold = v;
		Audio.mutexUnlock();

		return v;
	}

	function get_preGain():Float {
		Audio.mutexLock();
		var v = _preGain;
		Audio.mutexUnlock();

		return v;
	}

	function set_preGain(v:Float):Float {
		Audio.mutexLock();
		v = _setPreGain(v);
		Audio.mutexUnlock();

		return v;
	}

	function get_postGain():Float {
		Audio.mutexLock();
		var v = _postGain;
		Audio.mutexUnlock();

		return v;
	}

	function set_postGain(v:Float):Float {
		Audio.mutexLock();
		v = _setPostGain(v);
		Audio.mutexUnlock();

		return v;
	}

	function get_attackTime():Float {
		Audio.mutexLock();
		var v = _attackTime;
		Audio.mutexUnlock();

		return v;
	}

		//attack in milliseconds
	function set_attackTime(v:Float):Float {
		Audio.mutexLock();
		v = _setAttackTime(v);
		Audio.mutexUnlock();

		return v;
	}

	function get_releaseTime():Float {
		Audio.mutexLock();
		var v = _releaseTime;
		Audio.mutexUnlock();

		return v;
	}

		//release in milliseconds
	function set_releaseTime(v:Float):Float {
		Audio.mutexLock();
		v = _setReleaseTime(v);
		Audio.mutexUnlock();

		return v;
	}

	function _setRatio(v:Float) {
		_ratio = Mathf.clampBottom(v, 1);
		_slope = 1 - (1/_ratio);

		return _ratio;
	}

	function _setPreGain(v:Float) {
		_preGain = v;
		_preGainAmp = dbToAmp(_preGain);

		return _preGain;
	}

	function _setPostGain(v:Float) {
		_postGain = v;
		_postGainAmp = dbToAmp(_postGain);

		return _postGain;
	}

	function _setAttackTime(v:Float) {
		_attackTime = v;
		_attackGain = Math.exp(-1 / (_sampleRate * _attackTime));

		return _attackTime;
	}

	function _setReleaseTime(v:Float) {
		_releaseTime = v;
		_releaseGain = Math.exp(-1 / (_sampleRate * _releaseTime));	

		return _releaseTime;
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