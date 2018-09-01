package clay.resources;


class JsonResource extends Resource {


	@:noCompletion public var json:Dynamic;


	public function new(_json:Dynamic) {

		json = _json;
		
	}


}
