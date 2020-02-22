package clay.system;

import kha.System;
import kha.WindowMode;
import kha.graphics4.DepthStencilFormat;
import clay.render.types.TextureFormat;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.math.Vector;

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

	var _antialiasing:Int = 1;
	var _window:kha.Window; // todo, multiple windows ?


	@:allow(clay.system.App)
	function new(antialiasing:Int) {

		_antialiasing = antialiasing;

		cursor = new Cursor();
		_window = kha.Window.get(0);
		mid = new Vector(_window.width*0.5, _window.height*0.5);

	}

	@:allow(clay.system.App)
	function init() {

		updateBuffer();
		
	}

	public function resize(_w:Int, _h:Int) {

		if(Clay.renderer.rendering) {
			throw('you cant resize screen while rendering');
		}

		_window.resize(_w, _h);
		updateBuffer();

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
			_antialiasing,
			null,
			true
		);
		
		buffer.id = 'frontbuffer';
		Clay.resources.add(buffer);
		
		mid.set(_window.width*0.5, _window.height*0.5);

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
	public var visible(get, set):Bool;
	var _visible:Bool = true;

	@:allow(clay.system.Screen)
	function new() {

		pos = new Vector();
		
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
