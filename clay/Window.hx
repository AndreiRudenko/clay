package clay;

import kha.System;
import kha.WindowMode;

import clay.Graphics;
import clay.graphics.Texture;
import clay.graphics.Color;
import clay.math.Vector2;
import clay.utils.Signal;
import clay.utils.Log;

typedef ScreenRotation = kha.ScreenRotation;
typedef WindowMode = kha.WindowMode;

@:allow(clay.App)
class Window {

	public var width(get, null):Int;
	public var height(get, null):Int;
	public var mid(default, null):Vector2;

	public var buffer(default, null):Texture;
	public var antialiasing(get, set):Int;

	public var ppi(get, null):Int;
	public var rotation(get, null):ScreenRotation;
	public var fullscreen(get, set):Bool;

	public var cursor(default, null):Cursor;
	public var onResize(default, null):Signal<(w:Int, h:Int)->Void>;
	public var color:Color;

	var _antialiasing:Int = 1;

	var _windowId:Int = 0;
	var _window:kha.Window; // TODO: multiple windows ?

	function new(antialiasing:Int) {
		_antialiasing = antialiasing;

		cursor = new Cursor();
		_window = kha.Window.get(_windowId);
		mid = new Vector2();
		onResize = new Signal();
		color = new Color();
	}

	public function resize(w:Int, h:Int) {
		_window.resize(w, h);
		onResize.emit(w, h);
		updateSize();
	}

	function init() {
		updateSize();
	}

	function render() {
		Graphics.blit(buffer);
	}

	function updateSize() {
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
		
		buffer.name = 'windowbuffer';
		buffer.ref();
		Clay.resources.add(buffer);

		mid.set(width*0.5, height*0.5);
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
		// Log.assert(!Clay.renderer.isRendering, 'you cant change antialiasing while rendering');
		_antialiasing = v;

		updateSize();

		return v;
	}

}

class Cursor {

	public var x(default, null):Float;
	public var y(default, null):Float;
	public var dx(default, null):Float;
	public var dy(default, null):Float;

	public var visible(get, set):Bool;
	var _visible:Bool = true;

	@:allow(clay.Window)
	function new() {
		x = 0;
		y = 0;
		dx = 0;
		dy = 0;
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
		this.x = x;
		this.y = y;
		this.dx = dx;
		this.dy = dy;
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
