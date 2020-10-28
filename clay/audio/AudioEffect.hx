package clay.audio;


import clay.utils.Math;
import clay.Audio;

@:allow(clay.audio.AudioChannel)
class AudioEffect {

	public var mute(get, set):Bool;
	public var parent(get, null):AudioChannel;

	var _mute:Bool;
	var _parent:AudioChannel;

	public function new() {
		_mute = false;
	}

	public function process(samples:Int, buffer:kha.arrays.Float32Array, sampleRate:Int) {}

	function get_mute():Bool {
		Audio.mutexLock();
		var v = _mute;
		Audio.mutexUnlock();

		return v;
	}

	function set_mute(v:Bool):Bool {
		Audio.mutexLock();
		_mute = v;
		Audio.mutexUnlock();

		return v;
	}

	function get_parent():AudioChannel {
		Audio.mutexLock();
		var v = _parent;
		Audio.mutexUnlock();
		
		return v;
	}

}