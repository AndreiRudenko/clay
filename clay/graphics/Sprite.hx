package clay.graphics;


import clay.math.RectangleCallback;
import clay.render.RenderPath;
import clay.render.Camera;
import clay.graphics.shapes.Quad;
import clay.resources.Texture;
import clay.utils.Log.*;

// @:keep
class Sprite extends Quad {


	public var centered         (default, set):Bool;
	public var uv               (default, null):RectangleCallback;
	public var flipx            (get, set):Bool;
	public var flipy            (get, set):Bool;

	var _flipx:Bool;
	var _flipy:Bool;


	public function new(?texture:Texture) {
		
		super();

		this.texture = texture;

		uv = new RectangleCallback();
		uv.listen(uv_changed);

		update_tcoord();
		set_uv(0, 0, 1, 1);

		_flipx = false;
		_flipy = false;

		centered = true;

	}
	
	public function set_uv(_x:Float, _y:Float, _w:Float, _h:Float) {

		var lstate = uv.ignore_listeners;
		uv.ignore_listeners = true;
		uv.set(_x, _y, _w, _h);
		uv.ignore_listeners = lstate;

		update_tcoord();

	}

	override function render_geometry(r:RenderPath, c:Camera) {

		r.set_object_renderer(r.quad_renderer);
		r.quad_renderer.render(this);

	}

	override function size_changed(v:Float) {

		if(centered) {
			var hw = size.x * 0.5;
			var hh = size.y * 0.5;
			vertices[0].pos.set(-hw, -hh);
			vertices[1].pos.set( hw, -hh);
			vertices[2].pos.set( hw,  hh);
			vertices[3].pos.set(-hw,  hh);
		} else {
			super.size_changed(v);
		}

	}

	function uv_changed(v:Float) {

		update_tcoord();

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

	function set_centered(v:Bool):Bool {

		centered = v;

		size_changed(0);

		return centered;

	}
	

}
