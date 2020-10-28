package clay;

import kha.audio2.Buffer;
import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.utils.Math;
import clay.utils.Log;
import clay.audio.AudioGroup;
import clay.audio.Sound;

#if cpp
import sys.thread.Mutex;
#end

class Audio extends AudioGroup {

#if cpp
	static var mutex:Mutex;
	static var mutexLocked:Bool = false;
#end

	static public inline function mutexLock() {
#if cpp
		Log.assert(!mutexLocked, 'Audio: unlock mutex before locking');
		mutex.acquire();
		mutexLocked = true;
#end
	}
	static public inline function mutexUnlock() {
#if cpp
		Log.assert(mutexLocked, 'Audio: lock mutex before unlocking');
		mutex.release();
		mutexLocked = false;
#end
	}

	public var sampleRate(get, never):Int;
	var _data:Float32Array;

	@:allow(clay.App)
	function new() {
		super();
#if cpp
		mutex = new Mutex();
#end

		_data = new Float32Array(512);

		kha.audio2.Audio.audioCallback = mix;
	}

	public function play(res:AudioResource, volume:Float = 1, pan:Float = 0, pitch:Float = 1, loop:Bool = false, output:AudioGroup = null):Sound {
		var sound = new Sound(res, output);
		sound.volume = volume;
		sound.pan = pan;
		sound.pitch = pitch;
		sound.loop = loop;
		sound.play();

		return sound;
	}

	public function stream(res:AudioResource, volume:Float = 1, pan:Float = 0, pitch:Float = 1, loop:Bool = false, output:AudioGroup = null):Sound {
		// var sound = new Sound(res, output);
		// sound.volume = volume;
		// sound.pan = pan;
		// sound.pitch = pitch;
		// sound.loop = loop;
		// // sound.stream = true;
		// sound.play();

		return null;
	}

	public function stop(res:AudioResource) {

	}

	function mix(samplesbox:kha.internal.IntBox, buffer:Buffer) {
		var samples = samplesbox.value;

		if (_data.length < samples) {
			_data = new Float32Array(samples);
		}

		for (i in 0...samples) {
			_data[i] = 0;
		}

		if(!_mute) {
			process(_data, samples);
		}

		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, Math.clamp(_data[i], -1.0, 1.0) * _volume);
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}
	}

	inline function get_sampleRate():Int {
		return kha.audio2.Audio.samplesPerSecond;
	}

}
