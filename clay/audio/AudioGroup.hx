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


	static inline var channels_count:Int = 32;

	@:noCompletion public var childs:Vector<AudioChannel>;

	var _childs_count:Int;
	var _cache: Float32Array;

	var _internal_childs:Vector<AudioChannel>;
	var _to_remove:Array<AudioChannel>;

	public function new() {

		super();

		_childs_count = 0;
		_cache = new Float32Array(512);
		// output = Clay.audio;

		childs = new Vector(channels_count);
		_internal_childs = new Vector(channels_count);
		_to_remove = [];

	}

	public inline function add(channel:AudioChannel) {

		if(_childs_count >= channels_count) {
			trace('cant add child, max childs: ${channels_count}');
			return;
		}
		
		#if cpp
		clay.system.Audio.mutex.acquire();
		#end

		childs[_childs_count++] = channel;

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

		for (i in 0..._childs_count) {
			_internal_childs[i] = childs[i];
		}

		#if cpp clay.system.Audio.mutex.release(); #end

		for (i in 0..._childs_count) {
			_internal_childs[i].process(_cache, samples);
		}


		if(_to_remove.length > 0) {

			#if cpp clay.system.Audio.mutex.acquire(); #end
			for (c in _to_remove) {
				for (i in 0..._childs_count) {
					if(childs[i] == c) { // todo: remove rest from _internal_childs and childs
						childs[i] = childs[--_childs_count];
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