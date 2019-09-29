package clay.audio;


import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.audio.AudioChannel;
import clay.audio.AudioEffect;
import clay.audio.AudioGroup;
import clay.utils.Mathf;
import clay.utils.Log.*;

class Sound extends AudioChannel {


	public var resource(get, set):AudioResource;

	public var pitch(get, set):Float;
	public var time(get, set):Float;
	public var duration(get, never):Float;
	public var position(get, set):Int;
	public var length(get, never):Int;

	public var paused(get, null):Bool;
	public var playing(get, never):Bool;
	public var finished(get, null):Bool;
	public var channels(get, never):Int;

	public var loop(get, set):Bool;

	@:noCompletion public var _added:Bool;

	var _resource:AudioResource;
	var _paused:Bool;
	var _pitch:Float;
	var _positionIdx:Int;
	var _position:Float;
	var _loop:Bool;
	var _finished:Bool;

	var _cache:Float32Array;
	var _outputToPlay:AudioGroup;


	public function new(?resource:AudioResource, output:AudioGroup = null, maxEffects:Int = 8) {

		super(maxEffects);

		_resource = resource;
		_outputToPlay = output != null ? output : Clay.audio;

		_pitch = 1;
		_positionIdx = 0;
		_position = 0;

		_paused = false;
		_loop = false;
		_finished = false;
		_added = false;

		_cache = new Float32Array(512);
		
	}

	override function process(data:Float32Array, samples:Int) {

		if(_resource == null) {
			return;
		}
	    
		if (_cache.length < samples) {
			_cache = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_cache[i] = 0;
		}

		if(_finished) {
			_outputToPlay.remove(this);
			_added = false;
			return;
		}

		var soundData = _resource.uncompressedData;
		var wPtr = 0;
		var chkPtr = 0;
		while (wPtr < samples) {
			// compute one chunk to render
			var addressableData = soundData.length - _positionIdx;
			var nextChunk = addressableData < (samples - wPtr) ? addressableData : (samples - wPtr);
			while (chkPtr < nextChunk) {
				_cache[wPtr] = soundData[_positionIdx];
				_position += _pitch;
				_positionIdx = Math.floor(_position);
				// ++_positionIdx;
				++chkPtr;
				++wPtr;
			}
			// loop to next chunk if applicable
			if (!_loop) {
				break;
			} else { 
				chkPtr = 0;
				if (_positionIdx >= soundData.length) {
					_positionIdx = 0;
					_position = 0;
				}
			}
		}
		// fill empty
		while (wPtr < samples) {
			_cache[wPtr] = 0;
			++wPtr;
		}

		processEffects(_cache, samples);

		for (i in 0...Std.int(samples/2)) {
			data[i*2] += _cache[i*2] * _volume * _l;
			data[i*2+1] += _cache[i*2+1] * _volume * _r;
		}

		if (_positionIdx >= soundData.length) {
			_finished = true;
		}
	}

	public function play():Sound {

		clay.system.Audio.mutexLock();

		_finished = false;
		_paused = false;
		_position = 0;
		_positionIdx = 0;

		if(_resource != null) {
			if(_outputToPlay != null) {
				if(!_added) {
					_outputToPlay.add(this);
					_added = true;
				}
			} else {
				log("cant play: there is no output channel for sound");
			}
		} else {
			log("there is no audio _resource to play");
		}

		clay.system.Audio.mutexUnlock();
		
		return this;

	}

	public function stop():Sound {
		
		clay.system.Audio.mutexLock();

		if(_resource != null) {
			if(_outputToPlay != null) {
				if(!_added) {
					_outputToPlay.remove(this);
					_added = false;
				}
			} else {
				log("cant stop: there is no output channel for sound");
			}
		} else {
			log("there is no audio _resource, nothing to stop");
		}

		clay.system.Audio.mutexUnlock();

		return this;

	}

	public function pause():Sound {
		
		clay.system.Audio.mutexLock();
		_paused = true;
		clay.system.Audio.mutexUnlock();

		return this;

	}

	public function unpause():Sound {

		clay.system.Audio.mutexLock();
		_paused = false;
		clay.system.Audio.mutexUnlock();
		
		return this;

	}

	public function setOutput(output:AudioGroup):Sound {

		clay.system.Audio.mutexLock();
		if(_outputToPlay != null) {
			if(_added) {
				_outputToPlay.remove(this);
			}
		}
		_outputToPlay = output;
		clay.system.Audio.mutexUnlock();

		return this;
		
	}

	function get_resource():AudioResource {

		clay.system.Audio.mutexLock();
		var v = _resource;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_resource(v:AudioResource):AudioResource {

		clay.system.Audio.mutexLock();
		_resource = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_paused():Bool {

		clay.system.Audio.mutexLock();
		var v = _paused;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_pitch():Float {

		clay.system.Audio.mutexLock();
		var v = _pitch;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_pitch(v:Float):Float {

		clay.system.Audio.mutexLock();
		_pitch = Mathf.clampBottom(v, 0.01); // todo: 0?
		v = _pitch;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_loop():Bool {

		clay.system.Audio.mutexLock();
		var v = _loop;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_loop(v:Bool):Bool {

		clay.system.Audio.mutexLock();
		_loop = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_time():Float {

		clay.system.Audio.mutexLock();
		var v = _positionIdx / Clay.audio._sampleRate / _getChannels();
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_time(v:Float):Float { // TODO: implement this

		// clay.system.Audio.mutexLock();
		// _positionIdx = Std.int(v * Clay.audio._sampleRate * _getChannels())
		// _position = _positionIdx;
		// clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_finished():Bool { 

		clay.system.Audio.mutexLock();
		// var v = _positionIdx >= _getLength();
		var v = _finished;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_playing():Bool { 

		clay.system.Audio.mutexLock();
		var v = _added;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_position():Int {

		clay.system.Audio.mutexLock();
		var v = _positionIdx;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_position(v:Int):Int {

		clay.system.Audio.mutexLock();
		_positionIdx = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_length():Int {

		clay.system.Audio.mutexLock();
		var v = _getLength();
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_channels():Int {

		clay.system.Audio.mutexLock();
		var v = _getChannels();
		clay.system.Audio.mutexUnlock();

		return 0;

	}

	function get_duration():Float {

		clay.system.Audio.mutexLock();
		var v = _getDuration();
		clay.system.Audio.mutexUnlock();

		return 0;

	}

	function _getChannels():Int {
		
		if(_resource != null) {
			return _resource.channels;
		}

		return 0;

	}

	function _getLength():Int {
		
		if(_resource != null) {
			return _resource.uncompressedData.length;
		}

		return 0;

	}

	function _getDuration():Float {
		
		if(_resource != null) {
			return _resource.uncompressedData.length / Clay.audio._sampleRate / _resource.channels;
		}

		return 0;

	}


}