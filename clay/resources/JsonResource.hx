package clay.resources;


import clay.system.ResourceManager;


class JsonResource extends Resource {


	public var json:Dynamic;


	public function new(json:Dynamic) {

		this.json = json;
		resourceType = ResourceType.json;
		
	}


}
