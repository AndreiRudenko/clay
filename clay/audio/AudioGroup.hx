package clay.audio;


import clay.math.Mathf;
import clay.utils.Log.*;

import clay.math.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;


class AudioGroup extends AudioChannel {


	var cache: Float32Array;


	public function new() {

		super();

		cache = new Float32Array(512);
		output = Clay.audio;

	}

	override function process(data: Float32Array, samples: Int) {
	    
		if (cache.length < samples) {
			cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			cache[i] = 0;
		}

		if(mute) {
			return;
		}

		var ch:AudioChannel = childs.head;
		var n:AudioChannel;
		while (ch != null) {
			n = ch.next;
			ch.process(cache, samples);
			ch = n;
		}
		
		process_effects(cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += cache[i*2] * volume * l;
			data[i*2+1] += cache[i*2+1] * volume * r;
		}

	}


}