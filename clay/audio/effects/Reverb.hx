package clay.audio.effects;


import clay.math.Mathf;
import clay.utils.Log.*;
import clay.Sound;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

// https://github.com/DeerMichel/reverb
// basic variant of the Jot's FDN Late Reverberator using a Hadamard matrix as feedback matrix

class Reverb extends AudioEffect {

	// amount of dry signal fed into main line
	public var dry: Float;
	// amount of wet signal fed from delay lines into main line
	public var wet  	(default, set): Float;
	// amount of dry signal fed into delay lines
	public var feed_dry_in   	(default, set): Float;
	// amount of decay of delay lines
	public var decay         	(default, set): Float;
	// set max delay tap time in ms
	public var delay_tap_time	(default, set): Int;

	// order of reverb (number of delay lines)
	var order: Int;
	// max number of samples passed for processing
	var max_samples: Int;

	// input buffer holding the last and current input samples
	var input_buffer_l: CircularBuffer;
	var input_buffer_r: CircularBuffer;
	// delay buffers holding the last and current calculated samples of delay lines
	var delay_buffer_l: Array<CircularBuffer>;
	var delay_buffer_r: Array<CircularBuffer>;
	// feedback matrix used for reverb
	var feedback_matrix: Array<Float32Array>;

	var delay_taps: Uint32Array;
	var decay_arr: Float32Array;


	public function new(_options: ReverbOptions) {

		order = def(_options.order, 8);
		max_samples = def(_options.max_samples, 512);
		dry = def(_options.dry, 1);

		// set default parameters (and dynamic allocation)
		input_buffer_l = new CircularBuffer(max_samples);
		input_buffer_r = new CircularBuffer(max_samples);
		delay_buffer_l = [];
		delay_buffer_r = [];
		feedback_matrix = [];
		delay_taps = new Uint32Array(order);
		decay_arr = new Float32Array(order);

		for (i in 0...order) {
			delay_buffer_l[i] = new CircularBuffer(max_samples);
			delay_buffer_r[i] = new CircularBuffer(max_samples);
			feedback_matrix[i] = new Float32Array(order);
		}

		// feedback matrix is a hadamard matrix (for now)
		generate_hadamard_matrix(order, 1 / Math.sqrt(order), feedback_matrix);

		feed_dry_in = def(_options.feed_dry_in, 0.2);
		wet = def(_options.wet, 0.2);
		decay = def(_options.decay, 0.95);
		delay_tap_time = def(_options.delay_tap_time, 4096);

	}

	override function process(samples: Int, buffer: Float32Array, sample_rate: Int) {

		// for (i in 0...Std.int(samples/2)) {

		var len:Int = Std.int(samples/2);

		// var b = new Float32Array(len);
		// var b2 = new Float32Array(len);

		// update buffers
		// for (i in 0...len) {

		// 	input_buffer_l.insert_one(buffer[i*2]);
		// 	input_buffer_r.insert_one(buffer[i*2+1]);
		// 	// b[i] = buffer[i*2];
		// 	// b2[i] = buffer[i*2+1];
		// }

		input_buffer_l.insert_shift(buffer, len, 0);
		input_buffer_r.insert_shift(buffer, len, 1);

		for (n in 0...order) {
			delay_buffer_l[n].shift(len);
			delay_buffer_r[n].shift(len);
		}

		// process samples

		var in_l: Float;
		var in_r: Float;

		var out_l: Float;
		var out_r: Float;

		var res: Float;

		for (i in 0...len) {

			in_l = buffer[i*2];
			in_r = buffer[i*2+1];

			out_l = 0;
			out_r = 0;

			out_l = dry * input_buffer_l.get(i);
			out_r = dry * input_buffer_r.get(i);

			for (n in 0...order) {
				// left
				res = feed_dry_in * input_buffer_l.get(i - delay_taps[n]);
				for (j in 0...order) {
					res += feedback_matrix[n][j] * delay_buffer_l[j].get(i - delay_taps[n]) * decay_arr[j];
				}
				delay_buffer_l[n].set(i, res);

				out_l += wet * res;

				// right
				res = feed_dry_in * input_buffer_r.get(i - delay_taps[n]);
				for (j in 0...order) {
					res += feedback_matrix[n][j] * delay_buffer_r[j].get(i - delay_taps[n]) * decay_arr[j];
				}
				delay_buffer_r[n].set(i, res);

				out_r += wet * res;
			}

			buffer[i*2] = out_l;
			buffer[i*2+1] = out_r;
		}

	}

	function generate_hadamard_matrix(order: Int, value: Float, result: Array<Float32Array>) {

		// set initial value
		result[0][0] = value; 

		var n: Int = 2;
		var i: Int = 0;
		var j: Int = 0;
		var a: Int = 0;
		var b: Int = 0;

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

	function set_decay(v: Float): Float {

		decay = Mathf.clamp(v, 0, 1);

		for (i in 0...order) {
			decay_arr.set(i, decay);
		}

		return decay;

	}

	function set_feed_dry_in(v: Float): Float {

		return feed_dry_in = v;

	}

	function set_wet(v: Float): Float {
		
		return wet = v;

	}

	function set_delay_tap_time(v: Int): Int {
		
  		// distribute delay taps exponentially over time
  		var distribution = Math.log(v) / order;
		for (i in 0...order) {
			delay_taps.set(i, Math.floor(Math.exp(distribution * (i + 1))));
		}

		// update buffer sizes
		// TODO: no need for reconstruction -> variable buffer size
		input_buffer_l = new CircularBuffer(max_samples + v);
		input_buffer_r = new CircularBuffer(max_samples + v);
		for (i in 0...order) {
			delay_buffer_l[i] = new CircularBuffer(max_samples + v);
			delay_buffer_r[i] = new CircularBuffer(max_samples + v);
		}

		return delay_tap_time = v;

	}


}


typedef ReverbOptions = {

	@:optional var dry: Float;
	@:optional var feed_dry_in: Float;
	@:optional var wet: Float;
	@:optional var decay: Float;
	@:optional var delay_tap_time: Int;
	@:optional var order: Int;
	@:optional var max_samples: Int;

}


private class CircularBuffer {


	public var buffer:Float32Array;
	public var length(get, never):Int;

	var offset: Int;
	var recent_num_values: Int;

	public inline function new(size: Int) {
	
		buffer = new Float32Array(size);
		offset = 0;
		recent_num_values = 0;
	
	}

	public function insert(values: Float32Array, num: Int) {

		if(num < 0 && num > length) {
			throw('CircularBuffer cant insert values');
		}

		for (i in 0...num) {
			buffer[mod(i + offset, length)] = values[i];
		}

		shift(num);

	}

	public function insert_shift(values: Float32Array, num: Int, _shift: Int) {

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

	public inline function insert_one(v: Float) {

		buffer[offset] = v;

		shift(1);

	}

	public inline function shift(num: Int) {

		offset = (offset + num) % length;
		recent_num_values = num;

	}

	public function get(i: Int): Float {

		return buffer[mod((offset - recent_num_values) + i, length)];
	
	}

	public function set(i: Int, v: Float) {

		return buffer.set(mod((offset - recent_num_values) + i, length),  v);
	
	}

	inline function get_length(): Int {
		
		return buffer.length;

	}

	inline function mod(i: Int, n: Int): Int {
		
		return return (i % n + n) % n;

	}

}
