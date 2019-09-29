package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;

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

		clay.system.Audio.mutexLock();
		var v = _mute;
		clay.system.Audio.mutexUnlock();

		return v;
		
	}

	function set_mute(v:Bool):Bool {

		clay.system.Audio.mutexLock();
		_mute = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_parent():AudioChannel {

		clay.system.Audio.mutexLock();
		var v = _parent;
		clay.system.Audio.mutexUnlock();

		return v;
		
	}

}