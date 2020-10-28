package clay.graphics;

import clay.graphics.Texture;
import clay.graphics.Vertex;

class Polygon {

	public var texture(get, set):Texture;
	var _texture:Texture;
	inline function get_texture() return _texture; 
	function set_texture(value:Texture) return _texture = value;
	
	public var vertices:Array<Vertex>;
	public var indices:Array<Int>;

	public function new(texture:Texture, vertices:Array<Vertex>, indices:Array<Int>) {
		_texture = texture;
		this.vertices = vertices;
		this.indices = indices;
	}

}
