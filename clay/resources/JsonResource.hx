package clay.resources;

import clay.resources.ResourceManager;

class JsonResource extends Resource {

	public var json:Dynamic;

	public function new(json:Dynamic) {
		this.json = json;
		resourceType = ResourceType.JSON;
	}

}
