package clay.graphics.shapes;


import clay.math.VectorCallback;
import clay.math.Vector;
import clay.render.Vertex;
import clay.render.Camera;
import clay.graphics.Mesh;


class QuadOutline extends Mesh {


	public var size(default, null):VectorCallback;
	public var weight(get, set):Float;
	public var align(get, set):StrokeAlign;

	var _weight:Float;
	var _align:StrokeAlign;


	public function new(w:Float = 32, h:Float = 32, weight:Float = 4) {

		_weight = weight;
		_align = StrokeAlign.CENTER;

		size = new VectorCallback(w, h);
		size.listen(sizeChanged);

		var vertices = [];
		var indices = [];
		for (i in 0...5) { // +1 for texcoords
			vertices.push(new Vertex(null, null, new Vector(i/4,0)));
			vertices.push(new Vertex(null, null, new Vector(i/4,1)));
		}

		for (i in 0...4) {
			indices.push(i*2);
			indices.push(i*2+1);
			indices.push((i*2+2));

			indices.push((i*2+2));
			indices.push((i*2+3));
			indices.push(i*2+1);
		}

		super(vertices, indices, null);

		sizeChanged(0);

	}

	function sizeChanged(v:Float) {
		
		var sw:Float = 0;
		var sw2:Float = 0;
		var w:Float = size.x;
		var h:Float = size.y;

		switch (_align) {
			case StrokeAlign.CENTER:
				sw -= _weight * 0.5;
				sw2 += _weight * 0.5;
			case StrokeAlign.INSIDE:
				sw2 += _weight;
			case StrokeAlign.OUTSIDE:
				sw -= _weight;
		}

		vertices[0].pos.set(sw,  sw);
		vertices[1].pos.set(sw2, sw2);

		vertices[2].pos.set(w-sw, sw);
		vertices[3].pos.set(w-sw2, sw2);

		vertices[4].pos.set(w-sw, h-sw);
		vertices[5].pos.set(w-sw2, h-sw2);

		vertices[6].pos.set(sw,   h-sw);
		vertices[7].pos.set(sw2,  h-sw2);

		vertices[8].pos.set(sw,  sw);
		vertices[9].pos.set(sw2, sw2);

	}

	inline function get_align():StrokeAlign {

		return _align;

	}

	function set_align(v:StrokeAlign):StrokeAlign {

		_align = v;

		sizeChanged(0);

		return v;

	}

	inline function get_weight():Float {

		return _weight;

	}

	function set_weight(v:Float):Float {

		_weight = v;

		sizeChanged(0);

		return v;

	}


}
