package clay.resources;

import clay.resources.ResourceManager;

class Resource {

	public var id:String;
    public var resourceType:ResourceType;
    public var references(default, null):Int = 0;

	public function unload() {}

	public function memoryUse():Int {
		return 0;
	}

	@:noCompletion public function ref() {
		references++;
	}

	@:noCompletion public function unref() {
		references--;
	}

}
