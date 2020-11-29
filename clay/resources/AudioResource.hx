package clay.resources;

import haxe.io.Bytes;
import clay.utils.Float32Array;
import clay.resources.Resource;
import clay.Resources;

class AudioResource extends Resource {

	public var sound:kha.Sound;

	public var duration(get, never):Float;
	inline function get_duration() return sound.length;

	public var channels(get, never):Int;
	inline function get_channels() return sound.channels;

	public var compressedData(get, set):Bytes;
	inline function get_compressedData() return sound.compressedData;
	inline function set_compressedData(v:Bytes) return sound.compressedData = v;
	
	public var uncompressedData(get, set):Float32Array;
	inline function get_uncompressedData() return sound.uncompressedData;
	inline function set_uncompressedData(v:Float32Array) return sound.uncompressedData = v;

	public function new(?sound:kha.Sound) {
		if(sound == null) {
			sound = new kha.Sound();
		}

		this.sound = sound;

		resourceType = ResourceType.AUDIO;
	}

	override function unload() {
		sound.unload();
	}

	override function memoryUse() {
        return sound.uncompressedData.length;
	}

}
