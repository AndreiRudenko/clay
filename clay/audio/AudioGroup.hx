package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;

import clay.utils.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;

import haxe.ds.Vector;


class AudioGroup extends AudioChannel {


	public var channels:Vector<AudioChannel>;

	public var channelsCount(default, null):Int;

	var _maxChannels:Int;
	var _cache:Float32Array;

	var _internalChannels:Vector<AudioChannel>;
	var _toRemove:Array<AudioChannel>;

	public function new(maxChannels:Int = 32) {

		super();

		_maxChannels = maxChannels;
		channelsCount = 0;
		_cache = new Float32Array(512);
		// output = Clay.audio;

		channels = new Vector(_maxChannels);
		_internalChannels = new Vector(_maxChannels);
		_toRemove = [];

	}

	public inline function add(channel:AudioChannel) {

		if(channelsCount >= _maxChannels) {
			trace('cant add channel, max channels: ${_maxChannels}');
			return;
		}
		
		clay.system.Audio.mutexLock();

		channels[channelsCount++] = channel;

		clay.system.Audio.mutexUnlock();

	}

	public inline function remove(channel:AudioChannel) {

		_toRemove.push(channel);

	}

	override function process(data:Float32Array, samples:Int) {
	    
		if (_cache.length < samples) {
			trace('Allocation request in audio thread. cache: ${_cache.length}, samples: $samples');
			_cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_cache[i] = 0;
		}

		if(mute) {
			return;
		}

		clay.system.Audio.mutexLock();
		for (i in 0...channelsCount) {
			_internalChannels[i] = channels[i];
		}
		clay.system.Audio.mutexUnlock();


		for (i in 0...channelsCount) {
			if(!_internalChannels[i].mute) {
				_internalChannels[i].process(_cache, samples);
			}
		}

		if(_toRemove.length > 0) {

			clay.system.Audio.mutexLock();
			for (c in _toRemove) {
				for (i in 0...channelsCount) {
					if(channels[i] == c) { // todo: remove rest from _internalChannels and channels
						channels[i] = channels[--channelsCount];
						break;
					}
				}
			}
			clay.system.Audio.mutexUnlock();

			ArrayTools.clear(_toRemove);
		}

		processEffects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * volume * l;
			data[i*2+1] += _cache[i*2+1] * volume * r;
		}

	}


}