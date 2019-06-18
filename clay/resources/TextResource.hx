package clay.resources;


import clay.system.ResourceManager;


class TextResource extends Resource {


	public var text:String;


	public function new(_text:String) {

		text = _text;
		
		resource_type = ResourceType.text;
		
	}

	override function memory_use() {
		
        return text != null ? text.length : 0;
        
	}


}
