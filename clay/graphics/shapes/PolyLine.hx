package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Vertex;
import clay.render.Color;
import clay.render.Camera;
import clay.graphics.Mesh;


class PolyLine extends Mesh {


	public var weight (get, set):Float;
	public var points (get, set):Array<Vector>;

	var _weight:Float;
	var _points:Array<Vector>;

	var _line:Vector;
	var _tangent:Vector;
	var _line1:Vector;


	public function new(points:Array<Vector>, weight:Float = 4) {

		_weight = weight;
		_points = points;

		// tmp values
		_line = new Vector();
		_tangent = new Vector();
		_line1 = new Vector();

		var vertices = [];
		var len = _points.length;
		for (i in 0...len) {
			vertices.push(new Vertex());
			vertices.push(new Vertex());
		}

		var total_verts = len * 2;
		var indices = [];
		for (i in 0...len-1) {
			indices.push(i*2);
			indices.push(i*2+1);
			indices.push((i*2+2) % total_verts);

			indices.push((i*2+2) % total_verts);
			indices.push((i*2+3) % total_verts);
			indices.push(i*2+1);
		}

		super(vertices, indices, null);

		update_points();
		update_tcoords();

	}

	public function update_points() {

		var len = _points.length;

		if(len < 2) {
			return;
		}

		for (i in 0...len) {
	        var p0 = _points[i-1 < 0 ? 0 : i-1];
	        var p1 = _points[i];
	        var p2 = _points[i+1 >= len ? len-1 : i+1];

			if (p0 == p1) {
				_line.copy_from(p2).subtract(p1).normalize();
				_tangent.copy_from(_line);
			} else if (p1 == p2) {
				_line.copy_from(p1).subtract(p0).normalize();
				_tangent.copy_from(_line);
			} else {
				_line.copy_from(p1).subtract(p0).normalize();
				_line1.copy_from(p2).subtract(p1).normalize();
				_tangent.copy_from(_line1.add(_line)).normalize();
			}

			var tmp = _line.x;
			var normal = _line.set(-_line.y, tmp).normalize();
			tmp = _tangent.x;
			var miter = _tangent.set(-_tangent.y, tmp);
			var length = _weight / normal.dot(miter);

			vertices[i*2].pos.set(
				p1.x + miter.x * length,
				p1.y + miter.y * length
			);

			vertices[i*2+1].pos.set(
				p1.x - miter.x * length,
				p1.y - miter.y * length
			);

		}
		
	}

	function update_tcoords() {

		var len = _points.length-1;
		for (i in 0..._points.length) {
			vertices[i*2].tcoord.set(i/len,0);
			vertices[i*2+1].tcoord.set(i/len,1);
		}

	}

	inline function get_points():Array<Vector> {

		return _points;

	}

	function set_points(v:Array<Vector>):Array<Vector> {

		_points = v;

		update_points();
		update_tcoords();

		return v;

	}

	inline function get_weight():Float {

		return _weight;

	}

	function set_weight(v:Float):Float {

		_weight = v;

		update_points();

		return v;

	}


}
