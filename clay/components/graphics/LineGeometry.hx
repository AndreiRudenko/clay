package clay.components.graphics;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.data.Color;
import clay.render.Vertex;
import clay.render.GeometryType;
import clay.render.RenderPath;
import clay.render.GeometryType;
import clay.render.Camera;
import clay.components.graphics.Geometry;
import clay.utils.Log.*;

@:keep
class LineGeometry extends Geometry {


	public var p0    	(default, set):VectorCallback;
	public var p1    	(default, set):VectorCallback;

	public var color0	(default, set):Color;
	public var color1	(default, set):Color;

	public var strength (get, set):Float;
	var _strength:Float;

	var _tmp:Vector;


	public function new(options:LineGeometryOptions) {

		super(options);

		sort_key.geomtype = GeometryType.quad;

		p0 = new VectorCallback();
		p1 = new VectorCallback();
		_tmp = new Vector();

		if(options.p0 != null) {
			p0.copy_from(options.p0);
		}

		if(options.p1 != null) {
			p1.copy_from(options.p1);
		}

		p0.listen(update_line_geom);
		p1.listen(update_line_geom);

		add(new Vertex(new Vector(), null, new Vector(0,0)));
		add(new Vertex(new Vector(), null, new Vector(1,0)));
		add(new Vertex(new Vector(), null, new Vector(1,1)));
		add(new Vertex(new Vector(), null, new Vector(0,1)));

		color0 = def(options.color0, new Color());
		color1 = def(options.color1, new Color());

		strength = def(options.strength, 1);


	}

	override function render_geometry(r:RenderPath, c:Camera) {

		r.set_object_renderer(r.quad_renderer);
		r.quad_renderer.render(this);

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

	function set_p0(v:VectorCallback):VectorCallback {

		p0 = v;

		if (vertices.length == 0) {
			return p0;
		}

		update_line_geom(0);

		return p0;

	}

	function set_p1(v:VectorCallback):VectorCallback {

		p1 = v;

		if (vertices.length == 0) {
			return p1;
		}

		update_line_geom(0);

		return p1;

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

		if(vertices.length == 0) {
			return color0;
		}

		vertices[0].color = color0;
		vertices[3].color = color0;

		return color0;

	}

	function set_color1(_c:Color):Color {

		color1 = _c;

		if(vertices.length == 0) {
			return color1;
		}

		vertices[1].color = color1;
		vertices[2].color = color1;

		return color1;

	}


}

typedef LineGeometryOptions = {

	>GeometryOptions,

	@:optional var p0:Vector;
	@:optional var p1:Vector;
	@:optional var color0:Color;
	@:optional var color1:Color;
	@:optional var strength:Float;

}
