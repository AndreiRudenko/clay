package clay.components.misc;


import kha.math.FastMatrix3;
import kha.graphics4.Graphics;

import clay.math.Matrix;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.math.Mathf;
import clay.ds.BitVector;
import clay.core.Signal;
import clay.components.common.Transform;

using clay.render.utils.FastMatrix3Extender;


@:allow(clay.render.Renderer)
class Camera {


	public var name (default, null):String;
	public var active:Bool = true;
	public var viewport:Rectangle;

	public var onprerender  (default, null):Signal<Void->Void>;
	public var onpostrender	(default, null):Signal<Void->Void>;

	@:noCompletion public var transform:Transform;

	@:noCompletion public var view_matrix:Matrix;
	@:noCompletion public var view_matrix_inverted:Matrix;
	@:noCompletion public var projection_matrix:FastMatrix3;

	public var zoom(default, set):Float;
	public var pos(get, null):Vector;
	public var rotation(get, set):Float;

	var visible_layers_mask:BitVector;
	var added:Bool = false;


	@:access(clay.render.Renderer)
	public function new(_name:String, _x:Float = 0, _y:Float = 0, ?_w:Float, ?_h:Float) {

		name = _name;

		var w:Float = _w != null ? _w : Clay.screen.width;
		var h:Float = _h != null ? _h : Clay.screen.height;

		viewport = new Rectangle(_x, _y, w, h);

		view_matrix = new Matrix();
		view_matrix_inverted = new Matrix();
		projection_matrix = FastMatrix3.identity();

		visible_layers_mask = new BitVector(Clay.renderer.layers_max);
		visible_layers_mask.enable_all();

		transform = new CameraTransform(this);

		zoom = 1;

		onprerender = new Signal();
		onpostrender = new Signal();

	}

	public function destroy() {

		if(added) {
			Clay.renderer.cameras.remove(name);
		}
		
	}

	public function hide_layers(?layers:Array<Int>) {

		if(layers != null) {
			for (i in layers) {
				visible_layers_mask.disable(i);
			}
		} else {
			visible_layers_mask.disable_all();
		}
		
	}

	public function show_layers(?layers:Array<Int>) {

		if(layers != null) {
			for (i in layers) {
				visible_layers_mask.enable(i);
			}
		} else {
			visible_layers_mask.enable_all();
		}

	}

	public function screen_to_world(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		update();

		into.transform(view_matrix);

		return into;
		
	}

	public function world_to_screen(v:Vector, ?into:Vector):Vector {

		if(into == null) {
			into = new Vector();
		}

		update();

		into.transform(view_matrix_inverted);

		return into;
		
	}

	public inline function update() {

		transform.update();
		update_matrices();

	}

	inline function update_matrices() {
		
		view_matrix_inverted.copy(view_matrix);
		view_matrix_inverted.invert();
		projection_matrix.identity();
		
		if (Clay.renderer.target.image.g4.renderTargetsInvertedY()) {
			projection_matrix.orto(0, viewport.w, 0, viewport.h);
		}
		else {
			projection_matrix.orto(0, viewport.w, viewport.h, 0);
		}

		projection_matrix.append_matrix(view_matrix_inverted);

	}

	inline function get_pos() return transform.pos;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;

	function set_zoom(v:Float):Float {

		if(v < 0.01) {
			v = 0.01;
		}
		
		return zoom = v;

	}

	function prerender(g:Graphics) {

		onprerender.emit();

		var _x:Int = Std.int(viewport.x);
		var _y:Int = Std.int(viewport.y);
		var _w:Int = Std.int(viewport.w);
		var _h:Int = Std.int(viewport.h);
		
		g.viewport(_x, _y, _w, _h);
		g.scissor(_x, _y, _w, _h);

	}

	function postrender(g:Graphics) {

		g.disableScissor();
		onpostrender.emit();
		
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

		var hw:Float = camera.viewport.w * 0.5;
		var hh:Float = camera.viewport.h * 0.5;
		var z:Float = 1/camera.zoom;

		local.identity()
		.translate(pos.x, pos.y)
		.translate(hw, hh) // translate to rotate origin
		.rotate(Mathf.radians(-rotation)) // negative ?
		.scale(z, z)
		.apply(-hw, -hh); // revert rotate origin translation

		if(parent != null) {
			world.copy(parent.world).multiply(local); // todo: check
		} else {
			world.copy(local);
		}

		camera.view_matrix.copy(world);

	}


}