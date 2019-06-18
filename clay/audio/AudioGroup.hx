package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;

import clay.utils.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;


class AudioGroup extends AudioChannel {


	var _cache: Float32Array;

	@:noCompletion public var childs:Array<AudioChannel>;
	var _to_remove:Array<AudioChannel>;

	public function new() {

		super();

		_cache = new Float32Array(512);
		// output = Clay.audio;

		childs = [];
		_to_remove = [];

	}

	public inline function add(channel:AudioChannel) {
		
		childs.push(channel);

	}

	public inline function remove(channel:AudioChannel) {

		_to_remove.push(channel);

	}

	override function process(data:Float32Array, samples:Int) {
	    
		if (_cache.length < samples) {
			_cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_cache[i] = 0;
		}

		if(mute) {
			return;
		}

		for (ch in childs) {
			ch.process(_cache, samples);
		}

		if(_to_remove.length > 0) {
			for (c in _to_remove) {
				childs.remove(c);
			}
			ArrayTools.clear(_to_remove);
		}

		process_effects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * volume * l;
			data[i*2+1] += _cache[i*2+1] * volume * r;
		}

	}


}