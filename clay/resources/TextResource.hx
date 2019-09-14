package clay.resources;


import clay.system.ResourceManager;


class TextResource extends Resource {


	public var text:String;


	public function new(_text:String) {

		text = _text;
		
		resourceType = ResourceType.text;
		
	}

	override function memoryUse() {
		
        return text != null ? text.length : 0;
        
	}


}
