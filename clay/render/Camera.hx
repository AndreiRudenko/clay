package clay.render;


import kha.math.FastMatrix3;
import kha.graphics4.Graphics;
import kha.graphics4.DepthStencilFormat;

import clay.math.Matrix;
import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Rectangle;
import clay.utils.Mathf;
import clay.ds.BitVector;
import clay.events.Signal;
import clay.math.Transform;
import clay.render.CameraManager;
import clay.render.Layer;
import clay.resources.Texture;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


@:allow(clay.render.Renderer)
class Camera {


	public var name (default, null):String;
	public var active (get, set):Bool;
	public var viewport:Rectangle;
	public var roundPixels:Bool;

	public var bounds:Rectangle;
	public var priority(default, null):Int;

	public var onpreRender  (default, null):Signal<(c:Camera)->Void>;
	public var onpostRender	(default, null):Signal<(c:Camera)->Void>;

	@:noCompletion public var transform:Transform;
	@:noCompletion public var projectionMatrix:Matrix;

	public var zoom(default, set):Float;
	public var pos(default, null):VectorCallback;
	public var rotation(get, set):Float;
	public var size(default, null):VectorCallback;
	public var anchor(default, null):VectorCallback;
	public var sizeMode (default, set):SizeMode;
	
	@:noCompletion public var _sizeFactor:Vector;

	var _active:Bool = false;
	var _visibleLayersMask:BitVector;
	var _manager:CameraManager;

	// var _viewMatrix:Matrix;
	var _viewMatrixInverted:Matrix;
	

	function new(manager:CameraManager, name:String, viewport:Rectangle, priority:Int) {

		this.name = name;
		this.priority = priority;
		roundPixels = false;
		_manager = manager;

		pos = new VectorCallback();
		anchor = new VectorCallback(0.5,0.5);
		size = new VectorCallback();

		pos.listen(updatePos);
		anchor.listen(updatePos);
		size.listen(set_size);

		_sizeFactor = new Vector(1,1);

		this.viewport = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);

		if(viewport != null) {
			this.viewport.copyFrom(viewport);
		}

		// _viewMatrix = new Matrix();
		_viewMatrixInverted = new Matrix();
		projectionMatrix = new Matrix();

		_visibleLayersMask = new BitVector(Clay.renderer.layers.capacity);
		_visibleLayersMask.enableAll();

		transform = new Transform();

		zoom = 1;

		onpreRender = new Signal();
		onpostRender = new Signal();

		sizeMode = SizeMode.fit;

		updatePos(0);

	}

	public function hideLayers(?layers:Array<String>):Camera {

		if(layers != null) {
			var l:Layer;
			for (n in layers) {
				l = Clay.renderer.layers.get(n);
				if(l != null) {
					_visibleLayersMask.disable(l.id);
				} else {
					log('can`t hide layer `${n}` for camera `${name}`');
				}
			}
		} else {
			_visibleLayersMask.disableAll();
		}

		return this;

	}

	public function showLayers(?layers:Array<String>):Camera {

		if(layers != null) {			
			var l:Layer;
			for (n in layers) {
				l = Clay.renderer.layers.get(n);
				if(l != null) {
					_visibleLayersMask.enable(l.id);
				} else {
					log('can`t show layer `${n}` for camera `${name}`');
				}
			}
		} else {
			_visibleLayersMask.enableAll();
		}
		
		return this;

	}

	public function screenToWorld(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		into.copyFrom(v);

		transform.update();

		into.transform(transform.world.matrix);

		return into;
		
	}

	public function worldToScreen(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		into.copyFrom(v);

		transform.update();

		_viewMatrixInverted.copy(transform.world.matrix);
		_viewMatrixInverted.invert();

		into.transform(_viewMatrixInverted);

		return into;
		
	}

	function updatePos(_:Float) {

		var corx = 0.0;
		var cory = 0.0;

		var vw = viewport.w;
		var vh = viewport.h;
		
		var ox = vw * anchor.x;
		var oy = vh * anchor.y;

		if(size.x > 0 && size.y > 0) {
			vw = size.x;
			vh = size.y;
			corx = vw * anchor.x - ox;
			cory = vh * anchor.y - oy;
		}

		if(bounds != null) {
			pos.ignoreListeners = true;

			if(pos.x < bounds.x) {
				pos.x = bounds.x;
			}

			if(pos.y < bounds.y) {
				pos.y = bounds.y;
			}

			if(pos.x + vw > bounds.x + bounds.w) {
				pos.x = bounds.x + bounds.w - vw;
			}

			if(pos.y + vh > bounds.y + bounds.h) {
				pos.y = bounds.y + bounds.h - vh;
			}

			pos.ignoreListeners = false;
		}

		var px = pos.x + ox + corx;
		var py = pos.y + oy + cory;

		transform.pos.set(px, py);
		transform.origin.set(ox, oy);

	}

	function destroy() {

		name = null;
		viewport = null;
		onpreRender = null;
		onpostRender = null;
		transform = null;
		// _viewMatrix = null;
		_viewMatrixInverted = null;
		projectionMatrix = null;
		_visibleLayersMask = null;
		_manager = null;

	}

	inline function updateMatrices(g:Graphics) {

		_viewMatrixInverted.copy(transform.world.matrix);
		_viewMatrixInverted.invert();

		projectionMatrix.identity();

		if (kha.Image.renderTargetsInvertedY()) {
			projectionMatrix.orto(0, viewport.w, 0, viewport.h);
		} else {
			projectionMatrix.orto(0, viewport.w, viewport.h, 0);
		}

		projectionMatrix.append(_viewMatrixInverted);

	}

	function preRender() {

		onpreRender.emit(this);

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

		transform.update();
		updateMatrices(g);

		g.viewport(Std.int(viewport.x), Std.int(viewport.y), Std.int(viewport.w), Std.int(viewport.h));

	}

	function postRender() {

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

		// g.disableScissor();
		
		onpostRender.emit(this);
		
	}
	
	function set_sizeMode(mode:SizeMode):SizeMode {

		sizeMode = mode;
		set_size(0);

		return mode;

	}

	function set_size(v:Float) {

		if(size.x <= 0 || size.y <= 0) {
			return;
		}

		var rx = viewport.w / size.x;
		var ry = viewport.h / size.y;
		var shortest = Math.max(rx, ry);
		var longest = Math.min(rx, ry);

		switch(sizeMode) {
			case SizeMode.fit:{
				rx = ry = longest;
			}
			case SizeMode.cover: {
				rx = ry = shortest;
			}
			case SizeMode.contain: {
				//use actual size
			}
		}

		_sizeFactor.x = rx;
		_sizeFactor.y = ry;

		zoom = zoom;
		updatePos(0);

	}

	inline function get_pos() return transform.pos;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;

	function set_zoom(v:Float):Float {

		if(v < 0.01) {
			v = 0.01;
		}

		zoom = v;

		var sx = 1 / (_sizeFactor.x * zoom);
		var sy = 1 / (_sizeFactor.y * zoom);

		transform.scale.set(sx, sy);

		return v;

	}

	inline function get_active():Bool {

		return _active;

	}
	
	inline function set_active(value:Bool):Bool {

		_active = value;

		if(_manager != null) {
			if(_active){
				_manager.enable(this);
			} else {
				_manager.disable(this);
			}
		}
		
		return _active;

	}


}


@:enum abstract SizeMode(Int) from Int to Int {

		/** fit the size into the camera viewport (possible letter/pillar box) */
	var fit = 0;
		/** cover the viewport with the size (possible cropping) */
	var cover = 1;
		/** contain the size (stretch to fit the viewport)*/
	var contain = 2;

}