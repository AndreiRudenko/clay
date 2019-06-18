package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;


class Compressor extends AudioEffect {


	public var ratio(default, set): Float;

	public var threshold: Float;
	public var attack_time: Float; // sec
	public var release_time: Float; // sec

	public var pre_gain: Float = 0;
	public var post_gain: Float = 0;

	var slope: Float = 0;

	var lookahead_time: Float = 0.005; // sec, 5ms: this introduces lag

	var delay_buffer: kha.arrays.Float32Array;
	var envelope_buffer: kha.arrays.Float32Array;

	var delay_read_pointer: Int;
	var delay_write_pointer: Int;
	var envelope_sample: Float = 0;
	var sample_rate: Float;


	public function new(_ratio:Float = 3, _threshold:Float = -2, _attack:Float = 0, _release:Float = 0.5, _pre_gain:Float = 0, _post_gain:Float = 0) {

		sample_rate = Clay.audio.sample_rate;

		var n = Std.int(lookahead_time * sample_rate);
		delay_buffer = new kha.arrays.Float32Array(n);
		delay_read_pointer = 0;
		delay_write_pointer = n - 1;
		envelope_buffer = new kha.arrays.Float32Array(512);

		threshold = _threshold;
		attack_time = _attack;
		release_time = _release;
		ratio = _ratio;
		
		pre_gain = _pre_gain;
		post_gain = _post_gain;

	}

	override function process(samples: Int, data: kha.arrays.Float32Array, sample_rate: Int) {

		//transform db to amplitude value
		var post_gain_amp = db_to_amp(post_gain);
		
		//apply pre gain to signal
		var pre_gain_amp = db_to_amp(pre_gain);
		for (k in 0...samples) {
			data[k] = pre_gain_amp * data[k];
		}

		var envelope_data = get_envelope(samples, data);

		var len = Std.int(samples/2);

		if (lookahead_time > 0){
			//write signal into buffer and read delayed signal
			for (i in 0...len) {
				delay_buffer.set((delay_write_pointer*2) % delay_buffer.length,  data[i*2]);
				delay_buffer.set((delay_write_pointer*2+1) % delay_buffer.length,  data[i*2+1]);
				data[i*2] = delay_buffer.get((delay_read_pointer*2) % delay_buffer.length);
				data[i*2+1] = delay_buffer.get((delay_read_pointer*2+1) % delay_buffer.length);

				delay_write_pointer++;
				delay_read_pointer++;
			}		
		}
		
		for (i in 0...len) {
			var gain_db = slope * (threshold - amp_to_db(envelope_data[i]));
			//is gain below zero?
			gain_db = Math.min(0, gain_db);
			var gain = db_to_amp(gain_db);
			data[i*2] *= (gain * post_gain_amp);
			data[i*2+1] *= (gain * post_gain_amp);
		}

	}

	function get_envelope(samples: Int, data: kha.arrays.Float32Array):kha.arrays.Float32Array {

		//attack and release in milliseconds
		var attack_gain = Math.exp(-1 / (sample_rate * attack_time));
		var release_gain = Math.exp(-1 / (sample_rate * release_time));	
		var len = Std.int(samples/2);

		if(envelope_buffer.length < len) {
			envelope_buffer = new kha.arrays.Float32Array(len);
		}
		
		for (i in 0...len) {
				
			var env_in = Math.abs(to_mono(data[i*2], data[i*2+1]));
			
			if (envelope_sample < env_in){
				envelope_sample = env_in + attack_gain * (envelope_sample - env_in);
			} else {
				envelope_sample = env_in + release_gain * (envelope_sample - env_in);
			}
			
			envelope_buffer[i] = envelope_sample;
			
		}
		
		return envelope_buffer;

	}

	function set_ratio(v: Float): Float {

		ratio = Mathf.clamp_bottom(v, 1);

		slope = 1 - (1/ratio);

		return ratio;

	}

	inline function to_mono(l: Float, r: Float):Float {
		
		return (l + r) / 2;

	}

	inline function log10(x: Float): Float {

  		return Math.log(x) / Math.log(10);

	}

	inline function amp_to_db(v: Float): Float {
		
		return 20 * log10(v);	

	}

	inline function db_to_amp(db: Float): Float {

		return Math.pow(10, db/20);

	}


}