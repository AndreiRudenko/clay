package clay.graphics.shapes;

import clay.math.VectorCallback;
import clay.math.Vector;
import clay.utils.Color;
import clay.render.Vertex;
import clay.render.Camera;
import clay.graphics.Mesh;
import clay.utils.Log.*;

class Line extends Mesh {

	public var point0(get, set):VectorCallback;
	public var point1(get, set):VectorCallback;

	public var color0(default, set):Color;
	public var color1(default, set):Color;

	public var strength(get, set):Float;

	var _strength:Float;
	var _tmp:Vector;

	var _point0:VectorCallback;
	var _point1:VectorCallback;

	public function new(point0x:Float = 0, point0y:Float = 0, point1x:Float = 0, point1y:Float = 0) {
		_point0 = new VectorCallback(point0x, point0y);
		_point1 = new VectorCallback(point1x, point1y);
		_tmp = new Vector();

		_point0.listen(updateLineGeomListener);
		_point1.listen(updateLineGeomListener);

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

	function updateLineGeomListener(v:Vector) {
		updateLineGeom();
	}

	inline function updateLineGeom() {
		if (point0.y == point1.y) {
			_tmp.set(0, -1);
		} else {
			_tmp.set(1, -(point1.x - point0.x) / (point1.y - point0.y));
		}
		_tmp.length = _strength;
		_tmp.multiplyScalar(0.5);

		vertices[0].pos.set(point0.x + _tmp.x, point0.y + _tmp.y);
		vertices[1].pos.set(point1.x + _tmp.x, point1.y + _tmp.y);
		vertices[2].pos.set(point1.x - _tmp.x, point1.y - _tmp.y);
		vertices[3].pos.set(point0.x - _tmp.x, point0.y - _tmp.y);
	}

	inline function get_point0():VectorCallback {
		return _point0;
	}

	function set_point0(v:VectorCallback):VectorCallback {
		_point0.listen(null);

		_point0 = v;

		_point0.listen(updateLineGeomListener);
		updateLineGeom();

		return _point0;
	}

	inline function get_point1():VectorCallback {
		return _point1;
	}

	function set_point1(v:VectorCallback):VectorCallback {
		_point1.listen(null);

		_point1 = v;

		_point1.listen(updateLineGeomListener);
		updateLineGeom();

		return _point1;
	}

	inline function get_strength():Float {
		return _strength;
	}

	function set_strength(v:Float):Float {
		_strength = v;

		updateLineGeom();

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
