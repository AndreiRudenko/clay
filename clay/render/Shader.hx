package clay.render;


import kha.graphics4.Graphics;
import kha.math.FastMatrix3;
import clay.components.graphics.Geometry;

import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;


@:access(clay.render.Renderer)
class Shader extends kha.graphics4.PipelineState {


	static var ID:Int = 0;

	public var id(default,null):Int;

	var blendSource_default:BlendMode;
	var alphaBlendDestination_default:BlendMode;
	var alphaBlendSource_default:BlendMode;
	var blendDestination_default:BlendMode;
	var blendOperation_default:BlendEquation;

	public function new() {

		super();
		id = Shader.ID++;

		if(id > Clay.renderer.shader_max) {
			throw('Error: to many shaders, max: ${Clay.renderer.shader_max}');
		}

	}

	override function compile() {
	    
		super.compile();

		blendSource_default = blendSource;
		alphaBlendDestination_default = alphaBlendDestination;
		alphaBlendSource_default = alphaBlendSource;
		blendDestination_default = blendDestination;
		blendOperation_default = blendOperation;

	}

	public function reset_blendmodes() {
		
		blendSource = blendSource_default;
		alphaBlendDestination = alphaBlendDestination_default;
		alphaBlendSource = alphaBlendSource_default;
		blendDestination = blendDestination_default;
		blendOperation = blendOperation_default;
		
	}


}