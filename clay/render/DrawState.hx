package clay.render;


import clay.math.Rectangle;
import clay.resources.Texture;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;


class DrawState {


	public var shader:Shader;
	public var clip_rect:Rectangle;
	public var texture:Texture;

	public var blend_src:BlendMode;
	public var blend_dst:BlendMode;
	public var blend_op:BlendEquation;

	public var alpha_blend_dst:BlendMode;
	public var alpha_blend_src:BlendMode;
	public var alpha_blend_op:BlendEquation;


	public function new() {

	}


	

}