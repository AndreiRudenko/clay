package clay.resources;

import clay.Resources;

@:allow(clay.Resources)
class Resource {

	public var name:String;
	public var id(default, null):Int = -1;
    public var resourceType(default, null):ResourceType;
    public var references(default, null):Int = 0;

	public function unload() {}

	public function memoryUse():Int {
		return 0;
	}

	public function ref() {
		references++;
	}

	public function unref() {
		references--;
	}

}
