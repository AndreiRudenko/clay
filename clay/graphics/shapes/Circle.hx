package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.graphics.Mesh;
import clay.utils.Log.*;


class Circle extends Mesh {


	public var radius (get, set):Float;
	public var segments (get, set):Int;
	public var auto_segments (get, set):Bool;

	var _radius:Float;
	var _segments:Int;
	var _auto_segments:Bool;


	public function new(radius:Float, ?segments:Int) {

		super();

		_radius = radius;
		_auto_segments = false;

		if(segments == null) {
			_segments = segments_for_smooth_circle(_radius);
		} else {
			_segments = segments;
		}

		set_circle_vertices(_radius, _segments);

	}

	function set_circle_vertices(r:Float, segments:Int) {

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

	function update_circle_vertices(r:Float) {

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

	inline function get_auto_segments():Bool {

		return _auto_segments;

	}

	function set_auto_segments(v:Bool):Bool {

		_auto_segments = v;

		if(v) {
			_segments = segments_for_smooth_circle(_radius);
			set_circle_vertices(_radius, _segments);
		}

		return v;

	}

	inline function get_radius():Float {

		return _radius;

	}

	function set_radius(v:Float):Float {

		_radius = v;

		if(_auto_segments) {
			_segments = segments_for_smooth_circle(_radius);
			set_circle_vertices(_radius, _segments);
		} else {
			update_circle_vertices(_radius);
		}

		return v;

	}

	inline function get_segments():Int {

		return _segments;

	}

	function set_segments(v:Int):Int {

		if(!_auto_segments) {
			_segments = v;
			set_circle_vertices(_radius, _segments);
		}

		return _segments;

	}

	inline function segments_for_smooth_circle(radius:Float, smooth:Float = 5):Int {

		return Std.int(smooth * Math.sqrt(radius));

	}
	

}
