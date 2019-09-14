package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;
import clay.Sound;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

// https://github.com/DeerMichel/reverb
// basic variant of the Jot's FDN Late Reverberator using a Hadamard matrix as feedback matrix

class Reverb extends AudioEffect {

	// amount of dry signal fed into main line
	public var dry:Float;
	// amount of wet signal fed from delay lines into main line
	public var wet(default, set):Float;
	// amount of dry signal fed into delay lines
	public var feedDryIn(default, set):Float;
	// amount of decay of delay lines
	public var decay(default, set):Float;
	// set max delay tap time in ms
	public var delayTapTime(default, set):Int;

	// order of reverb (number of delay lines)
	var order:Int;
	// max number of samples passed for processing
	var maxSamples:Int;

	// input buffer holding the last and current input samples
	var inputBufferL:CircularBuffer;
	var inputBufferR:CircularBuffer;
	// delay buffers holding the last and current calculated samples of delay lines
	var delayBufferL:Array<CircularBuffer>;
	var delayBufferR:Array<CircularBuffer>;
	// feedback matrix used for reverb
	var feedbackMatrix:Array<Float32Array>;

	var delayTaps:Uint32Array;
	var decayArr:Float32Array;


	public function new(_options:ReverbOptions) {

		order = def(_options.order, 8);
		maxSamples = def(_options.maxSamples, 512);
		dry = def(_options.dry, 1);

		// set default parameters (and dynamic allocation)
		inputBufferL = new CircularBuffer(maxSamples);
		inputBufferR = new CircularBuffer(maxSamples);
		delayBufferL = [];
		delayBufferR = [];
		feedbackMatrix = [];
		delayTaps = new Uint32Array(order);
		decayArr = new Float32Array(order);

		for (i in 0...order) {
			delayBufferL[i] = new CircularBuffer(maxSamples);
			delayBufferR[i] = new CircularBuffer(maxSamples);
			feedbackMatrix[i] = new Float32Array(order);
		}

		// feedback matrix is a hadamard matrix (for now)
		generateHadamardMatrix(order, 1 / Math.sqrt(order), feedbackMatrix);

		feedDryIn = def(_options.feedDryIn, 0.2);
		wet = def(_options.wet, 0.2);
		decay = def(_options.decay, 0.95);
		delayTapTime = def(_options.delayTapTime, 4096);

	}

	override function process(samples:Int, buffer:Float32Array, sampleRate:Int) {

		// for (i in 0...Std.int(samples/2)) {

		var len:Int = Std.int(samples/2);

		// var b = new Float32Array(len);
		// var b2 = new Float32Array(len);

		// update buffers
		// for (i in 0...len) {

		// 	inputBufferL.insertOne(buffer[i*2]);
		// 	inputBufferR.insertOne(buffer[i*2+1]);
		// 	// b[i] = buffer[i*2];
		// 	// b2[i] = buffer[i*2+1];
		// }

		inputBufferL.insertShift(buffer, len, 0);
		inputBufferR.insertShift(buffer, len, 1);

		for (n in 0...order) {
			delayBufferL[n].shift(len);
			delayBufferR[n].shift(len);
		}

		// process samples

		var inL:Float;
		var inR:Float;

		var outL:Float;
		var outR:Float;

		var res:Float;

		for (i in 0...len) {

			inL = buffer[i*2];
			inR = buffer[i*2+1];

			outL = 0;
			outR = 0;

			outL = dry * inputBufferL.get(i);
			outR = dry * inputBufferR.get(i);

			for (n in 0...order) {
				// left
				res = feedDryIn * inputBufferL.get(i - delayTaps[n]);
				for (j in 0...order) {
					res += feedbackMatrix[n][j] * delayBufferL[j].get(i - delayTaps[n]) * decayArr[j];
				}
				delayBufferL[n].set(i, res);

				outL += wet * res;

				// right
				res = feedDryIn * inputBufferR.get(i - delayTaps[n]);
				for (j in 0...order) {
					res += feedbackMatrix[n][j] * delayBufferR[j].get(i - delayTaps[n]) * decayArr[j];
				}
				delayBufferR[n].set(i, res);

				outR += wet * res;
			}

			buffer[i*2] = outL;
			buffer[i*2+1] = outR;
		}

	}

	function generateHadamardMatrix(order:Int, value:Float, result:Array<Float32Array>) {

		// set initial value
		result[0][0] = value; 

		var n:Int = 2;
		var i:Int = 0;
		var j:Int = 0;
		var a:Int = 0;
		var b:Int = 0;

		// expand recursively according to hadamard rules
		while(n <= order) {
			i = 0;
			while(i < n / 2) {
				j = 0;
				while(j < n / 2) {
					a = Math.floor(j + n / 2);
					b = Math.floor(i + n / 2);
			        result[i][a] = result[i][j];
			        result[b][j] = result[i][j];
			        result[b][a] = -result[i][j];
					j++;
				}
				i++;
			}
			n *= 2;
		}

	}

	function set_decay(v:Float):Float {

		decay = Mathf.clamp(v, 0, 1);

		for (i in 0...order) {
			decayArr.set(i, decay);
		}

		return decay;

	}

	function set_feedDryIn(v:Float):Float {

		return feedDryIn = v;

	}

	function set_wet(v:Float):Float {
		
		return wet = v;

	}

	function set_delayTapTime(v:Int):Int {
		
  		// distribute delay taps exponentially over time
  		var distribution = Math.log(v) / order;
		for (i in 0...order) {
			delayTaps.set(i, Math.floor(Math.exp(distribution * (i + 1))));
		}

		// update buffer sizes
		// TODO:no need for reconstruction -> variable buffer size
		inputBufferL = new CircularBuffer(maxSamples + v);
		inputBufferR = new CircularBuffer(maxSamples + v);
		for (i in 0...order) {
			delayBufferL[i] = new CircularBuffer(maxSamples + v);
			delayBufferR[i] = new CircularBuffer(maxSamples + v);
		}

		return delayTapTime = v;

	}


}


typedef ReverbOptions = {

	@:optional var dry:Float;
	@:optional var feedDryIn:Float;
	@:optional var wet:Float;
	@:optional var decay:Float;
	@:optional var delayTapTime:Int;
	@:optional var order:Int;
	@:optional var maxSamples:Int;

}


private class CircularBuffer {


	public var buffer:Float32Array;
	public var length(get, never):Int;

	var offset:Int;
	var recentNumValues:Int;

	public inline function new(size:Int) {
	
		buffer = new Float32Array(size);
		offset = 0;
		recentNumValues = 0;
	
	}

	public function insert(values:Float32Array, num:Int) {

		if(num < 0 && num > length) {
			throw('CircularBuffer cant insert values');
		}

		for (i in 0...num) {
			buffer[mod(i + offset, length)] = values[i];
		}

		shift(num);

	}

	public function insertShift(values:Float32Array, num:Int, _shift:Int) {

		if(num < 0 && num > length) {
			throw('CircularBuffer cant insert values');
		}

		for (i in 0...num) {
			// buffer[mod(i + offset, length)] = (values[i*2] + values[i*2+1]) * 0.5;
			buffer[mod(i + offset, length)] = values[i*2+_shift];
			// buffer[mod(i + offset, length)] = values[i*2+(1-_shift)] * 0.3 + values[i*2+_shift] * 0.7;
		}

		shift(num);

	}

	public inline function insertOne(v:Float) {

		buffer[offset] = v;

		shift(1);

	}

	public inline function shift(num:Int) {

		offset = (offset + num) % length;
		recentNumValues = num;

	}

	public function get(i:Int):Float {

		return buffer[mod((offset - recentNumValues) + i, length)];
	
	}

	public function set(i:Int, v:Float) {

		return buffer.set(mod((offset - recentNumValues) + i, length),  v);
	
	}

	inline function get_length():Int {
		
		return buffer.length;

	}

	inline function mod(i:Int, n:Int):Int {
		
		return return (i % n + n) % n;

	}

}
