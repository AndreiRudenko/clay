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
import clay.render.types.TextureFormat;
import clay.render.types.Usage;
import clay.render.types.TextureFilter;
import clay.render.types.TextureAddressing;
import clay.utils.Log.*;
import clay.resources.Texture;

using clay.render.utils.FastMatrix3Extender;


@:allow(clay.render.Renderer)
class Camera {


	public var name (default, null):String;
	public var active (get, set):Bool;
	public var viewport:Rectangle;

	public var priority(default, null):Int;

	public var onprerender  (default, null):Signal<Camera->Void>;
	public var onpostrender	(default, null):Signal<Camera->Void>;

	@:noCompletion public var transform:Transform;

	@:noCompletion public var view_matrix:Matrix;
	@:noCompletion public var view_matrix_inverted:Matrix;
	@:noCompletion public var projection_matrix:FastMatrix3;

	public var zoom(default, set):Float;
	public var pos(get, null):Vector;
	public var rotation(get, set):Float;
	public var size(default, null):VectorCallback;
	public var size_mode (default, set):SizeMode;
	// dont use colors with alpha
	public var clear_color:Color;

	public var antialiasing(get, set):Int;
	public var resolution(get, set):Float;
	public var buffer(default, null):Texture;
	@:noCompletion public var _size_factor:Vector;

	var _resolution:Float = 1;
	var _antialiasing:Int = 1;
	var _active:Bool = false;
	var _visible_layers_mask:BitVector;
	var _manager:CameraManager;


	function new(manager:CameraManager, name:String, viewport:Rectangle, priority:Int) {

		this.name = name;
		this.priority = priority;
		_manager = manager;
		clear_color = new Color(0,0,0,1);

		size = new VectorCallback();
		_size_factor = new Vector(1,1);
		size.listen(set_size);

		this.viewport = new Rectangle(0, 0, Clay.screen.width, Clay.screen.height);

		if(viewport != null) {
			this.viewport.copy_from(viewport);
		}

		view_matrix = new Matrix();
		view_matrix_inverted = new Matrix();
		projection_matrix = FastMatrix3.identity();

		_visible_layers_mask = new BitVector(Clay.renderer.layers.capacity);
		_visible_layers_mask.enable_all();

		transform = new CameraTransform(this);

		zoom = 1;

		onprerender = new Signal();
		onpostrender = new Signal();

		size_mode = SizeMode.fit;

		update_buffer();

	}

	function destroy() {

		name = null;
		viewport = null;
		onprerender = null;
		onpostrender = null;
		transform = null;
		view_matrix = null;
		view_matrix_inverted = null;
		projection_matrix = null;
		_visible_layers_mask = null;
		_manager = null;

	}

	function set_size_mode( _m:SizeMode ) : SizeMode {

		size_mode = _m;
		set_size(0);

		return _m;

	}

	function set_size(v:Float) {

		if(size.x == 0 || size.y == 0) {
			return;
		}
		
		var _ratio_x = viewport.w / size.x;
		var _ratio_y = viewport.h / size.y;
		var _shortest = Math.max( _ratio_x, _ratio_y );
		var _longest = Math.min( _ratio_x, _ratio_y );

        switch(size_mode) {
            case SizeMode.fit:{
                _ratio_x = _ratio_y = _longest;
            }
            case SizeMode.cover: {
                _ratio_x = _ratio_y = _shortest;
            }
            case SizeMode.contain: {
                //use actual size
            }
        }

		_size_factor.x = _ratio_x;
		_size_factor.y = _ratio_y;

	}

	function update_buffer() {
		
		if(buffer != null) {
			buffer.unload();
			Clay.resources.remove(buffer);
		}

		buffer = Texture.create_rendertarget(
			Std.int(viewport.w * _resolution), 
			Std.int(viewport.h * _resolution), 
			TextureFormat.RGBA32, 
			DepthStencilFormat.NoDepthAndStencil,
			_antialiasing,
			null,
			true
		);
		
		buffer.id = 'camera.$name';
		Clay.resources.add(buffer);

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

		update();

		into.transform(view_matrix);

		return into;
		
	}

	public function world_to_screen(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}
		
		into.copy_from(v);

		update();

		into.transform(view_matrix_inverted);

		return into;
		
	}

	public inline function update() {

		transform.update();

	}

	inline function update_matrices(g:Graphics) {
		
		view_matrix_inverted.copy(view_matrix);
		view_matrix_inverted.invert();
		projection_matrix.identity();

		if (g.renderTargetsInvertedY()) {
			projection_matrix.orto(0, viewport.w / _resolution, 0, viewport.h / _resolution);
		} else {
			projection_matrix.orto(0, viewport.w / _resolution, viewport.h / _resolution, 0);
		}

		projection_matrix.append_matrix(view_matrix_inverted);

	}

	inline function get_pos() return transform.pos;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;
	inline function get_antialiasing():Int return _antialiasing;
	inline function get_resolution():Float return _resolution;

	function set_zoom(v:Float):Float {

		if(v < 0.01) {
			v = 0.01;
		}
		
		return zoom = v;

	}

	function prerender() {

		onprerender.emit(this);

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : buffer.image.g4;

		g.begin();
		g.clear(clear_color.to_int());

		update_matrices(g);
		g.viewport(Std.int(viewport.x), Std.int(viewport.y), Std.int(viewport.w), Std.int(viewport.h));

	}

	function postrender() {

		var g = Clay.renderer.target != null ? Clay.renderer.target.image.g4 : buffer.image.g4;

		g.disableScissor();
		g.end();
		
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

	function set_antialiasing(v:Int):Int {

		if(Clay.renderer.rendering) {
			throw('you cant change antialiasing while rendering');
		}

		_antialiasing = v;

		update_buffer();

		return v;
		
	}

	function set_resolution(value:Float):Float {

		if(Clay.renderer.rendering) {
			throw('you cant change antialiasing while rendering');
		}

		_resolution = Mathf.clamp(value, 0.1, 1);

		update_buffer();

		return _resolution;

	}

}


class CameraTransform extends Transform {


	var camera:Camera;


	public function new(c:Camera) {

		super();
		camera = c;

	}

	override function update() { // todo: check dirty

		if(parent != null) {
			parent.update();
		}

		_cleaning = true;

		var hw:Float = camera.viewport.w * 0.5;
		var hh:Float = camera.viewport.h * 0.5;
		var corx:Float = 0;
		var cory:Float = 0;

		var zx:Float = 1 / (camera._size_factor.x * camera.zoom);
		var zy:Float = 1 / (camera._size_factor.y * camera.zoom);

		if(camera.size.x != 0 && camera.size.y != 0) {
			hw = camera.size.x * 0.5;
			hh = camera.size.y * 0.5;
			corx = hw - camera.viewport.w / 2;
			cory = hh - camera.viewport.h / 2;
		}

		_local.matrix.identity()
		.translate(pos.x, pos.y) // apply position
		.translate(hw, hh) // translate to origin
		.rotate(Mathf.radians(-rotation)) // rotate
		.scale(zx, zy) // scale
		.apply((-hw + corx), (-hh + cory)) // revert origin translation
		;

		if(parent != null) {
			_world.matrix.copy(parent._world.matrix).append(_local.matrix);
		} else {
			_world.matrix.copy(_local.matrix);
		}

        _world.decompose(false);

		camera.view_matrix.copy(_world.matrix);

		_cleaning = false;

		if(_clean_handlers != null && _clean_handlers.length > 0) {
			for(handler in _clean_handlers) {
				handler(this);
			}
		}

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