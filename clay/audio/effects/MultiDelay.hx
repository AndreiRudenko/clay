package clay.audio.effects;


import clay.math.Mathf;
import clay.utils.Log.*;
import clay.Sound;

// https://github.com/corbanbrook/dsp.js

class MultiDelay extends AudioEffect {


	public var delay_samples(default, set): Int;

	var delay_buffer_samples: kha.arrays.Float32Array;

	var delay_input_pointer: Int;
	var delay_output_pointer: Int;
	var delay_volume: Float;
	var master_volume: Float;

	var sample_rate: Float;


	public function new(_delay_samples:Int, _master_volume:Float, _delay_volume:Float) {

		delay_buffer_samples = new kha.arrays.Float32Array(_delay_samples); // The maximum size of delay
		delay_input_pointer  = _delay_samples;
		delay_output_pointer = 0;
	 
		delay_samples = _delay_samples;
		delay_volume = _delay_volume;
		master_volume = _master_volume;

		sample_rate = Clay.audio.sample_rate;

	}

	override function process(samples: Int, buffer: kha.arrays.Float32Array, sample_rate: Int) {

		for (i in 0...Std.int(samples/2)) {
			buffer[i*2] = get_delayed(buffer[i*2]) * master_volume;
			buffer[i*2+1] = get_delayed(buffer[i*2+1]) * master_volume;
		}

	}

	function get_delayed(input:Float) {

		var delay_sample = delay_buffer_samples.get(delay_output_pointer);

		// Mix normal audio data with delayed audio
		var sample = (delay_sample * delay_volume) + input;

		// Add audio data with the delay in the delay buffer
		delay_buffer_samples.set(delay_input_pointer, sample);
		
		// Manage circulair delay buffer pointers
		delay_input_pointer++;

		if (delay_input_pointer >= delay_buffer_samples.length-1) {
			delay_input_pointer = 0;
		}
		 
		delay_output_pointer++;

		if (delay_output_pointer >= delay_buffer_samples.length-1) {
			delay_output_pointer = 0; 
		} 

		return sample;

	}

	function set_delay_samples(v:Int):Int {

		delay_samples = v;
		delay_input_pointer = delay_output_pointer + delay_samples;

		if (delay_input_pointer >= delay_buffer_samples.length-1) {
			delay_input_pointer = delay_input_pointer - delay_buffer_samples.length; 
		}

		return delay_samples;
		
	}


}