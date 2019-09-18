package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Vertex;
import clay.render.Color;
import clay.render.Camera;
import clay.graphics.Mesh;


class PolygonOutline extends Mesh {


	public var weight(get, set):Float;
	public var points(get, set):Array<Vector>;
	public var align(get, set):StrokeAlign;

	var _weight:Float;
	var _points:Array<Vector>;
	var _align:StrokeAlign;

	var _line:Vector;
	var _tangent:Vector;
	var _line1:Vector;


	public function new(points:Array<Vector>, weight:Float = 4) {

		_weight = weight;
		_points = points;
		_align = StrokeAlign.CENTER;

		// tmp values
		_line = new Vector();
		_tangent = new Vector();
		_line1 = new Vector();

		var vertices = [];
		var len = _points.length+1; // +1 for texcoords
		for (i in 0...len) {
			vertices.push(new Vertex());
			vertices.push(new Vertex());
		}

		var totalVerts = len * 2;
		var indices = [];
		for (i in 0...len) {
			indices.push(i*2);
			indices.push(i*2+1);
			indices.push((i*2+2) % totalVerts);

			indices.push((i*2+2) % totalVerts);
			indices.push((i*2+3) % totalVerts);
			indices.push(i*2+1);
		}

		super(vertices, indices, null);

		updatePoints();
		updateTcoords();

	}

	public function updatePoints() {

		if(_points.length < 3) {
			return;
		}

		var l0:Float = 1;
		var l1:Float = 1;

		switch (_align) {
			case StrokeAlign.INSIDE:
				l0 = 2;
				l1 = 0;
			case StrokeAlign.OUTSIDE:
				l0 = 0;
				l1 = 2;
			case _:
		}

		var len = _points.length;

		for (i in 0..._points.length+1) {
	        var p0 = _points[i-1 < 0 ? len-1 : i-1];
	        var p1 = _points[i % len];
	        var p2 = _points[(i+1) % len];

			_line.copyFrom(p1).subtract(p0).normalize();
			_line1.copyFrom(p2).subtract(p1).normalize();
			_tangent.copyFrom(_line1.add(_line)).normalize();

			var tmp = _line.x;
			var normal = _line.set(-_line.y, tmp).normalize();
			tmp = _tangent.x;
			var miter = _tangent.set(-_tangent.y, tmp);
			var length = weight / normal.dot(miter);

			vertices[i*2].pos.set(
				p1.x + miter.x * length * l0,
				p1.y + miter.y * length * l0
			);

			vertices[i*2+1].pos.set(
				p1.x - miter.x * length * l1,
				p1.y - miter.y * length * l1
			);
		}
		
	}

	function updateTcoords() {

		var len = _points.length+1;
		for (i in 0...len) {
			vertices[i*2].tcoord.set(i/len,0);
			vertices[i*2+1].tcoord.set(i/len,1);
		}
		
	}

	inline function get_points():Array<Vector> {

		return _points;

	}

	function set_points(v:Array<Vector>):Array<Vector> {

		_points = v;

		updatePoints();
		updateTcoords();

		return v;

	}

	inline function get_weight():Float {

		return _weight;

	}

	function set_weight(v:Float):Float {

		_weight = v;

		updatePoints();

		return v;

	}


	inline function get_align():StrokeAlign {

		return _align;

	}

	function set_align(v:StrokeAlign):StrokeAlign {

		_align = v;

		updatePoints();

		return v;

	}


}
