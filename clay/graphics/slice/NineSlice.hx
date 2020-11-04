package clay.graphics.slice;

import clay.graphics.Texture;
import clay.graphics.Vertex;

/*  
	0---1---2---3
	|   |   |   |
	4---5---6---7
	|   |   |   |
	8---9---10--11
	|   |   |   |
	12--13--14--15
*/

class NineSlice extends Polygon {

	public var width(get, set):Float;
	var _width:Float;
	inline function get_width() return _width;
	function set_width(v:Float):Float {
		_width = v;
		updateWidth();
		return _width;
	}

	public var height(get, set):Float;
	var _height:Float;
	inline function get_height() return _height;
	function set_height(v:Float):Float {
		_height = v;
		updateHeight();
		return _height;
	}

	public var top(get, set):Float;
	var _top:Float;
	inline function get_top():Float return _top;
	function set_top(v:Float):Float {
		_top = v;
		updateHeight();
		return _top;
	}

	public var bottom(get, set):Float;
	var _bottom:Float;
	inline function get_bottom() return _bottom;
	function set_bottom(v:Float):Float {
		_bottom = v;
		updateHeight();
		return _bottom;
	}

	public var left(get, set):Float;
	var _left:Float;
	inline function get_left()return _left;
	function set_left(v:Float):Float {
		_left = v;
		updateWidth();
		return _left;
	}

	public var right(get, set):Float;
	var _right:Float;
	inline function get_right()return _right;
	function set_right(v:Float):Float {
		_right = v;
		updateWidth();
		return _right;
	}

	public var edgeScale(get, set):Float;
	var _edgeScale:Float;
	inline function get_edgeScale() return _edgeScale;
	function set_edgeScale(v:Float) {
		_edgeScale = v;
		updateWidth();
		updateHeight();
		return _edgeScale;
	}

	public var drawCender(get, set):Bool;
	var _drawCender:Bool = true;
	inline function get_drawCender() return _drawCender;
	function set_drawCender(v:Bool):Bool {
		_drawCender = v;
		indices = getIndices();
		return v;
	}

	public function new(texture:Texture, top:Float, left:Float, right:Float, bottom:Float) {
		var vertices = [];
		for (i in 0...16) {
			vertices.push(new Vertex(0, 0));
		}

		super(texture, vertices, getIndices());

		_top = top;
		_bottom = bottom;
		_left = left;
		_right = right;

		_width = 128;
		_height = 128;
		_edgeScale = 1;

		_drawCender = true;

		updateWidth();
		updateHeight();
	}

	override function set_texture(v:Texture):Texture {
		super.set_texture(v);

		updateWidth();
		updateHeight();

		return v;
	}

	function updateWidth() {
		var tw:Float = texture.widthActual;

		vertices[0].x = vertices[4].x = vertices[8].x = vertices[12].x = 0; 
		vertices[1].x = vertices[5].x = vertices[9].x = vertices[13].x = _left * _edgeScale; 
		vertices[2].x = vertices[6].x = vertices[10].x = vertices[14].x = _width - _right * _edgeScale; 
		vertices[3].x = vertices[7].x = vertices[11].x = vertices[15].x = _width;

		vertices[0].u = vertices[4].u = vertices[8].u = vertices[12].u = 0; 
		vertices[1].u = vertices[5].u = vertices[9].u = vertices[13].u = _left / tw; 
		vertices[2].u = vertices[6].u = vertices[10].u = vertices[14].u = 1 - _right / tw; 
		vertices[3].u = vertices[7].u = vertices[11].u = vertices[15].u = 1;
	}

	function updateHeight() {
		var th:Float = texture.heightActual;
		
		vertices[0].y = vertices[1].y = vertices[2].y = vertices[3].y = 0; 
		vertices[4].y = vertices[5].y = vertices[6].y = vertices[7].y = _top * _edgeScale; 
		vertices[8].y = vertices[9].y = vertices[10].y = vertices[11].y = _height - _bottom * _edgeScale; 
		vertices[12].y = vertices[13].y = vertices[14].y = vertices[15].y = _height; 

		vertices[0].v = vertices[1].v = vertices[2].v = vertices[3].v = 0; 
		vertices[4].v = vertices[5].v = vertices[6].v = vertices[7].v = _top / th; 
		vertices[8].v = vertices[9].v = vertices[10].v = vertices[11].v = 1 - _bottom / th; 
		vertices[12].v = vertices[13].v = vertices[14].v = vertices[15].v = 1; 
	}

	function getIndices() {
		if(_drawCender) {
			return [
				0,  1,  5,  5,  4,  0,  // 0
				1,  2,  6,  6,  5,  1,  // 1
				2,  3,  7,  7,  6,  2,  // 2
				4,  5,  9,  9,  8,  4,  // 3
				5,  6,  10, 10, 9,  5,  // 4
				6,  7,  11, 11, 10, 6,  // 5
				8,  9,  13, 13, 12, 8,  // 6
				9,  10, 14, 14, 13, 9,  // 7
				10, 11, 15, 15, 14, 10, // 8
			];
		} 

		return [
			0,  1,  5,  5,  4,  0,  // 0
			1,  2,  6,  6,  5,  1,  // 1
			2,  3,  7,  7,  6,  2,  // 2
			4,  5,  9,  9,  8,  4,  // 3
			// 5,  6,  10, 10, 9,  5,  // 4
			6,  7,  11, 11, 10, 6,  // 5
			8,  9,  13, 13, 12, 8,  // 6
			9,  10, 14, 14, 13, 9,  // 7
			10, 11, 15, 15, 14, 10, // 8
		];
		
	}

}
