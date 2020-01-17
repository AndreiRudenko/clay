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

	var _channels:Vector<AudioChannel>;
	var _channelsCount:Int;
	var _dirtyChannels:Bool;

	var _maxChannels:Int;
	var _cache:Float32Array;

	var _channelsInternal:Vector<AudioChannel>;


	public function new(maxChannels:Int = 32) {

		super();

		_maxChannels = maxChannels;
		_channelsCount = 0;
		_cache = new Float32Array(512);
		_dirtyChannels = true;

		_channels = new Vector(_maxChannels);
		_channelsInternal = new Vector(_maxChannels);

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
			var found = false;
			for (i in 0..._channelsCount) {
				if(_channels[i] == channel) { // todo: remove rest from _channelsInternal and channels
					_channels[i] = _channels[--_channelsCount];
					found = true;
					break;
				}
			}
			if(!found) {
				log('can`t remove channel ?');
			}
			_dirtyChannels = true;
		} else {
			log('can`t remove channel, it not belong to this group');
		}

		clay.system.Audio.mutexUnlock();

	}

	override function process(data:Float32Array, bufferSamples:Int) {
	    
		if (_cache.length < bufferSamples) {
			clay.system.Audio.mutexLock();
			log('Allocation request in audio thread. cache: ${_cache.length}, samples: $bufferSamples');
			clay.system.Audio.mutexUnlock();
			_cache = new Float32Array(bufferSamples);
		}

		var i:Int = 0;
		while(i < bufferSamples) {
			_cache[i] = 0;
			i++;
		}

		clay.system.Audio.mutexLock();

		if(_dirtyChannels) {
			var j:Int = 0;
			while(j < _channelsCount) {
				_channelsInternal[j] = _channels[j];
				j++;
			}
			_dirtyChannels = false;
		}

		var count = _channelsCount;

		clay.system.Audio.mutexUnlock();

		i = 0;
		while(i < count) {
			if(!_channelsInternal[i]._mute) {
				_channelsInternal[i].process(_cache, bufferSamples);
			}
			i++;
		}

		processEffects(_cache, bufferSamples);

		i = 0;
		while(i < bufferSamples) {
			data[i] += _cache[i] * _volume * _l;
			data[i+1] += _cache[i+1] * _volume * _r;
			i +=2;
		}

	}

	function get_channels():Array<AudioChannel> {

		clay.system.Audio.mutexLock();
		var v = [];
		for (i in 0..._channelsCount) {
			v.push(_channels[i]);
		}
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