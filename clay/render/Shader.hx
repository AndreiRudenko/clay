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
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;


@:access(clay.render.Renderer)
class Shader {


	static var ID:Int = 0;

	public var id       (default,null):Int;
	public var uniforms (default,null):Uniforms;
	public var pipeline (default,null):PipelineState;

	var _blend_src_default:BlendMode;
	var _blend_dst_default:BlendMode;
	var _blend_op_default:BlendEquation;

	var _alpha_blend_dst_default:BlendMode;
	var _alpha_blend_src_default:BlendMode;
	var _alpha_blend_op_default:BlendEquation;


	public function new(input_layout:Array<VertexStructure>, vertex_shader:VertexShader, fragment_shader:FragmentShader) {

		id = Shader.ID++;

		if(id > Clay.renderer.sort_options.shader_max) {
			throw('Error: to many shaders, max: ${Clay.renderer.sort_options.shader_max}');
		}

		pipeline = new PipelineState();

		pipeline.inputLayout = input_layout;
		pipeline.vertexShader = vertex_shader;
		pipeline.fragmentShader = fragment_shader;

		uniforms = new Uniforms(pipeline);

	}

	public function use(g:Graphics) {

		g.setPipeline(pipeline);

	}

	public function apply(g:Graphics) {

		uniforms.apply(g);

	}

	public function set_blendmode(blend_src:BlendMode, blend_dst:BlendMode, ?blend_op:BlendEquation, ?alpha_blend_src:BlendMode, ?alpha_blend_dst:BlendMode, ?alpha_blend_op:BlendEquation) {
		
		pipeline.blendSource = blend_src;
		pipeline.blendDestination = blend_dst;
		pipeline.blendOperation = blend_op != null ? blend_op : BlendEquation.Add;	

		pipeline.alphaBlendSource = alpha_blend_src != null ? alpha_blend_src : blend_src;
		pipeline.alphaBlendDestination = alpha_blend_dst != null ? alpha_blend_dst : blend_dst;
		pipeline.alphaBlendOperation = alpha_blend_op != null ? alpha_blend_op : blend_op;	

	}

	public function set_bool(name:String, value:Bool)               return uniforms.set_bool(name, value);
	public function set_int(name:String, value:Int)                 return uniforms.set_int(name, value);
	public function set_float(name:String, value:FastFloat)         return uniforms.set_float(name, value);
	public function set_float2(name:String, value:Array<FastFloat>) return uniforms.set_float2(name, value);
	public function set_float3(name:String, value:Array<FastFloat>) return uniforms.set_float3(name, value);
	public function set_float4(name:String, value:Array<FastFloat>) return uniforms.set_float4(name, value);
	public function set_floats(name:String, value:Float32Array)     return uniforms.set_floats(name, value);
	public function set_vector2(name:String, value:FastVector2)     return uniforms.set_vector2(name, value);
	public function set_vector3(name:String, value:FastVector3)     return uniforms.set_vector3(name, value);
	public function set_vector4(name:String, value:FastVector4)     return uniforms.set_vector4(name, value);
	public function set_matrix3(name:String, value:FastMatrix3)     return uniforms.set_matrix3(name, value);
	public function set_matrix4(name:String, value:FastMatrix4)     return uniforms.set_matrix4(name, value);
	public function set_texture(name:String, value:Texture)         return uniforms.set_texture(name, value);
	public function set_video(name:String, value:VideoResource)     return uniforms.set_video(name, value);


	public function compile() {
	    
		pipeline.compile();

		_blend_src_default = pipeline.blendSource;
		_blend_dst_default = pipeline.blendDestination;
		_blend_op_default = pipeline.blendOperation;

		_alpha_blend_src_default = pipeline.alphaBlendSource;
		_alpha_blend_dst_default = pipeline.alphaBlendDestination;
		_alpha_blend_op_default = pipeline.alphaBlendOperation;

	}

	public function reset_blendmodes() {
		
		pipeline.blendSource = _blend_src_default;
		pipeline.blendDestination = _blend_dst_default;
		pipeline.blendOperation = _blend_op_default;	

		pipeline.alphaBlendSource = _alpha_blend_src_default;
		pipeline.alphaBlendDestination = _alpha_blend_dst_default;
		pipeline.alphaBlendOperation = _alpha_blend_op_default;	
		
	}


}


