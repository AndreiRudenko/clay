package clay.resources;


import clay.system.ResourceManager;

@:access(kha.Kravur)
class FontResource extends Resource {


	@:noCompletion public var font:kha.Font;
	public var textures (default, null):Map<Int, Texture>;


	public function new(_font:kha.Font) {

		font = _font;
		textures = new Map();
		
		resourceType = ResourceType.font;
		
	}

	override function unload() {

		font.unload();
		for (t in textures) {
			t.unload();
		}
		
	}
	
	override function memoryUse() {
		
        return font.blob.length;
        
	}

	public function get(size:Int):Texture {

		var t = textures.get(size);

		if(t == null) {
			var k = font._get(size);
			t = new Texture(k.getTexture());
			t.id = id + "_" + size;
			textures.set(size, t);
			Clay.resources.add(t);
		}

		return t;
		
	}

	public function width(size:Int):Float {

		return font._get(size).getHeight();
		
	}

	public function height(size:Int, str:String):Float {

		return font._get(size).stringWidth(str);
		
	}

	public function charactersWidth(size:Int, characters:Array<Int>, start:Int, length:Int):Float {

		return font._get(size).charactersWidth(characters, start, length);

	}


}
