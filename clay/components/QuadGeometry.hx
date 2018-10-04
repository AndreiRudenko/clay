package clay.components;


import kha.Kravur.AlignedQuad;

import clay.math.VectorCallback;
import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.data.Color;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.components.Texture;
import clay.components.Geometry;
import clay.utils.Log.*;


class QuadGeometry extends Geometry {


	public var size(default, null):VectorCallback;
	public var flipx(default, set):Bool = false;
	public var flipy(default, set):Bool = false;

	var _setup:Bool = true;


	public function new(_options:QuadGeometryOptions) {

		size = new VectorCallback(32,32);
		if(_options.size != null) {
			size.copy_from_vec(_options.size);
		}
		size.listen(size_changed);

		var verts:Array<Vertex> = [];
		var _w:Float = size.x;
		var _h:Float = size.y;

		verts.push(new Vertex(new Vector(0, 0), null, new Vector(0,0)));
		verts.push(new Vertex(new Vector(_w, 0), null, new Vector(1,0)));
		verts.push(new Vertex(new Vector(_w, _h), null, new Vector(1,1)));
		verts.push(new Vertex( new Vector(0, _h), null, new Vector(0,1)));

		_options.vertices = verts;

		super(_options);

		flipx = def(_options.flipx, false);
		flipy = def(_options.flipy, false);

		_setup = false;

		geometry_type = GeometryType.quad;

		update_tcoord();

	}

	public function set_tcoord(_r:Rectangle) {

		vertices[0].tcoord.set(_r.x, _r.y);
		vertices[1].tcoord.set(_r.x+_r.w, _r.y);
		vertices[2].tcoord.set(_r.x+_r.w, _r.y+_r.h);
		vertices[3].tcoord.set(_r.x, _r.y+_r.h);

	}
	
	function set_flipx(v:Bool):Bool {

		flipx = v;

		update_tcoord();

		return flipx;

	}

	function set_flipy(v:Bool):Bool {

		flipy = v;

		update_tcoord();

		return flipy;

	}

	function size_changed(v:Float) {
		
		var _w:Float = size.x;
		var _h:Float = size.y;

		vertices[0].pos.set(0, 0);
		vertices[1].pos.set(_w, 0);
		vertices[2].pos.set(_w, _h);
		vertices[3].pos.set(0, _h);

	}

	function update_tcoord() {

		if(_setup) {
			return;
		}
		
		var tl:Vector = vertices[0].tcoord;
		var tr:Vector = vertices[1].tcoord;
		var br:Vector = vertices[2].tcoord;
		var bl:Vector = vertices[3].tcoord;

		if(flipx) {
			var tmp:Vector = tl;
			tl = tr;
			tr = tmp;
			tmp = bl;
			bl = br;
			br = tmp;
		}

		if(flipy) {
			var tmp:Vector = tl;
			tl = bl;
			bl = tmp;
			tmp = tr;
			tr = br;
			br = tmp;
		}

		vertices[0].tcoord = tl;
		vertices[1].tcoord = tr;
		vertices[2].tcoord = br;
		vertices[3].tcoord = bl;

	}

	override function destroy() {

	}

}

typedef QuadGeometryOptions = {

	>GeometryOptions,

	@:optional var size:Vector;
	@:optional var flipx:Bool;
	@:optional var flipy:Bool;

}
