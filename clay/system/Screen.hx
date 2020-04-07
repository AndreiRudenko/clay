package clay.system;

import kha.System;
import kha.WindowMode;
import kha.graphics4.DepthStencilFormat;
import clay.render.types.TextureFormat;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.render.RenderContext;
import clay.render.Camera;
import clay.utils.Color;
import clay.events.Signal;
import clay.utils.Log.*;

typedef ScreenRotation = kha.ScreenRotation;
typedef WindowMode = kha.WindowMode;

@:access(clay.system.App)
class Screen {

	public var width(get, null):Int;
	public var height(get, null):Int;
	public var mid(default, null):Vector;

	public var ppi(get, null):Int;
	public var rotation(get, null):ScreenRotation;
	public var fullscreen(get, set):Bool;

	public var cursor(default, null):Cursor;
	public var buffer(default, null):Texture;

	public var antialiasing(get, set):Int;
	public var onResize(default, null):Signal<(w:Int, h:Int)->Void>;

	var _antialiasing:Int = 1;
	var _window:kha.Window; // TODO: multiple windows ?

	var _viewport:Rectangle;
	var _projectionMatrix:Matrix;

	@:allow(clay.system.App)
	function new(antialiasing:Int) {
		_antialiasing = antialiasing;

		cursor = new Cursor();
		_window = kha.Window.get(0);
		mid = new Vector(width*0.5, height*0.5);
		_viewport = new Rectangle();
		_projectionMatrix = new Matrix();
		onResize = new Signal();
	}

	@:allow(clay.system.App)
	function init() {
		updateBuffer();
		updateViewport();
		updateProjection();
	}

	public function resize(w:Int, h:Int) {
		if(Clay.renderer.rendering) {
			throw('you cant resize screen while rendering');
		}

		_window.resize(w, h);
		updateBuffer();
		updateViewport();
		updateProjection();
		onResize.emit(w, h);
	}

	@:noCompletion public function preRender(ctx:RenderContext) {
		ctx.begin(buffer);
		ctx.setShader(Clay.renderer.shaderTextured);
		ctx.setViewport(_viewport);
		ctx.setClipBounds(_viewport);
		ctx.setProjection(_projectionMatrix);
	}

	@:noCompletion public function render(ctx:RenderContext, camera:Camera) {
		ctx.setTexture(camera.buffer);

		var w = camera.viewport.w;
		var h = camera.viewport.h;
		var x = camera.viewport.x;
		var y = camera.viewport.y;
		var color = Color.WHITE;

		ctx.beginGeometry();

		ctx.addIndex(0);
		ctx.addIndex(1);
		ctx.addIndex(2);
		ctx.addIndex(0);
		ctx.addIndex(2);
		ctx.addIndex(3);

		ctx.setColor(color);

		ctx.addVertex(
			x,
			y,
			0,
			0
		);

		ctx.addVertex(
			x + w,
			y,
			1,
			0
		);

		ctx.addVertex(
			x + w,
			y + h,
			1,
			1
		);

		ctx.addVertex(
			x,
			y + h,
			0,
			1
		);

		ctx.endGeometry();
	}

	@:noCompletion public function postRender(ctx:RenderContext) {
		ctx.end();
	}

	function updateBuffer() {
		if(buffer != null) {
			buffer.unload();
			Clay.resources.remove(buffer);
		}

		buffer = Texture.createRenderTarget(
			width, 
			height, 
			TextureFormat.RGBA32, 
			DepthStencilFormat.NoDepthAndStencil,
			_antialiasing
		);
		
		buffer.id = 'frontbuffer';
		buffer.ref();
		Clay.resources.add(buffer);
	}

	function updateViewport() {
		_viewport.set(0, 0, width, height);
		mid.set(width*0.5, height*0.5); //TODO: move
	}

	function updateProjection() {
		if (kha.Image.renderTargetsInvertedY()) {
			_projectionMatrix.orto(0, width, 0, height);
		} else {
			_projectionMatrix.orto(0, width, height, 0);
		}
	}

	function get_ppi():Int {
		return kha.Display.primary.pixelsPerInch;
	}

	function get_rotation():ScreenRotation {
		return System.screenRotation;
	}

	function get_width():Int {
		return _window.width;
	}

	function get_height():Int {
		return _window.height;
	}

	function get_fullscreen():Bool {
		return _window.mode == WindowMode.Fullscreen;
	}

	function set_fullscreen(v:Bool):Bool {
		if(v) {
			if(!fullscreen) {
				_window.mode = WindowMode.Fullscreen;
			}
		} else if(fullscreen) {
			_window.mode = WindowMode.Windowed;
		}

		return v;
	}

	inline function get_antialiasing():Int {
		return _antialiasing;
	}

	function set_antialiasing(v:Int):Int {
		if(Clay.renderer.rendering) {
			throw('you cant change antialiasing while rendering');
		}

		_antialiasing = v;

		updateBuffer();

		return v;
	}

}

class Cursor {

	public var pos(default, null):Vector;
	public var displacement(default, null):Vector;
	public var visible(get, set):Bool;
	var _visible:Bool = true;

	@:allow(clay.system.Screen)
	function new() {
		pos = new Vector();
		displacement = new Vector();
		
		var m = kha.input.Mouse.get();
		if(m != null) {
			m.notify(null, null, onMove, null);
		}
	}

	public function lock() {
		var m = kha.input.Mouse.get();
		if(m != null) {
			m.lock();
		}
	}

	public function unlock() {
		var m = kha.input.Mouse.get();
		if(m != null) {
			m.unlock();
		}
	}

	function get_visible():Bool {
		return _visible;
	}

	function onMove(x:Int, y:Int, dx:Int, dy:Int) {
		pos.set(x, y);
		displacement.set(dx, dy);
	}

	function set_visible(v:Bool):Bool {
		var m = kha.input.Mouse.get();
		if(m != null) {
			if(v) {
				m.showSystemCursor();
			} else {
				m.hideSystemCursor();
			}
			_visible = v;
		}

		return _visible;
	}

}
