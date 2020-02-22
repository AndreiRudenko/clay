package clay.graphics;


import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.VectorCallback;
import clay.render.Layer;
import clay.render.Shader;
import clay.render.Painter;
import clay.render.Camera;
import clay.render.LayerObject;
import clay.utils.Log.*;


class DisplayObject extends LayerObject {


	public var transform:Transform;

	public var shader(default, set):Shader;
	public var clipRect(default, set):Rectangle;

	public var shaderDefault(default, null):Shader;

	public var pos(get, never):VectorCallback;
	public var scale(get, never):VectorCallback;
	public var rotation(get, set):Float;
	public var origin(get, never):VectorCallback;
	

	public function new() {

		super();
		
		name = 'displayObject.${clay.utils.UUID.get()}';
		transform = new Transform();
		shaderDefault = Clay.renderer.shaders.get('textured');

	}

	override function update(dt:Float) {

		transform.update();

	}

	function set_shader(v:Shader):Shader {

		sortKey.shader = v != null ? v.id : shaderDefault.id;

		dirtySort();

		return shader = v;

	}

	function set_clipRect(v:Rectangle):Rectangle {

		sortKey.clip = v != null;

		if(clipRect == null && v != null || clipRect != null && v == null) {
			dirtySort();
		}

		return clipRect = v;

	}

	inline function get_pos() return transform.pos;
	inline function get_scale() return transform.scale;
	inline function get_rotation() return transform.rotation;
	inline function set_rotation(v:Float) return transform.rotation = v;
	inline function get_origin() return transform.origin;
	

}