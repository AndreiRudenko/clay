package clay.graphics.slice;

import clay.math.Vector;
import clay.render.Vertex;
import clay.resources.Texture;
import clay.graphics.Mesh;

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

class ThreeSlice extends Mesh {

	public var width(get, set):Float;
	public var height(get, set):Float;

	public var left(get, set):Float;
	public var right(get, set):Float;

	var _width:Float;
	var _height:Float;

	var _left:Float;
	var _right:Float;

	public function new(left:Float, right:Float) {
		var vertices = [];
		for (i in 0...8) {
			vertices.push(new Vertex(new Vector(), color));
		}

		var indices = [
			0,  1,  5,  5,  4,  0,  // 0
			1,  2,  6,  6,  5,  1,  // 1
			2,  3,  7,  7,  6,  2,  // 2
		];

		super(vertices, indices);
		name = 'ThreeSlice.${clay.utils.UUID.get()}';

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
		if(texture == null) {
			return;
		}
		var tw:Float = texture.widthActual;
		var th:Float = texture.heightActual;

		if(region != null) {
			tw = region.w;
			th = region.h;
		}

		var leftScale = (_height / _left)  * (_left / th);
		var rightScale = (_height / _right)  * (_right / th);

		if(width > height) {
			vertices[0].pos.x = vertices[4].pos.x = 0; 
			vertices[1].pos.x = vertices[5].pos.x = _left * leftScale; 
			vertices[2].pos.x = vertices[6].pos.x = _width - _right * rightScale; 
			vertices[3].pos.x = vertices[7].pos.x = _width;

			vertices[0].pos.y = vertices[1].pos.y = vertices[2].pos.y = vertices[3].pos.y = 0; 
			vertices[4].pos.y = vertices[5].pos.y = vertices[6].pos.y = vertices[7].pos.y = _height; 
		} else {
			vertices[0].pos.y = vertices[4].pos.y = 0; 
			vertices[1].pos.y = vertices[5].pos.y = _left * leftScale; 
			vertices[2].pos.y = vertices[6].pos.y = _width - _right * rightScale; 
			vertices[3].pos.y = vertices[7].pos.y = _width;

			vertices[0].pos.x = vertices[1].pos.x = vertices[2].pos.x = vertices[3].pos.x = _height; 
			vertices[4].pos.x = vertices[5].pos.x = vertices[6].pos.x = vertices[7].pos.x = 0; 
		}

		vertices[0].tcoord.x = vertices[4].tcoord.x = 0; 
		vertices[1].tcoord.x = vertices[5].tcoord.x = _left / tw; 
		vertices[2].tcoord.x = vertices[6].tcoord.x = 1 - _right / tw; 
		vertices[3].tcoord.x = vertices[7].tcoord.x = 1;

		vertices[0].tcoord.y = vertices[1].tcoord.y = vertices[2].tcoord.y = vertices[3].tcoord.y = 0; 
		vertices[4].tcoord.y = vertices[5].tcoord.y = vertices[6].tcoord.y = vertices[7].tcoord.y = 1; 
	}

	inline function get_width():Float {
		return _width;
	}

	function set_width(v:Float):Float {
		if(_width != v) {
			_width = v;
			updateVertices();
		}

		return _width;
	}

	inline function get_height():Float {
		return _height;
	}
	
	function set_height(v:Float):Float {
		if(_height != v) {
			_height = v;
			updateVertices();
		}

		return _height;
	}

	inline function get_left():Float {
		return _left;
	}

	function set_left(v:Float):Float {
		_left = v;
		updateVertices();

		return _left;
	}

	inline function get_right():Float {
		return _right;
	}

	function set_right(v:Float):Float {
		_right = v;
		updateVertices();

		return _right;
	}

}
