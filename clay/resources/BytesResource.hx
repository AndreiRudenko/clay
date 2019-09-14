package clay.resources;


import haxe.io.Bytes;
import clay.system.ResourceManager;


class BytesResource extends Resource {


	public static function create(_size:Int):BytesResource {
		
		var b = kha.Blob.alloc(_size);
		return new BytesResource(b);

	}

	public static function createFromBytes(_bytes:Bytes):BytesResource {
		
		var b = kha.Blob.fromBytes(_bytes);
		return new BytesResource(b);

	}


	public var blob:kha.Blob;


	public function new(_blob:kha.Blob) {

		blob = _blob;

		resourceType = ResourceType.bytes;
		
	}

	override function unload() {

		blob.unload();
		
	}

	override function memoryUse() {
		
		return blob.length;
		
	}


}