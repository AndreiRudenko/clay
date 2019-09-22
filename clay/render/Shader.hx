package clay.render;


import kha.graphics4.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.arrays.Float32Array;

import clay.resources.Texture;
import clay.resources.VideoResource;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;


@:access(clay.render.Renderer)
class Shader {


	static var ID:Int = 0;

	public var id(default,null):Int;
	public var uniforms(default,null):Uniforms;
	public var pipeline(default,null):PipelineState;

	@:noCompletion public var _blendSrcDefault:BlendFactor;
	@:noCompletion public var _blendDstDefault:BlendFactor;
	@:noCompletion public var _blendOpDefault:BlendOperation;

	@:noCompletion public var _alphaBlendDstDefault:BlendFactor;
	@:noCompletion public var _alphaBlendSrcDefault:BlendFactor;
	@:noCompletion public var _alphaBlendOpDefault:BlendOperation;


	public function new(inputLayout:Array<VertexStructure>, vertexShader:VertexShader, fragmentShader:FragmentShader) {

		id = Shader.ID++;

		if(id > Clay.renderer.sortOptions.shaderMax) {
			throw('Error: to many shaders, max: ${Clay.renderer.sortOptions.shaderMax}');
		}

		pipeline = new PipelineState();

		pipeline.inputLayout = inputLayout;
		pipeline.vertexShader = vertexShader;
		pipeline.fragmentShader = fragmentShader;

		uniforms = new Uniforms(pipeline);

	}

	public function use(g:Graphics) {

		g.setPipeline(pipeline);

	}

	public function apply(g:Graphics) {

		uniforms.apply(g);

	}

	public function setBlending(blendSrc:BlendFactor, blendDst:BlendFactor, ?blendOp:BlendOperation, ?alphaBlendSrc:BlendFactor, ?alphaBlendDst:BlendFactor, ?alphaBlendOp:BlendOperation) {
		
		pipeline.blendSource = blendSrc;
		pipeline.blendDestination = blendDst;
		pipeline.blendOperation = blendOp != null ? blendOp : BlendOperation.Add;	

		pipeline.alphaBlendSource = alphaBlendSrc != null ? alphaBlendSrc : blendSrc;
		pipeline.alphaBlendDestination = alphaBlendDst != null ? alphaBlendDst : blendDst;
		pipeline.alphaBlendOperation = alphaBlendOp != null ? alphaBlendOp : blendOp;	
		
	}

	public function setBool(name:String, value:Bool)               return uniforms.setBool(name, value);
	public function setInt(name:String, value:Int)                 return uniforms.setInt(name, value);
	public function setFloat(name:String, value:FastFloat)         return uniforms.setFloat(name, value);
	public function setFloat2(name:String, value:Array<FastFloat>) return uniforms.setFloat2(name, value);
	public function setFloat3(name:String, value:Array<FastFloat>) return uniforms.setFloat3(name, value);
	public function setFloat4(name:String, value:Array<FastFloat>) return uniforms.setFloat4(name, value);
	public function setFloats(name:String, value:Float32Array)     return uniforms.setFloats(name, value);
	public function setVector2(name:String, value:FastVector2)     return uniforms.setVector2(name, value);
	public function setVector3(name:String, value:FastVector3)     return uniforms.setVector3(name, value);
	public function setVector4(name:String, value:FastVector4)     return uniforms.setVector4(name, value);
	public function setMatrix3(name:String, value:FastMatrix3)     return uniforms.setMatrix3(name, value);
	public function setMatrix4(name:String, value:FastMatrix4)     return uniforms.setMatrix4(name, value);
	public function setTexture(name:String, value:Texture)         return uniforms.setTexture(name, value);
	public function setVideo(name:String, value:VideoResource)     return uniforms.setVideo(name, value);


	public function compile() {
		
		pipeline.compile();

		_blendSrcDefault = pipeline.blendSource;
		_blendDstDefault = pipeline.blendDestination;
		_blendOpDefault = pipeline.blendOperation;

		_alphaBlendSrcDefault = pipeline.alphaBlendSource;
		_alphaBlendDstDefault = pipeline.alphaBlendDestination;
		_alphaBlendOpDefault = pipeline.alphaBlendOperation;

	}

	public function resetBlending() {
		
		pipeline.blendSource = _blendSrcDefault;
		pipeline.blendDestination = _blendDstDefault;
		pipeline.blendOperation = _blendOpDefault;	

		pipeline.alphaBlendSource = _alphaBlendSrcDefault;
		pipeline.alphaBlendDestination = _alphaBlendDstDefault;
		pipeline.alphaBlendOperation = _alphaBlendOpDefault;	
		
	}


}


