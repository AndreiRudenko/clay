package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.graphics.Mesh;
import clay.utils.Log.*;


class Circle extends Mesh {


	public var radius(get, set):Float;
	public var segments(get, set):Int;
	public var autoSegments(get, set):Bool;

	var _radius:Float;
	var _segments:Int;
	var _autoSegments:Bool;


	public function new(radius:Float, ?segments:Int) {

		super();

		_radius = radius;
		_autoSegments = false;

		if(segments == null) {
			_segments = segmentsForSmoothCircle(_radius);
		} else {
			_segments = segments;
		}

		setCircleVertices(_radius, _segments);

	}

	function setCircleVertices(r:Float, segments:Int) {

		vertices = [];
		indices = [];

		var theta = 2 * Math.PI / segments;
		
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x:Float = 1;
		var y:Float = 0;
		var t:Float = 0;

		for (i in 0...segments) {

			add(new Vertex(new Vector(x*r, y*r), color, new Vector((x+1)*0.5, (y+1)*0.5)));

			t = x;
			x = c * x - s * y;
			y = s * t + c * y;

			indices.push(i);
			indices.push((i+1) % segments);
			indices.push(segments);

		}

		add(new Vertex(new Vector(), color, new Vector(0.5,0.5))); 
			
	}

	function updateCircleVertices(r:Float) {

		var theta = 2 * Math.PI / segments;
		
		var c = Math.cos(theta);
		var s = Math.sin(theta);

		var x:Float = r;
		var y:Float = 0;
		var t:Float = 0;

		for (i in 0...segments) {

			vertices[i].pos.set(x, y);
			
			t = x;
			x = c * x - s * y;
			y = s * t + c * y;

		}
			
	}

	inline function get_autoSegments():Bool {

		return _autoSegments;

	}

	function set_autoSegments(v:Bool):Bool {

		_autoSegments = v;

		if(v) {
			_segments = segmentsForSmoothCircle(_radius);
			setCircleVertices(_radius, _segments);
		}

		return v;

	}

	inline function segmentsForSmoothCircle(radius:Float, smooth:Float = 5):Int {

		return Std.int(smooth * Math.sqrt(radius));

	}

	inline function get_radius():Float {

		return _radius;

	}

	function set_radius(v:Float):Float {

		_radius = v;

		if(_autoSegments) {
			_segments = segmentsForSmoothCircle(_radius);
			setCircleVertices(_radius, _segments);
		} else {
			updateCircleVertices(_radius);
		}

		return v;

	}

	inline function get_segments():Int {

		return _segments;

	}

	function set_segments(v:Int):Int {

		if(!_autoSegments) {
			_segments = v;
			setCircleVertices(_radius, _segments);
		}

		return _segments;

	}


}
