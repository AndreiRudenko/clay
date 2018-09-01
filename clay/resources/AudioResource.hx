package clay.resources;


import haxe.io.Bytes;
import kha.arrays.Float32Array;


class AudioResource extends Resource {


	@:noCompletion public var sound:kha.Sound;

	public var compressed_data(get, set):Bytes;
	public var uncompressed_data(get, set):kha.arrays.Float32Array;


	public function new(?_sound:kha.Sound) {

		if(_sound == null) {
			_sound = new kha.Sound();
		}

		sound = _sound;
		
	}

	inline function get_compressed_data() return sound.compressedData;
	inline function set_compressed_data(v:Bytes) return sound.compressedData = v;

	inline function get_uncompressed_data() return sound.uncompressedData;
	inline function set_uncompressed_data(v:Float32Array) return sound.uncompressedData = v;


}
