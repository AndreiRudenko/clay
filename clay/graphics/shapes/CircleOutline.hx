package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.graphics.Mesh;
import clay.utils.Log.*;

class CircleOutline extends Circle {


	public var weight(get, set):Float;
	public var align(get, set):StrokeAlign;

	var _weight:Float;
	var _align:StrokeAlign;


	public function new(radius:Float, weight:Float = 4, ?segments:Int) {

		_weight = weight;
		_align = StrokeAlign.CENTER;

		super(radius, segments);

	}
	
	// https://www.gamedev.net/forums/topic/673527-draw-2d-empty-and-filled-circle/?page=2
	override function setCircleVertices(r:Float, segments:Int) {

	    vertices = [];
		indices = [];

		var theta = 2 * Math.PI / segments;

		var r1:Float = r;
		var r2:Float = r;

		switch (_align) {
			case StrokeAlign.CENTER:
				r1 += weight * 0.5;
				r2 -= weight * 0.5;
			case StrokeAlign.INSIDE:
				r2 -= weight;
			case StrokeAlign.OUTSIDE:
				r1 += weight;
		}

		var a:Float;
		var x:Float;
		var y:Float;

		var len = segments+1; // +1 for texcoords
		var totalVerts = len * 2;

		for (i in 0...len) {

        	a = i * theta;
        	x = Math.sin(a);
        	y = Math.cos(a);

			add(new Vertex(new Vector(x*r1, y*r1), color, new Vector(i/(len),0)));
			add(new Vertex(new Vector(x*r2, y*r2), color, new Vector(i/(len),1)));

			indices.push(i*2);
			indices.push(i*2+1);
			indices.push((i*2+2) % totalVerts);

			indices.push((i*2+2) % totalVerts);
			indices.push((i*2+3) % totalVerts);
			indices.push(i*2+1);

		}

	}

	override function updateCircleVertices(r:Float) {
	    
		var theta = 2 * Math.PI / segments;

		var r1:Float = r;
		var r2:Float = r;

		switch (_align) {
			case StrokeAlign.CENTER:
				r1 += weight * 0.5;
				r2 -= weight * 0.5;
			case StrokeAlign.INSIDE:
				r2 -= weight;
			case StrokeAlign.OUTSIDE:
				r1 += weight;
		}

		var a:Float;
		var x:Float;
		var y:Float;

		for (i in 0...segments+1) {

        	a = i * theta;
        	x = Math.sin(a);
        	y = Math.cos(a);

			vertices[i*2].pos.set(x*r1, y*r1);
			vertices[i*2+1].pos.set(x*r2, y*r2);

		}

	}

	inline function get_align():StrokeAlign {

		return _align;

	}

	function set_align(v:StrokeAlign):StrokeAlign {

		_align = v;

		updateCircleVertices(_radius);

		return v;

	}

	inline function get_weight():Float {

		return _weight;

	}

	function set_weight(v:Float):Float {

		_weight = v;

		updateCircleVertices(_radius);

		return v;

	}


}
