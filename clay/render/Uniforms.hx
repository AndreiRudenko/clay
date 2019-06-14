package clay.render;


import kha.arrays.Float32Array;
import kha.Color;
import kha.FastFloat;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.Video;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.Graphics;
import clay.resources.Texture;
import clay.resources.VideoResource;


class Uniforms {


	var pipeline:PipelineState;

	var bool_map    	     :Map<String, Uniform<Bool,ConstantLocation>>;
	var int_map     	     :Map<String, Uniform<Int,ConstantLocation>>;
	var float_map   	     :Map<String, Uniform<FastFloat,ConstantLocation>>;
	var float2_map  	     :Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var float3_map  	     :Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var float4_map  	     :Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var floats_map  	     :Map<String, Uniform<Float32Array,ConstantLocation>>;
	var vector2_map 	     :Map<String, Uniform<FastVector2,ConstantLocation>>;
	var vector3_map 	     :Map<String, Uniform<FastVector3,ConstantLocation>>;
	var vector4_map 	     :Map<String, Uniform<FastVector4,ConstantLocation>>;
	var matrix4_map  	     :Map<String, Uniform<FastMatrix4,ConstantLocation>>;
	var matrix3_map 	     :Map<String, Uniform<FastMatrix3,ConstantLocation>>;

	var texture_map 	     :Map<String, Uniform<Texture,TextureUnit>>;
	var video_map 	         :Map<String, Uniform<VideoResource,TextureUnit>>;

	var dirty_bool    	     :Array<Uniform<Bool,ConstantLocation>>;
	var dirty_int     	     :Array<Uniform<Int,ConstantLocation>>;
	var dirty_float   	     :Array<Uniform<FastFloat,ConstantLocation>>;
	var dirty_float2  	     :Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirty_float3  	     :Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirty_float4  	     :Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirty_floats  	     :Array<Uniform<Float32Array,ConstantLocation>>;
	var dirty_vector2 	     :Array<Uniform<FastVector2,ConstantLocation>>;
	var dirty_vector3 	     :Array<Uniform<FastVector3,ConstantLocation>>;
	var dirty_vector4 	     :Array<Uniform<FastVector4,ConstantLocation>>;
	var dirty_matrix3 	     :Array<Uniform<FastMatrix3,ConstantLocation>>;
	var dirty_matrix4  	     :Array<Uniform<FastMatrix4,ConstantLocation>>;

	var dirty_texture 	     :Array<Uniform<Texture,TextureUnit>>;
	var dirty_video          :Array<Uniform<VideoResource,TextureUnit>>;


	public function new(pipeline:PipelineState) {

		this.pipeline = pipeline;

		clear();
		
	}

	public function clear() {

		bool_map = new Map();
		int_map = new Map();
		float_map = new Map();
		float2_map = new Map();
		float3_map = new Map();
		float4_map = new Map();
		floats_map = new Map();
		vector2_map = new Map();
		vector3_map = new Map();
		vector4_map = new Map();
		matrix3_map = new Map();
		matrix4_map = new Map();
		texture_map = new Map();
		video_map = new Map();

		dirty_bool = [];
		dirty_int = [];
		dirty_float = [];
		dirty_float2 = [];
		dirty_float3 = [];
		dirty_float4 = [];
		dirty_floats = [];
		dirty_vector2 = [];
		dirty_vector3 = [];
		dirty_vector4 = [];
		dirty_matrix3 = [];
		dirty_matrix4 = [];
		dirty_texture = [];
		dirty_video = [];

	}
	
	public inline function set_bool(name:String, value:Bool) {

		var bool = bool_map.get(name);

		if(bool != null) {
			bool.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			bool = new Uniform<Bool, ConstantLocation>(value, location);
			bool_map.set(name, bool);
		}

		dirty_bool.push(bool);

		return bool;

	}

	public inline function set_int(name:String, value:Int) {

		var int = int_map.get(name);

		if(int != null) {
			int.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			int = new Uniform<Int, ConstantLocation>(value, location);
			int_map.set(name, int);
		}

		dirty_int.push(int);

		return int;

	}

	public inline function set_float(name:String, value:FastFloat) {

		var float = float_map.get(name);

		if(float != null) {
			float.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float = new Uniform<FastFloat, ConstantLocation>(value, location);
			float_map.set(name, float);
		}

		dirty_float.push(float);

		return float;

	}

	public inline function set_float2(name:String, value:Array<FastFloat>) {

		var float2 = float2_map.get(name);

		if(float2 != null) {
			float2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float2 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float2_map.set(name, float2);
		}

		dirty_float2.push(float2);

		return float2;

	}

	public inline function set_float3(name:String, value:Array<FastFloat>) {

		var float3 = float3_map.get(name);

		if(float3 != null) {
			float3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float3 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float3_map.set(name, float3);
		}

		dirty_float3.push(float3);

		return float3;

	}

	public inline function set_float4(name:String, value:Array<FastFloat>) {

		var float4 = float4_map.get(name);

		if(float4 != null) {
			float4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float4 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float4_map.set(name, float4);
		}

		dirty_float4.push(float4);

		return float4;

	}

	public inline function set_floats(name:String, value:Float32Array) {

		var floats = floats_map.get(name);

		if(floats != null) {
			floats.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			floats = new Uniform<Float32Array, ConstantLocation>(value, location);
			floats_map.set(name, floats);
		}

		dirty_floats.push(floats);

		return floats;

	}

	public inline function set_vector2(name:String, value:FastVector2) {

		var vector2 = vector2_map.get(name);

		if(vector2 != null) {
			vector2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector2 = new Uniform<FastVector2, ConstantLocation>(value, location);
			vector2_map.set(name, vector2);
		}

		dirty_vector2.push(vector2);

		return vector2;

	}

	public inline function set_vector3(name:String, value:FastVector3) {

		var vector3 = vector3_map.get(name);

		if(vector3 != null) {
			vector3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector3 = new Uniform<FastVector3, ConstantLocation>(value, location);
			vector3_map.set(name, vector3);
		}

		dirty_vector3.push(vector3);

		return vector3;

	}

	public inline function set_vector4(name:String, value:FastVector4) {

		var vector4 = vector4_map.get(name);

		if(vector4 != null) {
			vector4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector4 = new Uniform<FastVector4, ConstantLocation>(value, location);
			vector4_map.set(name, vector4);
		}

		dirty_vector4.push(vector4);

		return vector4;

	}

	public inline function set_matrix3(name:String, value:FastMatrix3) {

		var matrix3 = matrix3_map.get(name);

		if(matrix3 != null) {
			matrix3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix3 = new Uniform<FastMatrix3, ConstantLocation>(value, location);
			matrix3_map.set(name, matrix3);
		}

		dirty_matrix3.push(matrix3);

		return matrix3;

	}

	public inline function set_matrix4(name:String, value:FastMatrix4) {

		var matrix4 = matrix4_map.get(name);

		if(matrix4 != null) {
			matrix4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix4 = new Uniform<FastMatrix4, ConstantLocation>(value, location);
			matrix4_map.set(name, matrix4);
		}

		dirty_matrix4.push(matrix4);

		return matrix4;

	}

	public inline function set_texture(name:String, value:Texture) {

		var texture = texture_map.get(name);

		if(texture != null) {
			texture.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			texture = new Uniform<Texture, TextureUnit>(value, location);
			texture_map.set(name, texture);
		}

		dirty_texture.push(texture);

		return texture;

	}

	public inline function set_video(name:String, value:VideoResource) {

		var video = video_map.get(name);

		if(video != null) {
			video.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			video = new Uniform<VideoResource, TextureUnit>(value, location);
			video_map.set(name, video);
		}

		dirty_video.push(video);
		
		return video;

	}

	public inline function apply(g:Graphics) {

		while(dirty_bool.length > 0) {
			var uf = dirty_bool.pop();
			g.setBool(uf.location, uf.value);
		}
		
		while(dirty_int.length > 0) {
			var uf = dirty_int.pop();
			g.setInt(uf.location, uf.value);
		}
		
		while(dirty_float.length > 0) {
			var uf = dirty_float.pop();
			g.setFloat(uf.location, uf.value);
		}
		
		while(dirty_float2.length > 0) {
			var uf = dirty_float2.pop();
			g.setFloat2(uf.location, uf.value[0], uf.value[1]);
		}
		
		while(dirty_float3.length > 0) {
			var uf = dirty_float3.pop();
			g.setFloat3(uf.location, uf.value[0], uf.value[1], uf.value[2]);
		}
		
		while(dirty_float4.length > 0) {
			var uf = dirty_float4.pop();
			g.setFloat4(uf.location, uf.value[0], uf.value[1], uf.value[2], uf.value[3]);
		}

		while(dirty_floats.length > 0) {
			var uf = dirty_floats.pop();
			g.setFloats(uf.location, uf.value);
		}

		while(dirty_vector2.length > 0) {
			var uf = dirty_vector2.pop();
			g.setVector2(uf.location, uf.value);
		}

		while(dirty_vector3.length > 0) {
			var uf = dirty_vector3.pop();
			g.setVector3(uf.location, uf.value);
		}

		while(dirty_vector4.length > 0) {
			var uf = dirty_vector4.pop();
			g.setVector4(uf.location, uf.value);
		}

		while(dirty_matrix3.length > 0) {
			var uf = dirty_matrix3.pop();
			g.setMatrix3(uf.location, uf.value);
		}

		while(dirty_matrix4.length > 0) {
			var uf = dirty_matrix4.pop();
			g.setMatrix(uf.location, uf.value);
		}

		while(dirty_texture.length > 0) {
			var uf = dirty_texture.pop();
			g.setTexture(uf.location, uf.value.image);
			g.setTextureParameters(uf.location, uf.value.u_addressing, uf.value.v_addressing, uf.value.filter_min, uf.value.filter_mag, uf.value.mipmap_filter);
		}

		while(dirty_video.length > 0) {
			var uf = dirty_video.pop();
			g.setVideoTexture(uf.location, uf.value.video);
		}

	}


}

@:generic
private class Uniform<T, T1> {

	public var value : T;
	public var location : T1;

	inline public function new(value:T, location:T1) {

		this.value = value;
		this.location = location;

	}

}
