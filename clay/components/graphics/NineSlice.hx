package clay.components.graphics;


import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.data.Color;
import clay.ds.Int32RingBuffer;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.components.graphics.Texture;
import clay.components.graphics.Geometry;
import clay.utils.Log.*;
import clay.utils.PowerOfTwo;


class NineSlice extends Geometry {


	public var width 	(default, set):Float;
	public var height	(default, set):Float;

	var top:Float;
	var left:Float;
	var right:Float;
	var bottom:Float;


	public function new(_options:NineSliceOptions) {

		super(_options);

		top = def(_options.top, 32);
		left = def(_options.left, 32);
		right = def(_options.right, 32);
		bottom = def(_options.bottom, 32);

		width = def(_options.width, 128);
		height = def(_options.height, 128);

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

		for (i in 0...16) {
			add(new Vertex(new Vector(), color));
		}

		set_geometry_type(GeometryType.polygon);

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
		vertices[1].pos.x = vertices[5].pos.x = vertices[9].pos.x = vertices[13].pos.x = left; 
		vertices[2].pos.x = vertices[6].pos.x = vertices[10].pos.x = vertices[14].pos.x = width - right; 
		vertices[3].pos.x = vertices[7].pos.x = vertices[11].pos.x = vertices[15].pos.x = width;

		vertices[0].tcoord.x = vertices[4].tcoord.x = vertices[8].tcoord.x = vertices[12].tcoord.x = 0; 
		vertices[1].tcoord.x = vertices[5].tcoord.x = vertices[9].tcoord.x = vertices[13].tcoord.x = left / tw; 
		vertices[2].tcoord.x = vertices[6].tcoord.x = vertices[10].tcoord.x = vertices[14].tcoord.x = 1 - right / tw; 
		vertices[3].tcoord.x = vertices[7].tcoord.x = vertices[11].tcoord.x = vertices[15].tcoord.x = 1;

	}

	function update_height() {
		
		if(texture == null) {
			return;
		}

		var th = texture.height_actual;

		vertices[0].pos.y = vertices[1].pos.y = vertices[2].pos.y = vertices[3].pos.y = 0; 
		vertices[4].pos.y = vertices[5].pos.y = vertices[6].pos.y = vertices[7].pos.y = top; 
		vertices[8].pos.y = vertices[9].pos.y = vertices[10].pos.y = vertices[11].pos.y = height - bottom; 
		vertices[12].pos.y = vertices[13].pos.y = vertices[14].pos.y = vertices[15].pos.y = height; 

		vertices[0].tcoord.y = vertices[1].tcoord.y = vertices[2].tcoord.y = vertices[3].tcoord.y = 0; 
		vertices[4].tcoord.y = vertices[5].tcoord.y = vertices[6].tcoord.y = vertices[7].tcoord.y = top / th; 
		vertices[8].tcoord.y = vertices[9].tcoord.y = vertices[10].tcoord.y = vertices[11].tcoord.y = 1 - bottom / th; 
		vertices[12].tcoord.y = vertices[13].tcoord.y = vertices[14].tcoord.y = vertices[15].tcoord.y = 1; 

	}

	function set_width(v:Float):Float {
		
		width = v;

		update_width();

		return width;

	}

	function set_height(v:Float):Float {
		
		height = v;

		update_height();

		return height;

	}


}

typedef NineSliceOptions = {

	>GeometryOptions,

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
