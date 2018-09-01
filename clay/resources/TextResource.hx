package clay.resources;


class TextResource extends Resource {


	@:noCompletion public var text:String;


	public function new(_text:String) {

		text = _text;
		
	}


}
