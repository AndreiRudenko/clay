package clay.render;

import kha.math.FastMatrix3;
import clay.math.Rectangle;
import clay.resources.Texture;
import clay.render.TextureParameters;
import clay.render.Shader;
import clay.render.Blending;
import clay.utils.BlendMode;
import clay.utils.Color;
using clay.render.utils.FastMatrix3Extender;

class RenderState {

	public var id(get, never):Int;
	public var target:Texture;
	public var texture:Texture;
	public var textureParameters:TextureParameters;
	public var shader:Shader;
	public var clipBounds:Rectangle;
	public var clipRect:Rectangle;
	public var viewport:Rectangle;
	public var blending:Blending;
	public var projectionMatrix:FastMatrix3;
	public var clearColor:kha.Color;
	public var color:Color;

	public function new() {
		projectionMatrix = FastMatrix3.identity();
	}

	public function reset() {
		target = null;
		texture = null;
		textureParameters = null;
		shader = null;
		clipBounds = null;
		clipRect = null;
		viewport = null;
		blending = null;
		projectionMatrix.identity();
		clearColor = 0;
	}

	inline function get_id() {
		return target.tid;
	}
	
}