package clay.render;


import kha.graphics4.Graphics;
import kha.math.FastMatrix3;
import clay.components.graphics.Geometry;


@:access(clay.render.Renderer)
class Shader extends kha.graphics4.PipelineState {


	static var ID:Int = 0;

	public var id(default,null):Int;


	public function new() {

		super();

		id = Shader.ID++;

		if(id > Clay.renderer.shader_max) {
			throw('Error: to many shaders, max: ${Clay.renderer.shader_max}');
		}

	}


}