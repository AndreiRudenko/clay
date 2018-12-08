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

		update_tcoord();

	}

	function uv_changed(v:Float) {

		update_tcoord();

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
		
		var tl_x = uv.x;
		var tl_y = uv.y;
		var tr_x = uv.x + uv.w;
		var tr_y = uv.y;
		var br_x = uv.x + uv.w;
		var br_y = uv.y + uv.h;
		var bl_x = uv.x;
		var bl_y = uv.y + uv.h;

		if(_flipx) {
			var tmp_x = tl_x;
			var tmp_y = tl_y;
			tl_x = tr_x;
			tl_y = tr_y;
			tr_x = tmp_x;
			tr_y = tmp_y;
			tmp_x = bl_x;
			tmp_y = bl_y;
			bl_x = br_x;
			bl_y = br_y;
			br_x = tmp_x;
			br_y = tmp_y;
		}

		if(_flipy) {
			var tmp_x = tl_x;
			var tmp_y = tl_y;
			tl_x = bl_x;
			tl_y = bl_y;
			bl_x = tmp_x;
			bl_y = tmp_y;
			tmp_x = tr_x;
			tmp_y = tr_y;
			tr_x = br_x;
			tr_y = br_y;
			br_x = tmp_x;
			br_y = tmp_y;
		}

		vertices[0].tcoord.set(tl_x, tl_y);
		vertices[1].tcoord.set(tr_x, tr_y);
		vertices[2].tcoord.set(br_x, br_y);
		vertices[3].tcoord.set(bl_x, bl_y);

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
