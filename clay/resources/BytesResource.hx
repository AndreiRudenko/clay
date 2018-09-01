package clay.resources;


import haxe.io.Bytes;


class BytesResource extends Resource {


	public static function create(_size:Int):BytesResource {
	    
		var b = kha.Blob.alloc(_size);
		return new BytesResource(b);

	}

	public static function create_from_bytes(_bytes:Bytes):BytesResource {
	    
		var b = kha.Blob.fromBytes(_bytes);
		return new BytesResource(b);

	}


	@:noCompletion public var blob:kha.Blob;


	public function new(_blob:kha.Blob) {

		blob = _blob;
		
	}


}