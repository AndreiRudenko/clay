package clay.resources;


import haxe.io.Bytes;
import clay.core.Resources;


class BytesResource extends Resource {


	public static function create(_size:Int):BytesResource {
		
		var b = kha.Blob.alloc(_size);
		return new BytesResource(b);

	}

	public static function create_from_bytes(_bytes:Bytes):BytesResource {
		
		var b = kha.Blob.fromBytes(_bytes);
		return new BytesResource(b);

	}


	public var blob:kha.Blob;


	public function new(_blob:kha.Blob) {

		blob = _blob;

		resource_type = ResourceType.bytes;
		
	}

	override function unload() {

		blob.unload();
		
	}

	override function memory_use() {
		
		return blob.length;
		
	}


}