package clay.render;


import clay.resources.Texture;

import clay.graphics.Mesh;
import clay.graphics.Sprite;
import clay.graphics.Text;
import clay.graphics.shapes.Line;
import clay.graphics.shapes.PolyLine;
import clay.graphics.shapes.Quad;
import clay.graphics.shapes.QuadOutline;
import clay.graphics.shapes.Circle;
import clay.graphics.shapes.CircleOutline;
import clay.graphics.shapes.PolygonOutline;
import clay.graphics.shapes.StrokeAlign;

import clay.resources.FontResource;
import clay.render.Layer;
import clay.render.Vertex;
import clay.math.Vector;
import clay.math.Matrix;
import clay.utils.Mathf;
import clay.utils.ArrayTools;
import clay.utils.Log.*;
import clay.render.Color;


class Draw {


	var geometry:Array<Mesh>;


	@:allow(clay.system.App)
	inline function new() {

		geometry = [];
		
	}

	public function line(options:DrawLineOptions):Line {

		var strength = def(options.strength, 4);
		var color0 = def(options.color0, new Color());
		var color1 = def(options.color1, color0);

		var immediate = def(options.immediate, true);
		var layer = def(options.layer, null);
		var noLayer = def(options.noLayer, false);
		
		var geom = new Line(options.p0.x, options.p0.y, options.p1.x, options.p1.y);
		geom.color0 = color0;
		geom.color1 = color1;
		geom.strength = strength;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function quad(options:DrawQuadOptions):Quad {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var w = def(options.w, 32);
		var h = def(options.h, 32);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var immediate = def(options.immediate, true);
		var layer = def(options.layer, null);
		var noLayer = def(options.noLayer, false);

		var geom = new Quad(w, h);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.transform.rotation = angle;
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function quadOutline(options:DrawQuadOutlineOptions):QuadOutline {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var w = def(options.w, 32);
		var h = def(options.h, 32);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var immediate = def(options.immediate, true);
		var layer = def(options.layer, null);
		var noLayer = def(options.noLayer, false);

		var geom = new QuadOutline(w, h, options.weight);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.transform.rotation = angle;
		geom.color = color;

		if(options.align != null) {
			geom.align = options.align;
		}

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function circle(options:DrawCircleOptions):Circle {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var r = def(options.r, 32);
		var color = def(options.color, new Color());
		var layer = def(options.layer, null);
		var immediate = def(options.immediate, true);
		var noLayer = def(options.noLayer, false);

		var geom = new Circle(r, options.segments);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;
	}
	
	public function circleOutline(options:DrawCircleOutlineOptions):CircleOutline {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var r = def(options.r, 32);
		var color = def(options.color, new Color());
		var layer = def(options.layer, null);
		var immediate = def(options.immediate, true);
		var noLayer = def(options.noLayer, false);

		var geom = new CircleOutline(r, options.weight, options.segments);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.color = color;

		if(options.align != null) {
			geom.align = options.align;
		}

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;
	}

	public function polygon(options:DrawMeshOptions):Mesh {

		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var layer = def(options.layer, null);
		var immediate = def(options.immediate, true);
		var noLayer = def(options.noLayer, false);

		var iterator = options.vertices.iterator();

		if (!iterator.hasNext()) {
			return null;
		}

		var v0 = iterator.next();

		if (!iterator.hasNext()) {
			return null;
		}

		var v1 = iterator.next();

		var indices = options.indices;
		var vertices = [];

		var i = 0;
		while (iterator.hasNext()) {
			var v2 = iterator.next();

			vertices.push(new Vertex(v0.clone()));
			vertices.push(new Vertex(v1.clone()));
			vertices.push(new Vertex(v2.clone()));

			v1 = v2;
			i++;
		}

		if(indices == null) {
			indices = [];
			for (i in 0...options.vertices.length) {
				indices[i * 3 + 0] = i * 3 + 0;
				indices[i * 3 + 1] = i * 3 + 1;
				indices[i * 3 + 2] = i * 3 + 2;
			}
		}

		var geom = new Mesh(vertices, indices);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.transform.rotation = angle;
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function polygonOutline(options:DrawPolyLineOptions):PolygonOutline {

		var color = def(options.color, new Color());
		var layer = def(options.layer, null);
		var immediate = def(options.immediate, true);
		var noLayer = def(options.noLayer, false);

		var geom = new PolygonOutline(options.points, options.weight);
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function polyline(options:DrawPolyLineOptions):PolyLine {

		var color = def(options.color, new Color());
		var layer = def(options.layer, null);
		var immediate = def(options.immediate, true);
		var noLayer = def(options.noLayer, false);

		var geom = new PolyLine(options.points, options.weight);
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function sprite(options:DrawSpriteOptions):Sprite {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var w = def(options.w, 32);
		var h = def(options.h, 32);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var immediate = def(options.immediate, true);
		var layer = def(options.layer, null);
		var noLayer = def(options.noLayer, false);

		var geom = new Sprite(options.texture);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.transform.rotation = angle;
		geom.color = color;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}

		return geom;

	}

	public function text(options:DrawTextOptions):Text {
		
		var x = def(options.x, 0);
		var y = def(options.y, 0);
		var ox = def(options.ox, 0);
		var oy = def(options.oy, 0);
		var size = def(options.size, 16);
		var angle = def(options.angle, 0);
		var color = def(options.color, new Color());

		var immediate = def(options.immediate, true);
		var layer = def(options.layer, null);
		var noLayer = def(options.noLayer, false);

		var geom = new Text(options.font);
		geom.transform.pos.set(x,y);
		geom.transform.origin.set(ox,oy);
		geom.transform.rotation = angle;
		geom.color = color;
		geom.text = options.text;

		if(options.depth != null) {
			geom.depth = options.depth;
		}

		if(options.align != null) {
			geom.align = options.align;
		}

		if(options.alignVertical != null) {
			geom.alignVertical = options.alignVertical;
		}

		// update martix
		geom.update(0);

		if(!noLayer) {
			addToLayer(geom, layer, options.depth);
			if(immediate) {
				geometry.push(geom);
			}
		}
		
		return geom;

	}

	@:allow(clay.system.App)
	function update() {

		if(geometry.length > 0) {
			for (g in geometry) {
				g.drop();
			}
			ArrayTools.clear(geometry);
		}
		
	}
	
	inline function addToLayer(geom:Mesh, layer:Layer, ?depth:Null<Float>) {

		if(geom.layer == null) {
			if(layer == null) {
				layer = Clay.renderer.layer;
			}
			layer._addUnsafe(geom, depth != null);
		}

	}


}


typedef DrawGeometryOptions = {

	@:optional var layer:Layer;
	@:optional var immediate:Bool;
	@:optional var depth:Float;
	@:optional var noLayer:Bool;

}

typedef DrawLineOptions = {

	> DrawGeometryOptions,

	var p0:Vector;
	var p1:Vector;

	@:optional var color0:Color;
	@:optional var color1:Color;

	@:optional var strength:Float;

}

typedef DrawCircleOptions = {

	> DrawGeometryOptions,

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var ox:Float;
	@:optional var oy:Float;

	@:optional var r:Float;

	@:optional var segments:Int;

	@:optional var color:Color;

}

typedef DrawCircleOutlineOptions = {

	> DrawCircleOptions,

	@:optional var weight:Float;
	@:optional var align:StrokeAlign;

}

typedef DrawQuadOptions = {

	> DrawGeometryOptions,

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var ox:Float;
	@:optional var oy:Float;

	@:optional var w:Float;
	@:optional var h:Float;
	
	@:optional var angle:Float;

	@:optional var color:Color;

}

typedef DrawQuadOutlineOptions = {

	> DrawQuadOptions,

	@:optional var weight:Float;
	@:optional var align:StrokeAlign;

}

typedef DrawSpriteOptions = {

	> DrawQuadOptions,

	var texture:Texture;

	@:optional var color:Color;

}

typedef DrawMeshOptions = {

	> DrawGeometryOptions,

	var vertices:Array<Vector>;
	@:optional var indices:Array<Int>;

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var ox:Float;
	@:optional var oy:Float;

	@:optional var angle:Float;

	@:optional var color:Color;

}

typedef DrawPolyLineOptions = {

	> DrawGeometryOptions,

	var points:Array<Vector>;

	@:optional var color:Color;
	@:optional var weight:Float;

}

typedef DrawTextOptions = {

	> DrawGeometryOptions,

	var font:FontResource;
	var text:String;

	@:optional var size:Int;

	@:optional var x:Float;
	@:optional var y:Float;

	@:optional var ox:Float;
	@:optional var oy:Float;

	@:optional var angle:Float;

	@:optional var color:Color;

	@:optional var align:TextAlign;
	@:optional var alignVertical:TextAlign;

}

