package clay.render;


// import kha.graphics4.Graphics;
import clay.components.graphics.Texture;
import clay.components.graphics.Geometry;
import clay.components.graphics.QuadGeometry;
import clay.components.graphics.Text;
import clay.resources.FontResource;
import clay.render.Layer;
import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Mathf;
import clay.data.Color;
import clay.utils.Log.*;


class Draw {

	// image, text, geom cache
	var geometry:Array<Geometry>;


	@:allow(clay.Engine)
	inline function new() {

		geometry = [];
		
	}

	public function line(options:DrawLineOptions) {

		var p0 = options.p0;
		var p1 = options.p1;
		var color0 = def(options.color0, new Color());
		var color1 = def(options.color1, new Color());
		
	}

	public function rectangle(options:DrawRectangleOptions) {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var w = def(options.w, 32);
		var h = def(options.h, 32);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());
		var immediate = def(options.immediate, true);
		var layer = def(options.layer, 0);

		var rect = new QuadGeometry({
			size: new Vector(w, h),
			color: color,
			layer: layer
		});

		update_matrix(rect.transform_matrix, x, y, 0, 0, angle);
		add_to_layer(rect, Clay.renderer.layers.get(layer), options.order);

		if(immediate) {
			geometry.push(rect);
		}

		return rect;

	}

	public function circle(options:DrawCircleOptions) {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var r = def(options.r, 64);
		var color = def(options.color, new Color());

	}

	public function polygon(options:DrawPolyOptions) {

		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var points = options.points;

	}

	public function image(options:DrawImageOptions) {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var w = def(options.w, 32);
		var h = def(options.h, 32);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());
		var immediate = def(options.immediate, true);
		var layer = def(options.layer, 0);

		var texture = options.texture;

		var rect = new QuadGeometry({
			size: new Vector(w, h),
			color: color,
			layer: layer,
			texture: texture
		});

		update_matrix(rect.transform_matrix, x, y, 0, 0, angle);
		add_to_layer(rect, Clay.renderer.layers.get(layer), options.order);

		if(immediate) {
			geometry.push(rect);
		}

		return rect;

	}

	public function text(options:DrawTextOptions) {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var size = def(options.size, 16);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());
		var immediate = def(options.immediate, true);
		var layer = def(options.layer, 0);
		
		var text = options.text;
		var font = options.font;

		var text = new Text({
			size: size,
			color: color,
			layer: layer,
			font: font,
			text: text,
			align: options.align,
			align_vertical: options.align_vertical
		});

		update_matrix(text.transform_matrix, x, y, 0, 0, angle);
		add_to_layer(text, Clay.renderer.layers.get(layer), options.order);

		if(immediate) {
			geometry.push(text);
		}

		return text;

	}

	@:allow(clay.Engine)
	function update() {

		if(geometry.length > 0) {
			var lr:Layer = null;

			for (g in geometry) {
				lr = Clay.renderer.layers.get(g.layer);
				lr.remove(g);
			}

			geometry.splice(0, geometry.length);
		}
		
	}
	
	inline function add_to_layer(geom:Geometry, layer:Layer, ?order:Null<Int>) {

		if(layer != null) {
			if(order != null) {
				geom.order = order;
				layer.geometry_list.add(geom);
			} else {
				layer.geometry_list.add_first(geom);
			}
		} else {
			log('cant add geometry to layer');
		}

	}

	inline function update_matrix(matrix:Matrix, x:Float, y:Float, ox:Float, oy:Float, angle:Float) {
		
		matrix.identity().translate(x, y).rotate(Mathf.radians(angle)).apply(-ox, -oy);

	}


}


typedef DrawGeometryOptions = {

	@:optional var layer:Int;
	@:optional var immediate:Bool;
	@:optional var order:Int;

}

typedef DrawLineOptions = {

	> DrawGeometryOptions,

	var p0:Vector;
	var p1:Vector;

	@:optional var color0:Color;
	@:optional var color1:Color;

	@:optional var thickness:Float;

}

typedef DrawCircleOptions = {

	> DrawGeometryOptions,

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var r:Float;

	@:optional var color:Color;

}

typedef DrawRectangleOptions = {

	> DrawGeometryOptions,

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var w:Float;
	@:optional var h:Float;
	
	@:optional var angle:Float;

	@:optional var color:Color;

}

typedef DrawImageOptions = {

	> DrawRectangleOptions,

	var texture:Texture;

	@:optional var color:Color;

}

typedef DrawPolyOptions = {

	> DrawGeometryOptions,

	var points:Array<Vector>;

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var angle:Float;

	@:optional var color:Color;

}

typedef DrawTextOptions = {

	> DrawGeometryOptions,

	var font:FontResource;
	var text:String;

	@:optional var size:Int;

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var angle:Float;

	@:optional var color:Color;

	@:optional var align:TextAlign;
	@:optional var align_vertical:TextAlign;

}