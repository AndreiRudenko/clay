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
	public var round_pixels:Bool;

	public var bounds:Rectangle;
	public var priority(default, null):Int;

	public var onprerender  (default, null):Signal<(c:Camera)->Void>;
	public var onpostrender	(default, null):Signal<(c:Camera)->Void>;

	@:noCompletion public var transform:Transform;
	@:noCompletion public var projection_matrix:Matrix;

	public var zoom(default, set):Float;
	public var pos(default, null):VectorCallback;
	public var rotation(get, set):Float;
	public var size(default, null):VectorCallback;
	public var anchor(default, null):VectorCallback;
	public var size_mode (default, set):SizeMode;
	
	@:noCompletion public var _size_factor:Vector;

	var _active:Bool = false;
	var _visible_layers_mask:BitVector;
	var _manager:CameraManager;

	// var _view_matrix:Matrix;
	var _view_matrix_inverted:Matrix;
	

	function new(manager:CameraManager, name:String, viewport:Rectangle, priority:Int) {

		this.name = name;
		this.priority = priority;
		round_pixels = false;
		_manager = manager;

		pos = new VectorCallback();
		anchor = new VectorCallback(0.5,0.5);
		size = new VectorCallback();

		pos.listen(update_pos);
		anchor.listen(update_pos);
		size.listen(set_size);

		_size_factor = new Vector(1,1);

		this.viewport = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);

		if(viewport != null) {
			this.viewport.copy_from(viewport);
		}

		// _view_matrix = new Matrix();
		_view_matrix_inverted = new Matrix();
		projection_matrix = new Matrix();

		_visible_layers_mask = new BitVector(Clay.renderer.layers.capacity);
		_visible_layers_mask.enable_all();

		transform = new Transform();

		zoom = 1;

		onprerender = new Signal();
		onpostrender = new Signal();

		size_mode = SizeMode.fit;

		update_pos(0);

	}

	public function hide_layers(?layers:Array<String>):Camera {

		if(layers != null) {
			var l:Layer;
			for (n in layers) {
				l = Clay.renderer.layers.get(n);
				if(l != null) {
					_visible_layers_mask.disable(l.id);
				} else {
					log('can`t hide layer `${n}` for camera `${name}`');
				}
			}
		} else {
			_visible_layers_mask.disable_all();
		}

		return this;

	}

	public function show_layers(?layers:Array<String>):Camera {

		if(layers != null) {			
			var l:Layer;
			for (n in layers) {
				l = Clay.renderer.layers.get(n);
				if(l != null) {
					_visible_layers_mask.enable(l.id);
				} else {
					log('can`t show layer `${n}` for camera `${name}`');
				}
			}
		} else {
			_visible_layers_mask.enable_all();
		}
		
		return this;

	}

	public function screen_to_world(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		into.copy_from(v);

		transform.update();

		into.transform(transform.world.matrix);

		return into;
		
	}

	public function world_to_screen(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		into.copy_from(v);

		transform.update();

		_view_matrix_inverted.copy(transform.world.matrix);
		_view_matrix_inverted.invert();

		into.transform(_view_matrix_inverted);

		return into;
		
	}

	function update_pos(_:Float) {

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
			pos.ignore_listeners = true;

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

			pos.ignore_listeners = false;
		}

		var px = pos.x + ox + corx;
		var py = pos.y + oy + cory;

		transform.pos.set(px, py);
		transform.origin.set(ox, oy);

	}

	function destroy() {

		name = null;
		viewport = null;
		onprerender = null;
		onpostrender = null;
		transform = null;
		// _view_matrix = null;
		_view_matrix_inverted = null;
		projection_matrix = null;
		_visible_layers_mask = null;
		_manager = null;

	}

	function set_size_mode(mode:SizeMode):SizeMode {

		size_mode = mode;
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

		switch(size_mode) {
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

		_size_factor.x = rx;
		_size_factor.y = ry;

		zoom = zoom;
		update_pos(0);

	}

	inline function update_matrices(g:Graphics) {

		_view_matrix_inverted.copy(transform.world.matrix);
		_view_matrix_inverted.invert();

		projection_matrix.identity();

		if (kha.Image.renderTargetsInvertedY()) {
			projection_matrix.orto(0, viewport.w, 0, viewport.h);
		} else {
			projection_matrix.orto(0, viewport.w, viewport.h, 0);
		}

		projection_matrix.append(_view_matrix_inverted);

	}

	inline function get_pos() return transform.pos;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;

	function set_zoom(v:Float):Float {

		if(v < 0.01) {
			v = 0.01;
		}

		zoom = v;

		var sx = 1 / (_size_factor.x * zoom);
		var sy = 1 / (_size_factor.y * zoom);

		transform.scale.set(sx, sy);

		return v;

	}

	function prerender() {

		onprerender.emit(this);

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

		transform.update();
		update_matrices(g);

		g.viewport(Std.int(viewport.x), Std.int(viewport.y), Std.int(viewport.w), Std.int(viewport.h));

	}

	function postrender() {

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : Clay.screen.buffer.image.g4;

		// g.disableScissor();
		
		onpostrender.emit(this);
		
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