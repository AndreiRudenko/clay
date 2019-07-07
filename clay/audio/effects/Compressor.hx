package clay.audio.effects;


import clay.utils.Mathf;
import clay.utils.Log.*;


class Compressor extends AudioEffect {


	public var ratio(default, set):Float;

	public var threshold:Float;
	public var attack_time(default, set):Float; // sec
	public var release_time(default, set):Float; // sec

	public var pre_gain(default, set):Float;
	public var post_gain(default, set):Float;

	var _slope:Float = 0;

	var _lookahead_time:Float = 0.005; // sec, 5ms: this introduces lag

	var _delay_buffer:kha.arrays.Float32Array;
	var _envelope_buffer:kha.arrays.Float32Array;

	var _delay_read_pointer:Int;
	var _delay_write_pointer:Int;
	var _envelope_sample:Float;
	var _sample_rate:Float;

	var _attack_gain:Float;
	var _release_gain:Float;

	var _pre_gain_amp:Float;
	var _post_gain_amp:Float;


	public function new(ratio:Float = 3, threshold:Float = -2, attack:Float = 0, release:Float = 0.5, pre_gain:Float = 0, post_gain:Float = 0) {

		_sample_rate = Clay.audio.sample_rate;
		
		var n = Std.int(_lookahead_time * _sample_rate);
		_delay_buffer = new kha.arrays.Float32Array(n);
		_envelope_buffer = new kha.arrays.Float32Array(512);

		_delay_read_pointer = 0;
		_delay_write_pointer = n - 1;
		_envelope_sample = 0;

		_attack_gain = 0;
		_release_gain = 0;

		_pre_gain_amp = 0;
		_post_gain_amp = 0;

		this.threshold = threshold;
		this.attack_time = attack;
		this.release_time = release;
		this.ratio = ratio;
		
		this.pre_gain = pre_gain;
		this.post_gain = post_gain;

	}

	override function process(samples:Int, data:kha.arrays.Float32Array, sample_rate:Int) {
		
		//apply pre gain to signal
		for (k in 0...samples) {
			data[k] = _pre_gain_amp * data[k];
		}

		var envelope_data = get_envelope(samples, data);

		var len = Std.int(samples/2);

		if (_lookahead_time > 0){
			//write signal into buffer and read delayed signal
			for (i in 0...len) {
				_delay_buffer.set((_delay_write_pointer*2) % _delay_buffer.length, data[i*2]);
				_delay_buffer.set((_delay_write_pointer*2+1) % _delay_buffer.length, data[i*2+1]);
				data[i*2] = _delay_buffer.get((_delay_read_pointer*2) % _delay_buffer.length);
				data[i*2+1] = _delay_buffer.get((_delay_read_pointer*2+1) % _delay_buffer.length);

				_delay_write_pointer++;
				_delay_read_pointer++;
			}
		}
		
		for (i in 0...len) {
			var gain_db = _slope * (threshold - amp_to_db(envelope_data[i]));
			//is gain below zero?
			gain_db = Math.min(0, gain_db);
			var gain = db_to_amp(gain_db);
			data[i*2] *= (gain * _post_gain_amp);
			data[i*2+1] *= (gain * _post_gain_amp);
		}

	}

	function get_envelope(samples:Int, data:kha.arrays.Float32Array):kha.arrays.Float32Array {

		var len = Std.int(samples/2);

		if(_envelope_buffer.length < len) {
			_envelope_buffer = new kha.arrays.Float32Array(len);
		}
		
		for (i in 0...len) {
				
			var env_in = Math.abs(to_mono(data[i*2], data[i*2+1]));
			
			if (_envelope_sample < env_in){
				_envelope_sample = env_in + _attack_gain * (_envelope_sample - env_in);
			} else {
				_envelope_sample = env_in + _release_gain * (_envelope_sample - env_in);
			}
			
			_envelope_buffer[i] = _envelope_sample;
			
		}
		
		return _envelope_buffer;

	}

	function set_ratio(v:Float):Float {

		ratio = Mathf.clamp_bottom(v, 1);

		_slope = 1 - (1/ratio);

		return ratio;

	}

	function set_pre_gain(v:Float):Float {

		_pre_gain_amp = db_to_amp(v);

		return pre_gain = v;

	}

	function set_post_gain(v:Float):Float {

		_post_gain_amp = db_to_amp(v);

		return post_gain = v;

	}

	function set_attack_time(v:Float):Float {

		//attack in milliseconds
		_attack_gain = Math.exp(-1 / (_sample_rate * v));

		return attack_time = v;

	}

	function set_release_time(v:Float):Float {

		//release in milliseconds
		_release_gain = Math.exp(-1 / (_sample_rate * v));	

		return release_time = v;

	}

	inline function to_mono(l:Float, r:Float):Float {
		
		return (l + r) / 2;

	}

	inline function log10(x:Float):Float {

  		return Math.log(x) / 2.302585092994046; // Math.log(x) / Math.log(10);

	}

	inline function amp_to_db(v:Float):Float {
		
		return 20 * log10(v);	

	}

	inline function db_to_amp(db:Float):Float {

		return Math.pow(10, db / 20);

	}


}