package clay;

import kha.System;
import kha.WindowMode;
import kha.graphics4.DepthStencilFormat;
import clay.types.ScreenRotation;
import clay.components.Texture;
import clay.math.Vector;

class Screen {


	public var width(get, null):Int;
	public var height(get, null):Int;
	public var mid(default, null):Vector;

	public var ppi(get, null):Int;
	public var rotation(get, null):ScreenRotation;
	public var fullscreen(get, set):Bool;

	public var cursor(default, null):Cursor;
	public var buffer(default, null):Texture;

	public var antialiasing(default, set):Int = 1; // todo

	var window:kha.Window; // todo, multiple windows ?


    @:allow(clay.Engine)
	function new() {

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
			buffer.destroy();
		}

		buffer = Texture.create_rendertarget(
			width, 
			height, 
			TextureFormat.RGBA32, 
			DepthStencilFormat.NoDepthAndStencil,
			antialiasing,
			null,
			true
		);
		
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
			window.mode = WindowMode.Window;
		}

		return v;
		
	}

	function set_antialiasing(v:Int):Int {

		if(Clay.renderer.rendering) {
			throw('you cant change antialiasing while rendering');
		}

		update_buffer();

		return antialiasing = v;
		
	}


}

class Cursor {

	public var pos(default, null):Vector; // todo
	public var visible(get, set):Bool;
	var _visible:Bool = true;

    @:allow(clay.Screen)
	function new() {

		pos = new Vector();
		
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
