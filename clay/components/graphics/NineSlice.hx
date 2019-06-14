package clay.components.graphics;


import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.data.Color;
import clay.ds.Int32RingBuffer;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.components.graphics.Geometry;
import clay.utils.Log.*;
import clay.utils.PowerOfTwo;


class NineSlice extends Geometry {


	public var width 	(get, set):Float;
	public var height	(get, set):Float;

	public var top 	    (get, set):Float;
	public var bottom	(get, set):Float;
	public var left	    (get, set):Float;
	public var right 	(get, set):Float;

	public var draw_cender(default, set):Bool;

	var _width:Float;
	var _height:Float;

	var _top:Float;
	var _bottom:Float;
	var _left:Float;
	var _right:Float;


	public function new(options:NineSliceOptions) {

		super(options);

		for (i in 0...16) {
			options.vertices.push(new Vertex(new Vector(), color));
		}

		draw_cender = def(options.draw_cender, true);

		_top = def(options.top, 32);
		_bottom = def(options.bottom, 32);
		_left = def(options.left, 32);
		_right = def(options.right, 32);

		_width = def(options.width, 128);
		_height = def(options.height, 128);

		update_width();
		update_height();

	}

	override function set_texture(v:Texture):Texture {

		super.set_texture(v);

		if(added) {
			update_width();
			update_height();
		}

		return v;
		
	}

	function update_width() {

		if(texture == null) {
			return;
		}
		
		var tw = texture.width_actual;
		
		vertices[0].pos.x = vertices[4].pos.x = vertices[8].pos.x = vertices[12].pos.x = 0; 
		vertices[1].pos.x = vertices[5].pos.x = vertices[9].pos.x = vertices[13].pos.x = _left; 
		vertices[2].pos.x = vertices[6].pos.x = vertices[10].pos.x = vertices[14].pos.x = _width - _right; 
		vertices[3].pos.x = vertices[7].pos.x = vertices[11].pos.x = vertices[15].pos.x = _width;

		vertices[0].tcoord.x = vertices[4].tcoord.x = vertices[8].tcoord.x = vertices[12].tcoord.x = 0; 
		vertices[1].tcoord.x = vertices[5].tcoord.x = vertices[9].tcoord.x = vertices[13].tcoord.x = _left / tw; 
		vertices[2].tcoord.x = vertices[6].tcoord.x = vertices[10].tcoord.x = vertices[14].tcoord.x = 1 - _right / tw; 
		vertices[3].tcoord.x = vertices[7].tcoord.x = vertices[11].tcoord.x = vertices[15].tcoord.x = 1;

	}

	function update_height() {
		
		if(texture == null) {
			return;
		}

		var th = texture.height_actual;

		vertices[0].pos.y = vertices[1].pos.y = vertices[2].pos.y = vertices[3].pos.y = 0; 
		vertices[4].pos.y = vertices[5].pos.y = vertices[6].pos.y = vertices[7].pos.y = _top; 
		vertices[8].pos.y = vertices[9].pos.y = vertices[10].pos.y = vertices[11].pos.y = _height - _bottom; 
		vertices[12].pos.y = vertices[13].pos.y = vertices[14].pos.y = vertices[15].pos.y = _height; 

		vertices[0].tcoord.y = vertices[1].tcoord.y = vertices[2].tcoord.y = vertices[3].tcoord.y = 0; 
		vertices[4].tcoord.y = vertices[5].tcoord.y = vertices[6].tcoord.y = vertices[7].tcoord.y = _top / th; 
		vertices[8].tcoord.y = vertices[9].tcoord.y = vertices[10].tcoord.y = vertices[11].tcoord.y = 1 - _bottom / th; 
		vertices[12].tcoord.y = vertices[13].tcoord.y = vertices[14].tcoord.y = vertices[15].tcoord.y = 1; 

	}

	function update_indices() {

		if(draw_cender) {
			indices = [
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
		} else {
			indices = [
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

	function set_draw_cender(v:Bool):Bool {
		
		draw_cender = v;
		update_indices();

		return draw_cender;

	}

	inline function get_width():Float {
		
		return _width;

	}

	function set_width(v:Float):Float {
		
		if(_width != v) {
			_width = v;
			update_width();
		}

		return _width;

	}
	inline function get_height():Float {
		
		return _height;

	}
	
	function set_height(v:Float):Float {
		
		if(_height != v) {
			_height = v;
			update_height();
		}

		return _height;

	}

	inline function get_top():Float {
		
		return _top;

	}

	function set_top(v:Float):Float {
		
		_top = v;
		update_height();

		return _top;

	}

	inline function get_bottom():Float {
		
		return _bottom;

	}

	function set_bottom(v:Float):Float {
		
		_bottom = v;
		update_height();

		return _bottom;

	}

	inline function get_left():Float {
		
		return _left;

	}

	function set_left(v:Float):Float {
		
		_left = v;
		update_width();

		return _left;

	}

	inline function get_right():Float {
		
		return _right;

	}

	function set_right(v:Float):Float {
		
		_right = v;
		update_width();

		return _right;

	}


}

typedef NineSliceOptions = {

	>GeometryOptions,

	@:optional var draw_cender:Bool;

		/** the top size of the nineslice, in the texture (pixels) */
	@:optional var top:Float;
		/** the left size of the nineslice, in the texture (pixels) */
	@:optional var left:Float;
		/** the right size of the nineslice, in the texture (pixels) */
	@:optional var right:Float;
		/** the bottom size of the nineslice, in the texture (pixels) */
	@:optional var bottom:Float;

	@:optional var width:Float;
	@:optional var height:Float;
	
}
