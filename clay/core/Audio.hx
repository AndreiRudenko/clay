package clay.core;

// import kha.Sound;
import kha.audio2.Audio;
import kha.audio2.AudioChannel;
import clay.resources.AudioResource;


class Audio {


	// public var master_volume(default, set):Float = 1;
	// public var master_pitch(default, set):Float = 1;

	var soundmap:Map<String, Sound> = new Map();
	var groupsmap:Map<String, SoundGroup> = new Map();

    @:allow(clay.Engine)
	function new() {}


	public inline function create_group(_name:String, ?_sounds:Array<Sound>):SoundGroup {

		var gr:SoundGroup = new SoundGroup(_name, _sounds);

		groupsmap.set(_name, gr);

		return gr;

	}

	public inline function get_group(_name:String):SoundGroup {

		return groupsmap.get(_name);

	}

	public inline function remove_group(_name:String):SoundGroup {

		var gr:SoundGroup = groupsmap.get(_name);

		if(gr != null) {
			gr.stop();
			groupsmap.remove(_name);
		}

		return gr;
		
	}

	public function create_sound(_name:String, _path:String):Sound {

		var res:AudioResource = Clay.resources.audio(_path);

		var snd:Sound = null;

		if(res != null) {
			snd = new Sound(_name, res);
			soundmap.set(_name, snd);
		}

		return snd;

	}

	public inline function get_sound(_name:String):Sound {

		return soundmap.get(_name);

	}

	public function remove_sound(_name:String):Sound {

		var snd:Sound = soundmap.get(_name);

		if(snd != null) {
			snd.stop();
			soundmap.remove(_name);
		}

		return snd;
		
	}


	// function set_master_volume(value:Float):Float {

	// 	for (s in soundmap) {
	// 		s.volume = s.volume;
	// 	}

	// 	return master_volume = value;

	// }

	// function set_master_pitch(value:Float):Float {

	// 	for (s in soundmap) {
	// 		s.pitch_all = s.pitch;
	// 	}

	// 	return master_pitch = value;

	// }


}


@:keep
@:allow(clay.core.Audio)
@:access(clay.core.Audio)
@:access(kha.audio2.AudioChannel)
class Sound {


	public var name    	(default, null):String;
	public var source  	(default, null):AudioResource;
	public var channel 	(default, null):AudioChannel;

	public var loop  	(get, set):Bool;
	public var volume  	(get, set):Float;
	@:isVar public var length  	(get, never):Float; // Seconds
	@:isVar public var position	(get, never):Float; // Seconds
	@:isVar public var finished	(get, never):Bool;
	

	inline function new(_name:String, _source:AudioResource) {

		name = _name;
		source = _source;
		channel = new AudioChannel(false);
		channel.data = source.uncompressed_data;
		
	}

	public inline function play() channel.play();
	public inline function pause() channel.pause();
	public inline function stop() channel.stop();

	inline function get_length() return channel.length;
	inline function get_position() return channel.position;
	inline function get_volume() return channel.volume; 
	inline function set_volume(value:Float) return channel.volume = value;
	inline function get_loop() return channel.looping; 
	inline function set_loop(value:Bool) return channel.looping = value;
	inline function get_finished() return channel.finished;

}


@:keep
@:allow(clay.core.Audio)
@:access(clay.core.Audio)
class SoundGroup {


	public var name(default, null):String;

	public var sounds(default, null):Map<String, Sound> = new Map();


	inline function new(_name:String, ?_sounds:Array<Sound>) {

		name = _name;

		if(_sounds != null) {
			for (s in _sounds) {
				sounds.set(s.name, s);
			}
		}
		
	}

	public inline function add(_sound:Sound) {

		if(_sound != null) {
			sounds.set(_sound.name, _sound);
		}

	}

	public inline function remove(_soundname:String) {

		sounds.remove(_soundname);

	}

	public inline function play() {

		for (s in sounds) {
			s.play();
		}

	}

	public inline function stop() {

		for (s in sounds) {
			s.stop();
		}

	}

	public inline function pause() {

		for (s in sounds) {
			s.pause();
		}

	}

	// public inline function unpause() {

	// 	for (s in sounds) {
	// 		s.unpause();
	// 	}

	// }

	public function destroy() {

		stop();

		Clay.audio.groupsmap.remove(name);

		sounds = null;

	}


}
