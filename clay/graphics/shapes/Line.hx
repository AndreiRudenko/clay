package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.render.Camera;
import clay.graphics.Mesh;
import clay.utils.Log.*;


class Line extends Mesh {


	public var p0    	(get, set):VectorCallback;
	public var p1    	(get, set):VectorCallback;

	public var color0	(default, set):Color;
	public var color1	(default, set):Color;

	public var strength (get, set):Float;

	var _strength:Float;
	var _tmp:Vector;

	var _p0:VectorCallback;
	var _p1:VectorCallback;


	public function new(p0x:Float = 0, p0y:Float = 0, p1x:Float = 0, p1y:Float = 0) {

		_p0 = new VectorCallback(p0x, p0y);
		_p1 = new VectorCallback(p1x, p1y);
		_tmp = new Vector();

		_p0.listen(update_line_geom);
		_p1.listen(update_line_geom);

		var vertices = [
			new Vertex(new Vector(), new Vector(0, 0)),
			new Vertex(new Vector(), new Vector(1, 0)),
			new Vertex(new Vector(), new Vector(1, 1)),
			new Vertex(new Vector(), new Vector(0, 1))
		];
		
		var indices = [0, 1, 2, 0, 2, 3];

		super(vertices, indices, null);

		color0 = new Color();
		color1 = new Color();

		strength = 1;

	}

	function update_line_geom(v:Float) {

		if (p0.y == p1.y) {
			_tmp.set(0, -1);
		} else {
			_tmp.set(1, -(p1.x - p0.x) / (p1.y - p0.y));
		}
		_tmp.length = _strength;
		_tmp.multiply_scalar(0.5);

		vertices[0].pos.set(p0.x + _tmp.x, p0.y + _tmp.y);
		vertices[1].pos.set(p1.x + _tmp.x, p1.y + _tmp.y);
		vertices[2].pos.set(p1.x - _tmp.x, p1.y - _tmp.y);
		vertices[3].pos.set(p0.x - _tmp.x, p0.y - _tmp.y);

	}

	inline function get_p0():VectorCallback {

		return _p0;

	}

	function set_p0(v:VectorCallback):VectorCallback {

		_p0.listen(null);

		_p0 = v;

		_p0.listen(update_line_geom);
		update_line_geom(0);

		return _p0;

	}

	inline function get_p1():VectorCallback {

		return _p1;

	}

	function set_p1(v:VectorCallback):VectorCallback {

		_p1.listen(null);

		_p1 = v;

		_p1.listen(update_line_geom);
		update_line_geom(0);

		return _p1;

	}

	inline function get_strength():Float {

		return _strength;

	}

	function set_strength(v:Float):Float {

		_strength = v;

		update_line_geom(0);

		return _strength;

	}

	function set_color0(_c:Color):Color {

		color0 = _c;

		vertices[0].color = color0;
		vertices[3].color = color0;

		return color0;

	}

	function set_color1(_c:Color):Color {

		color1 = _c;

		vertices[1].color = color1;
		vertices[2].color = color1;

		return color1;

	}


}
