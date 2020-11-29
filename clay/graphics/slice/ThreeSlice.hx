package clay.graphics.slice;

import clay.graphics.Texture;
import clay.graphics.Vertex;

/*  
    0---1---2---3
    |   |   |   |
    4---5---6---7

    4---0
    |   |
    5---1
    |   |
    6---2
    |   |
    7---3
*/

// TODO: vertical/horizontal switch, instead of auto
class ThreeSlice extends Polygon {

	public var width(get, set):Float;
	var _width:Float;
	inline function get_width() return _width;
	function set_width(v:Float):Float {
		_width = v;
		updateVertices();
		return _width;
	}

	public var height(get, set):Float;
	var _height:Float;
	inline function get_height() return _height;
	function set_height(v:Float):Float {
		_height = v;
		updateVertices();
		return _height;
	}

	public var left(get, set):Float;
	var _left:Float;
	inline function get_left()return _left;
	function set_left(v:Float):Float {
		_left = v;
		updateVertices();
		return _left;
	}

	public var right(get, set):Float;
	var _right:Float;
	inline function get_right()return _right;
	function set_right(v:Float):Float {
		_right = v;
		updateVertices();
		return _right;
	}

	public function new(texture:Texture, left:Float, right:Float) {
		var vertices = [];
		for (i in 0...8) {
			vertices.push(new Vertex(0, 0));
		}

		var indices = [
			0,  1,  5,  5,  4,  0,  // 0
			1,  2,  6,  6,  5,  1,  // 1
			2,  3,  7,  7,  6,  2,  // 2
		];

		super(texture, vertices, indices);

		_left = left;
		_right = right;

		_width = 128;
		_height = 128;

		updateVertices();
	}

	override function set_texture(v:Texture):Texture {
		super.set_texture(v);

		updateVertices();

		return v;
	}

	function updateVertices() {
		var tw:Float = texture.widthActual;
		var th:Float = texture.heightActual;

		if(width > height) {
			var leftScale = (_height / _left)  * (_left / th);
			var rightScale = (_height / _right)  * (_right / th);
			vertices[0].x = vertices[4].x = 0; 
			vertices[1].x = vertices[5].x = _left * leftScale; 
			vertices[2].x = vertices[6].x = _width - _right * rightScale; 
			vertices[3].x = vertices[7].x = _width;

			vertices[0].y = vertices[1].y = vertices[2].y = vertices[3].y = 0; 
			vertices[4].y = vertices[5].y = vertices[6].y = vertices[7].y = _height; 
		} else {
			var leftScale = (_width / _left)  * (_left / th);
			var rightScale = (_width / _right)  * (_right / th);
			vertices[0].y = vertices[4].y = 0; 
			vertices[1].y = vertices[5].y = _left * leftScale; 
			vertices[2].y = vertices[6].y = _height - _right * rightScale; 
			vertices[3].y = vertices[7].y = _height;

			vertices[0].x = vertices[1].x = vertices[2].x = vertices[3].x = _width; 
			vertices[4].x = vertices[5].x = vertices[6].x = vertices[7].x = 0; 
		}

		vertices[0].u = vertices[4].u = 0; 
		vertices[1].u = vertices[5].u = _left / tw; 
		vertices[2].u = vertices[6].u = 1 - _right / tw; 
		vertices[3].u = vertices[7].u = 1;

		vertices[0].v = vertices[1].v = vertices[2].v = vertices[3].v = 0; 
		vertices[4].v = vertices[5].v = vertices[6].v = vertices[7].v = 1; 
	}

}
