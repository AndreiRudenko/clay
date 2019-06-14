package clay.core;

import kha.System;
import kha.WindowMode;
import kha.graphics4.DepthStencilFormat;
import clay.types.ScreenRotation;
import clay.render.types.TextureFormat;
import clay.render.types.Usage;
import clay.resources.Texture;
import clay.math.Vector;

@:access(clay.Engine)
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
	var window:kha.Window; // todo, multiple windows ?


	@:allow(clay.Engine)
	function new(_antial:Int) {

		_antialiasing = _antial;

		cursor = new Cursor();
		window = kha.Window.get(0);
		mid = new Vector(window.width*0.5, window.height*0.5);

	}

	@:allow(clay.Engine)
	function init() {

		update_buffer();
		
	}

	public function resize(_w:Int, _h:Int) {

		if(Clay.renderer.rendering) {
			throw('you cant resize screen while rendering');
		}

		window.resize(_w, _h);
		update_buffer();

	}

	function update_buffer() {
		
		if(buffer != null) {
			buffer.unload();
			Clay.resources.remove(buffer);
		}

		buffer = Texture.create_rendertarget(
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
		
		mid.set(window.width*0.5, window.height*0.5);

	}

	function get_ppi():Int {

		return kha.Display.primary.pixelsPerInch;
		
	}

	function get_rotation():ScreenRotation {

		return System.screenRotation;
		
	}

	function get_width():Int {

		return window.width;
		
	}

	function get_height():Int {

		return window.height;
		
	}

	function get_fullscreen():Bool {

		return window.mode == WindowMode.Fullscreen;
		
	}

	function set_fullscreen(v:Bool):Bool {

		if(v) {
			if(!fullscreen) {
				window.mode = WindowMode.Fullscreen;
			}
		} else if(fullscreen) {
			window.mode = WindowMode.Windowed;
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

		update_buffer();

		return v;
		
	}


}

class Cursor {

	public var pos(default, null):Vector;
	public var visible(get, set):Bool;
	var _visible:Bool = true;

	@:allow(clay.core.Screen)
	function new() {

		pos = new Vector();
		
		var m = kha.input.Mouse.get();
		if(m != null) {
			m.notify(null, null, onmove, null);
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

	function onmove(x:Int, y:Int, x_rel:Int, y_rel:Int) {

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
