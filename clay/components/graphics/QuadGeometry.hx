package clay.components.graphics;


import kha.Kravur.AlignedQuad;

import clay.math.RectangleCallback;
import clay.math.VectorCallback;
import clay.math.Vector;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.data.Color;
import clay.render.Vertex;
import clay.resources.FontResource;
import clay.resources.Texture;
import clay.components.graphics.Geometry;
import clay.utils.Log.*;

@:keep
class QuadGeometry extends Geometry {


	public var size(default, null):VectorCallback;
	public var uv(default, null):RectangleCallback;
	public var flipx(get, set):Bool;
	public var flipy(get, set):Bool;

	var _flipx:Bool = false;
	var _flipy:Bool = false;


	public function new(_options:QuadGeometryOptions) {

		size = new VectorCallback(32, 32);
		if(_options.size != null) {
			size.copy_from(_options.size);
		}
		size.listen(size_changed);

		uv = new RectangleCallback();
		uv.listen(uv_changed);

		var verts:Array<Vertex> = [];
		var inds:Array<Int> = [0,1,2,0,2,3];
		var _w:Float = size.x;
		var _h:Float = size.y;

		verts.push(new Vertex(new Vector( 0,  0)));
		verts.push(new Vertex(new Vector(_w,  0)));
		verts.push(new Vertex(new Vector(_w, _h)));
		verts.push(new Vertex(new Vector( 0, _h)));

		_options.vertices = verts;
		_options.indices = inds;

		_flipx = def(_options.flipx, false);
		_flipy = def(_options.flipy, false);

		super(_options);

		set_geometry_type(GeometryType.quad);

		update_tcoord();

		if(_options.uv != null) {
			uv.copy_from(_options.uv);
		} else {
			set_uv(0, 0, 1, 1);
		}

	}
	
	public function set_uv(_x:Float, _y:Float, _w:Float, _h:Float) {

		var lstate = uv.ignore_listeners;
		uv.ignore_listeners = true;
		uv.set(_x, _y, _w, _h);
		uv.ignore_listeners = lstate;

		_set_uv(_x, _y, _w, _h);

	}

	inline function _set_uv(_x:Float, _y:Float, _w:Float, _h:Float) {
		
		vertices[0].tcoord.set(_x,    _y);
		vertices[1].tcoord.set(_x+_w, _y);
		vertices[2].tcoord.set(_x+_w, _y+_h);
		vertices[3].tcoord.set(_x,    _y+_h);

	}

	function uv_changed(v:Float) {

		// if(texture == null) {
		// 	log('Calling UV on a geometry with null texture.');
		// 	return;
		// }

        // var tlx = uv.x/texture.width_actual;
        // var tly = uv.y/texture.height_actual;
        // var szx = uv.w/texture.width_actual;
        // var szy = uv.h/texture.height_actual;

        // set_uv_space(tlx, tly, szx, szy);

		_set_uv(uv.x, uv.y, uv.w, uv.h);

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

	inline function get_flipx():Bool {

		return _flipx;

	}

	function set_flipx(v:Bool):Bool {

		_flipx = v;

		update_tcoord();

		return _flipx;

	}

	inline function get_flipy():Bool {

		return _flipy;

	}

	function set_flipy(v:Bool):Bool {

		_flipy = v;

		update_tcoord();

		return _flipy;

	}
	

}

typedef QuadGeometryOptions = {

	>GeometryOptions,

	@:optional var size:Vector;
	@:optional var flipx:Bool;
	@:optional var flipy:Bool;
	@:optional var uv:Rectangle;

}
