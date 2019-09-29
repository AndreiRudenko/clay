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


	public var channels(get, null):Array<AudioChannel>;
	public var channelsCount(get, null):Int;

	// public var channelsVolume(default, null):Float32Array;

	var _channels:Vector<AudioChannel>;
	var _channelsCount:Int;
	var _dirtyChannels:Bool;

	var _maxChannels:Int;
	var _cache:Float32Array;

	var _channelsInternal:Vector<AudioChannel>;
	var _channelsToRemove:Array<AudioChannel>;


	public function new(maxChannels:Int = 32) {

		super();

		_maxChannels = maxChannels;
		_channelsCount = 0;
		_cache = new Float32Array(512);
		_dirtyChannels = true;

		_channels = new Vector(_maxChannels);
		// channelsVolume = new Float32Array(_maxChannels);
		_channelsInternal = new Vector(_maxChannels);
		_channelsToRemove = [];

	}

	public function add(channel:AudioChannel) {

		clay.system.Audio.mutexLock();

		if(channel == this) {
			clay.system.Audio.mutexUnlock();
			log('can`t add channel to itself');
			return;
		}

		if(channel._output == this) {
			clay.system.Audio.mutexUnlock();
			log('channel already added to group');
			return;
		}

		if(_channelsCount >= _maxChannels) {
			clay.system.Audio.mutexUnlock();
			log('can`t add channel, max channels: ${_maxChannels}');
			return;
		}

		if(channel._output != null) {
			channel._output.remove(channel);
		}

		channel._output = this;
		_channels[_channelsCount++] = channel;
		_dirtyChannels = true;

		clay.system.Audio.mutexUnlock();

	}

	public function remove(channel:AudioChannel) {

		clay.system.Audio.mutexLock();

		if(channel._output == this) {
			channel._output = null;
			_channelsToRemove.push(channel);
			_dirtyChannels = true;
		} else {
			log('cant remove channel, it not belong to this group');
		}

		clay.system.Audio.mutexUnlock();

	}

	override function process(data:Float32Array, samples:Int) {
	    
		if (_cache.length < samples) {
			log('Allocation request in audio thread. cache: ${_cache.length}, samples: $samples');
			_cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_cache[i] = 0;
		}

		clay.system.Audio.mutexLock();

		if(_dirtyChannels) {
			if(_channelsToRemove.length > 0) {
				for (c in _channelsToRemove) {
					for (i in 0..._channelsCount) {
						if(_channels[i] == c) { // todo: remove rest from _channelsInternal and channels
							_channels[i] = _channels[--_channelsCount];
							break;
						}
					}
				}
				ArrayTools.clear(_channelsToRemove);
			}
			for (i in 0..._channelsCount) {
				_channelsInternal[i] = _channels[i];
			}
			_dirtyChannels = false;
		}

		var count = _channelsCount;

		clay.system.Audio.mutexUnlock();

		for (i in 0...count) {
			if(!_channelsInternal[i]._mute) {
				_channelsInternal[i].process(_cache, samples);
			}
		}

		processEffects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * _volume * _l;
			data[i*2+1] += _cache[i*2+1] * _volume * _r;
		}

	}

	function get_channels():Array<AudioChannel> {

		clay.system.Audio.mutexLock();
		var v = _channels.toArray();
		clay.system.Audio.mutexUnlock();

		return v;
		
	}

	function get_channelsCount():Int {

		clay.system.Audio.mutexLock();
		var v = _channelsCount;
		clay.system.Audio.mutexUnlock();

		return v;
		
	}


}