package clay.resources;


import clay.core.Resources;


class JsonResource extends Resource {


	public var json:Dynamic;


	public function new(_json:Dynamic) {

		json = _json;
		resource_type = ResourceType.json;
		
	}


}
