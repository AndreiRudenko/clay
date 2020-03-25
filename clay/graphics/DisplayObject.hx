package clay.graphics;

import clay.math.Rectangle;
import clay.math.Transform;
import clay.render.Shader;
import clay.render.LayerObject;
import clay.utils.Log.*;

class DisplayObject extends LayerObject {

	public var transform:Transform;
	public var shader(default, set):Shader;
	public var clipRect(default, set):Rectangle;

	var shaderDefault:Shader;

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
		var renderShader = getRenderShader();
		sortKey.shader = renderShader.id;
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

	inline function getRenderShader() {
		return shader != null ? shader : shaderDefault;
	}

}