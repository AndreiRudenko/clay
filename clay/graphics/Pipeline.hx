package clay.graphics;


import kha.graphics4.Graphics;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexShader;
import kha.graphics4.FragmentShader;
import kha.FastFloat;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.arrays.Float32Array;

import clay.graphics.Texture;
import clay.graphics.Video;
import clay.graphics.VertexBuffer;
import clay.graphics.VertexStructure;
import clay.graphics.Uniforms;

typedef BlendFactor = kha.graphics4.BlendingFactor;
typedef BlendOperation = kha.graphics4.BlendingOperation;

class Pipeline {

	static var ID:Int = 0;

	public var id(default,null):Int;
	public var uniforms(default,null):Uniforms;
	public var inputLayout(get, never):Array<VertexStructure>;
	public var vertexShader(default, null):VertexShader;
	public var fragmentShader(default, null):FragmentShader;
	var _pipeline:PipelineState;
	var _textureParameters:TextureParameters;

	public function new(inputLayout:Array<VertexStructure>, vertexShader:VertexShader, fragmentShader:FragmentShader) {
		id = Pipeline.ID++; // TODO: use smart generated ids

		_pipeline = new PipelineState();
		_textureParameters = new TextureParameters();

		this.vertexShader = vertexShader;
		this.fragmentShader = fragmentShader;

		_pipeline.inputLayout = inputLayout;
		_pipeline.vertexShader = vertexShader;
		_pipeline.fragmentShader = fragmentShader;

		uniforms = new Uniforms(_pipeline);
	}

	public function use(g:Graphics) {
		g.setPipeline(_pipeline);
	}

	public function apply(g:Graphics) {
		uniforms.apply(g);
	}

	public function clone():Pipeline {
		var p = new Pipeline(inputLayout, vertexShader, fragmentShader);
		p.setBlending(
			_pipeline.blendSource,
			_pipeline.blendDestination,
			_pipeline.blendOperation,
			_pipeline.alphaBlendSource,
			_pipeline.alphaBlendDestination,
			_pipeline.alphaBlendOperation
		);
		return p;
	}

	public function setBlending(
		blendSrc:BlendFactor, blendDst:BlendFactor, ?blendOp:BlendOperation, 
		?alphaBlendSrc:BlendFactor, ?alphaBlendDst:BlendFactor, ?alphaBlendOp:BlendOperation
	) {
		_pipeline.blendSource = blendSrc;
		_pipeline.blendDestination = blendDst;
		_pipeline.blendOperation = blendOp != null ? blendOp : BlendOperation.Add;	

		_pipeline.alphaBlendSource = alphaBlendSrc != null ? alphaBlendSrc : blendSrc;
		_pipeline.alphaBlendDestination = alphaBlendDst != null ? alphaBlendDst : blendDst;
		_pipeline.alphaBlendOperation = alphaBlendOp != null ? alphaBlendOp : blendOp;	
	}

	public function setBool(name:String, value:Bool) return uniforms.setBool(name, value);
	public function setInt(name:String, value:Int) return uniforms.setInt(name, value);
	public function setFloat(name:String, value:FastFloat) return uniforms.setFloat(name, value);
	public function setFloat2(name:String, value:Array<FastFloat>) return uniforms.setFloat2(name, value);
	public function setFloat3(name:String, value:Array<FastFloat>) return uniforms.setFloat3(name, value);
	public function setFloat4(name:String, value:Array<FastFloat>) return uniforms.setFloat4(name, value);
	public function setFloats(name:String, value:Float32Array) return uniforms.setFloats(name, value);
	public function setVector2(name:String, value:FastVector2) return uniforms.setVector2(name, value);
	public function setVector3(name:String, value:FastVector3) return uniforms.setVector3(name, value);
	public function setVector4(name:String, value:FastVector4) return uniforms.setVector4(name, value);
	public function setMatrix3(name:String, value:FastMatrix3) return uniforms.setMatrix3(name, value);
	public function setMatrix4(name:String, value:FastMatrix4) return uniforms.setMatrix4(name, value);
	public function setTexture(name:String, value:Texture) return uniforms.setTexture(name, value);
	public function setTextureParameters(
		name:String, 
		uAddressing:TextureAddressing, vAddressing:TextureAddressing, 
		filterMin:TextureFilter, filterMag:TextureFilter, 
		mipmapFilter:MipMapFilter
	) {
		_textureParameters.uAddressing = uAddressing;
		_textureParameters.vAddressing = vAddressing;
		_textureParameters.filterMin = filterMin;
		_textureParameters.filterMag = filterMag;
		_textureParameters.mipmapFilter = mipmapFilter;
		return uniforms.setTextureParameters(name, _textureParameters);
	}

	public function setVideo(name:String, value:Video) return uniforms.setVideo(name, value);

	public function compile() {
		_pipeline.compile();
	}

	public function destroy() {
		_pipeline.delete();
		uniforms = null;
		_pipeline = null;
	}

	function get_inputLayout() {
		return _pipeline.inputLayout;
	}

}
