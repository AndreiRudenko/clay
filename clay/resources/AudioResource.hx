package clay.resources;


import haxe.io.Bytes;
import kha.arrays.Float32Array;
import clay.core.Resources;


class AudioResource extends Resource {


	public var sound:kha.Sound;

	public var duration(get, never):Float;
	public var channels(get, never):Int;

	public var compressed_data(get, set):Bytes;
	public var uncompressed_data(get, set):kha.arrays.Float32Array;


	public function new(?_sound:kha.Sound) {

		if(_sound == null) {
			_sound = new kha.Sound();
		}

		sound = _sound;

		resource_type = ResourceType.audio;
		
	}

	override function unload() {

		sound.unload();
		
	}

	override function memory_use() {
		
        return sound.uncompressedData.length * sound.channels;
        
	}

	inline function get_duration() return sound.length;
	inline function get_channels() return sound.channels;

	inline function get_compressed_data() return sound.compressedData;
	inline function set_compressed_data(v:Bytes) return sound.compressedData = v;

	inline function get_uncompressed_data() return sound.uncompressedData;
	inline function set_uncompressed_data(v:Float32Array) return sound.uncompressedData = v;


}
