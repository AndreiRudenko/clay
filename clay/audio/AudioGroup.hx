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

	public var channels_count (default, null):Int;

	var _max_channels:Int;
	var _cache: Float32Array;

	var _internal_channels:Vector<AudioChannel>;
	var _to_remove:Array<AudioChannel>;

	public function new(max_channels:Int = 32) {

		super();

		_max_channels = max_channels;
		channels_count = 0;
		_cache = new Float32Array(512);
		// output = Clay.audio;

		channels = new Vector(_max_channels);
		_internal_channels = new Vector(_max_channels);
		_to_remove = [];

	}

	public inline function add(channel:AudioChannel) {

		if(channels_count >= _max_channels) {
			trace('cant add channel, max channels: ${_max_channels}');
			return;
		}
		
		#if cpp
		clay.system.Audio.mutex.acquire();
		#end

		channels[channels_count++] = channel;

		#if cpp
		clay.system.Audio.mutex.release();
		#end

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

		#if cpp clay.system.Audio.mutex.acquire(); #end

		for (i in 0...channels_count) {
			_internal_channels[i] = channels[i];
		}

		#if cpp clay.system.Audio.mutex.release(); #end

		for (i in 0...channels_count) {
			if(!_internal_channels[i].mute) {
				_internal_channels[i].process(_cache, samples);
			}
		}

		if(_to_remove.length > 0) {

			#if cpp clay.system.Audio.mutex.acquire(); #end
			for (c in _to_remove) {
				for (i in 0...channels_count) {
					if(channels[i] == c) { // todo: remove rest from _internal_channels and channels
						channels[i] = channels[--channels_count];
						break;
					}
				}
			}
			#if cpp clay.system.Audio.mutex.release(); #end

			ArrayTools.clear(_to_remove);
		}

		process_effects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * volume * l;
			data[i*2+1] += _cache[i*2+1] * volume * r;
		}

	}


}