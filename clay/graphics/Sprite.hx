package clay.graphics;


import clay.math.RectangleCallback;
import clay.render.Camera;
import clay.graphics.shapes.Quad;
import clay.resources.Texture;
import clay.utils.Log.*;

// @:keep
class Sprite extends Quad {


	public var centered(default, set):Bool;
	public var uv(default, null):RectangleCallback;
	public var flipX(get, set):Bool;
	public var flipY(get, set):Bool;

	var _flipX:Bool;
	var _flipY:Bool;


	public function new(?texture:Texture) {
		
		super();

		this.texture = texture;

		uv = new RectangleCallback();
		uv.listen(uvChanged);

		updateTcoord();
		setUV(0, 0, 1, 1);

		_flipX = false;
		_flipY = false;

		centered = true;

	}
	
	public function setUV(_x:Float, _y:Float, _w:Float, _h:Float) {

		var lstate = uv.ignoreListeners;
		uv.ignoreListeners = true;
		uv.set(_x, _y, _w, _h);
		uv.ignoreListeners = lstate;

		updateTcoord();

	}

	override function sizeChanged(v:Float) {

		if(centered) {
			var hw = size.x * 0.5;
			var hh = size.y * 0.5;
			vertices[0].pos.set(-hw, -hh);
			vertices[1].pos.set( hw, -hh);
			vertices[2].pos.set( hw,  hh);
			vertices[3].pos.set(-hw,  hh);
		} else {
			super.sizeChanged(v);
		}

	}

	function uvChanged(v:Float) {

		updateTcoord();

	}

	function updateTcoord() {
		
		var tlX = uv.x;
		var tlY = uv.y;
		var trX = uv.x + uv.w;
		var trY = uv.y;
		var brX = uv.x + uv.w;
		var brY = uv.y + uv.h;
		var blX = uv.x;
		var blY = uv.y + uv.h;

		if(_flipX) {
			var tmpX = tlX;
			var tmpY = tlY;
			tlX = trX;
			tlY = trY;
			trX = tmpX;
			trY = tmpY;
			tmpX = blX;
			tmpY = blY;
			blX = brX;
			blY = brY;
			brX = tmpX;
			brY = tmpY;
		}

		if(_flipY) {
			var tmpX = tlX;
			var tmpY = tlY;
			tlX = blX;
			tlY = blY;
			blX = tmpX;
			blY = tmpY;
			tmpX = trX;
			tmpY = trY;
			trX = brX;
			trY = brY;
			brX = tmpX;
			brY = tmpY;
		}

		vertices[0].tcoord.set(tlX, tlY);
		vertices[1].tcoord.set(trX, trY);
		vertices[2].tcoord.set(brX, brY);
		vertices[3].tcoord.set(blX, blY);

	}

	inline function get_flipX():Bool {

		return _flipX;

	}

	function set_flipX(v:Bool):Bool {

		_flipX = v;

		updateTcoord();

		return _flipX;

	}

	inline function get_flipY():Bool {

		return _flipY;

	}

	function set_flipY(v:Bool):Bool {

		_flipY = v;

		updateTcoord();

		return _flipY;

	}

	function set_centered(v:Bool):Bool {

		centered = v;

		sizeChanged(0);

		return centered;

	}
	

}
