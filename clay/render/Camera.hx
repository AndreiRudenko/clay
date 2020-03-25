package clay.render;

import kha.math.FastMatrix3;
import kha.graphics4.Graphics;
import kha.graphics4.DepthStencilFormat;

import clay.math.Matrix;
import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Rectangle;
import clay.utils.Mathf;
import clay.events.Signal;
import clay.math.Transform;
import clay.render.CameraManager;
import clay.render.Layer;
import clay.render.RenderContext;
import clay.render.types.TextureFormat;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.utils.Color;

using clay.render.utils.FastMatrix3Extender;

@:allow(clay.render.Renderer)
class Camera {

	public var name(default, null):String;
	public var active(get, set):Bool;
	public var viewport(get, set):Rectangle;
	public var roundPixels:Bool;

	public var bounds:Rectangle;
	public var priority(default, null):Int;

	public var onPreRender(default, null):Signal<(c:Camera)->Void>;
	public var onPostRender(default, null):Signal<(c:Camera)->Void>;
	public var onBufferResize(default, null):Signal<(w:Int, h:Int)->Void>;
	public var onRenderTexture(default, set):(source:Texture, target:Texture)->Void;

	@:noCompletion public var transform:Transform;
	@:noCompletion public var projectionMatrix:Matrix;

	public var zoom(default, set):Float;
	public var pos(default, null):VectorCallback;
	public var rotation(get, set):Float;
	public var size(default, null):VectorCallback;
	public var anchor(default, null):VectorCallback;
	public var sizeMode(default, set):SizeMode;

	public var antialiasing(get, set):Int;
	public var resolution(get, set):Float;
	public var buffer(default, null):Texture;
	public var bgColor:Color;

	public var cullingMask:Int;
	public var autoRender:Bool;

	@:noCompletion public var _sizeFactor:Vector;

	var _redraw:Bool = true;
	var _active:Bool = false;
	var _manager:CameraManager;

	var _viewMatrixInverted:Matrix;

	var _resolution:Float = 1;
	var _antialiasing:Int = 1;
	var _bufferInternal:Texture;
	var _viewport:Rectangle;

	function new(manager:CameraManager, name:String, viewport:Rectangle, priority:Int) {
		this.name = name;
		this.priority = priority;
		autoRender = true;
		roundPixels = false;
		_manager = manager;

		pos = new VectorCallback();
		anchor = new VectorCallback(0.5,0.5);
		size = new VectorCallback();

		pos.listen(updatePosListener);
		anchor.listen(updatePosListener);
		size.listen(updateSizeListener);

		_sizeFactor = new Vector(1,1);

		_viewport = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);

		if(viewport != null) {
			_viewport.copyFrom(viewport);
		}

		_viewMatrixInverted = new Matrix();
		projectionMatrix = new Matrix();

		cullingMask = -1;

		transform = new Transform();

		zoom = 1;

		onPreRender = new Signal();
		onPostRender = new Signal();
		onBufferResize = new Signal();

		sizeMode = SizeMode.FIT;
		bgColor = new Color(0,0,0,0);

		updatePos();
		updateBuffer();
	}

	public function hide(layerId:Int):Camera {
		if(layerIdInBounds(layerId)) {
			var mask = 1 << layerId;
			cullingMask &= ~mask;
		}
		return this;
	}

	public function show(layerId:Int):Camera {
		if(layerIdInBounds(layerId)) {
			var mask = 1 << layerId;
			cullingMask |= mask;
		}
		return this;
	}

	function layerIdInBounds(layerId:Int):Bool {
		if(layerId < 0 || layerId > 31) {
			log('layerId must be betweeen 0...32');
			return false;
		}
		return true;
	}

	public function showAll() {
		cullingMask = -1;
	}

	public function hideAll() {
		cullingMask = 0;
	}

	public function inCullingMask(layerId:Int):Bool {
		var mask = 1 << layerId;
		return cullingMask & mask != 0;
	}

	public inline function canRender():Bool {
		return autoRender || _redraw;
	}

	public function redraw() {
		_redraw = true;
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

	function updateSizeListener(v:Vector) {
		updateSize();
	}
	
	function updatePosListener(v:Vector) {
		updatePos();
	}

	inline function updateSize() {
		if(size.x <= 0 || size.y <= 0) {
			return;
		}

		var rx = viewport.w / size.x;
		var ry = viewport.h / size.y;
		var shortest = Math.max(rx, ry);
		var longest = Math.min(rx, ry);

		switch(sizeMode) {
			case SizeMode.FIT:{
				rx = ry = longest;
			}
			case SizeMode.COVER: {
				rx = ry = shortest;
			}
			case SizeMode.CONTAIN: {
				//use actual size
			}
		}

		_sizeFactor.x = rx;
		_sizeFactor.y = ry;

		zoom = zoom;
		updatePos();
	}

	inline function updatePos() {
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
		onPreRender = null;
		onPostRender = null;
		transform = null;
		_viewMatrixInverted = null;
		projectionMatrix = null;
		_manager = null;
	}

	inline function updateMatrices() {
		_viewMatrixInverted.copy(transform.world.matrix);
		_viewMatrixInverted.invert();

		projectionMatrix.identity();
		
		// if (kha.Image.renderTargetsInvertedY()) {
		// 	projectionMatrix.orto(0, viewport.w / _resolution, 0, viewport.h / _resolution);
		// } else {
		// 	projectionMatrix.orto(0, viewport.w / _resolution, viewport.h / _resolution, 0);
		// }
		if (kha.Image.renderTargetsInvertedY()) {
			projectionMatrix.orto(0, Clay.screen.width/_resolution, 0, Clay.screen.height/_resolution);
		} else {
			projectionMatrix.orto(0, Clay.screen.width/_resolution, Clay.screen.height/_resolution, 0);
		}

		projectionMatrix.append(_viewMatrixInverted);
	}

	function preRender(ctx:RenderContext) {
		transform.update();
		updateMatrices();

		onPreRender.emit(this);
		var target = getRenderTarget();
		ctx.begin(target, bgColor);
		// ctx.begin(target, Color.BLUE);
		// ctx.setViewport(viewport);
		// ctx.setClipBounds(viewport);
		ctx.setProjection(projectionMatrix);
	}

	function renderBuffer() {
		if(onRenderTexture != null) {
			onRenderTexture(_bufferInternal, buffer);
		}
	}

	function postRender(ctx:RenderContext) {
		ctx.end();
		onPostRender.emit(this);
		_redraw = false;
	}

	inline function getRenderTarget():Texture {
		var target = Clay.renderer.target;
		if(target == null) {
			target = _bufferInternal != null ? _bufferInternal : buffer;
		}
		return target;
	}
	
	function set_sizeMode(mode:SizeMode):SizeMode {
		sizeMode = mode;
		updateSize();

		return mode;
	}

	inline function get_pos() return transform.pos;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;

	function set_zoom(v:Float):Float {
		if(v < 0.01) {
			v = 0.01;
		}

		updatePos();

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

	inline function get_viewport():Rectangle return _viewport;
	
	function set_viewport(v:Rectangle):Rectangle {
		_viewport = v;
		updateBuffer();
		return _viewport;
	}

	inline function get_antialiasing():Int return _antialiasing;
	inline function get_resolution():Float return _resolution;

	function set_antialiasing(v:Int):Int {
		assert(!Clay.renderer.rendering, 'You cant change antialiasing while rendering');
		_antialiasing = v;

		updateBuffer();

		return v;
	}

	function set_resolution(value:Float):Float {
		assert(!Clay.renderer.rendering, 'You cant change resolution while rendering');
		_resolution = Mathf.clamp(value, 0.1, 2);

		updateBuffer();

		return _resolution;
	}

	function set_onRenderTexture(v:(source:Texture, target:Texture)->Void) {
		if(v != null) {
			createBufferInternal();
		} else {
			destroyBufferInternal();
		}
		onRenderTexture = v;
		return onRenderTexture;
	}

	function updateBuffer() {
		if(buffer != null) {
			buffer.unload();
			Clay.resources.remove(buffer);
		}

		var w = Std.int(viewport.w * _resolution);
		var h = Std.int(viewport.h * _resolution);

		buffer = Texture.createRenderTarget(
			w, 
			h, 
			TextureFormat.RGBA32, 
			DepthStencilFormat.NoDepthAndStencil,
			_antialiasing
		);
		
		buffer.id = 'camera.$name';
		buffer.ref();
		Clay.resources.add(buffer);

		destroyBufferInternal();

		if(onRenderTexture != null) {
			createBufferInternal();
		}
		onBufferResize.emit(w, h);
	}

	function createBufferInternal() {
		if(_bufferInternal == null) {
			_bufferInternal = Texture.createRenderTarget(
				Std.int(viewport.w * _resolution), 
				Std.int(viewport.h * _resolution), 
				TextureFormat.RGBA32, 
				DepthStencilFormat.NoDepthAndStencil,
				_antialiasing
			);

			_bufferInternal.id = 'camera.$name.internal';
			Clay.resources.add(_bufferInternal);
		}
	}

	function destroyBufferInternal() {
		if(_bufferInternal != null) {
			_bufferInternal.unload();
			Clay.resources.remove(_bufferInternal);
		}
	}

}

enum abstract SizeMode(Int) {
		/** fit the size into the camera viewport (possible letter/pillar box) */
	var FIT;
		/** cover the viewport with the size (possible cropping) */
	var COVER;
		/** contain the size (stretch to fit the viewport)*/
	var CONTAIN;
}