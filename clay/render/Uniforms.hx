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

	var boolMap:Map<String, Uniform<Bool,ConstantLocation>>;
	var intMap:Map<String, Uniform<Int,ConstantLocation>>;
	var floatMap:Map<String, Uniform<FastFloat,ConstantLocation>>;
	var float2Map:Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var float3Map:Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var float4Map:Map<String, Uniform<Array<FastFloat>,ConstantLocation>>;
	var floatsMap:Map<String, Uniform<Float32Array,ConstantLocation>>;
	var vector2Map:Map<String, Uniform<FastVector2,ConstantLocation>>;
	var vector3Map:Map<String, Uniform<FastVector3,ConstantLocation>>;
	var vector4Map:Map<String, Uniform<FastVector4,ConstantLocation>>;
	var matrix4Map:Map<String, Uniform<FastMatrix4,ConstantLocation>>;
	var matrix3Map:Map<String, Uniform<FastMatrix3,ConstantLocation>>;

	var textureMap:Map<String, Uniform<Texture,TextureUnit>>;
	var videoMap:Map<String, Uniform<VideoResource,TextureUnit>>;

	var dirtyBool:Array<Uniform<Bool,ConstantLocation>>;
	var dirtyInt:Array<Uniform<Int,ConstantLocation>>;
	var dirtyFloat:Array<Uniform<FastFloat,ConstantLocation>>;
	var dirtyFloat2:Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirtyFloat3:Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirtyFloat4:Array<Uniform<Array<FastFloat>,ConstantLocation>>;
	var dirtyFloats:Array<Uniform<Float32Array,ConstantLocation>>;
	var dirtyVector2:Array<Uniform<FastVector2,ConstantLocation>>;
	var dirtyVector3:Array<Uniform<FastVector3,ConstantLocation>>;
	var dirtyVector4:Array<Uniform<FastVector4,ConstantLocation>>;
	var dirtyMatrix3:Array<Uniform<FastMatrix3,ConstantLocation>>;
	var dirtyMatrix4:Array<Uniform<FastMatrix4,ConstantLocation>>;

	var dirtyTexture:Array<Uniform<Texture,TextureUnit>>;
	var dirtyVideo:Array<Uniform<VideoResource,TextureUnit>>;


	public function new(pipeline:PipelineState) {

		this.pipeline = pipeline;

		clear();
		
	}

	public function clear() {

		boolMap = new Map();
		intMap = new Map();
		floatMap = new Map();
		float2Map = new Map();
		float3Map = new Map();
		float4Map = new Map();
		floatsMap = new Map();
		vector2Map = new Map();
		vector3Map = new Map();
		vector4Map = new Map();
		matrix3Map = new Map();
		matrix4Map = new Map();
		textureMap = new Map();
		videoMap = new Map();

		dirtyBool = [];
		dirtyInt = [];
		dirtyFloat = [];
		dirtyFloat2 = [];
		dirtyFloat3 = [];
		dirtyFloat4 = [];
		dirtyFloats = [];
		dirtyVector2 = [];
		dirtyVector3 = [];
		dirtyVector4 = [];
		dirtyMatrix3 = [];
		dirtyMatrix4 = [];
		dirtyTexture = [];
		dirtyVideo = [];

	}
	
	public inline function setBool(name:String, value:Bool) {

		var bool = boolMap.get(name);

		if(bool != null) {
			bool.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			bool = new Uniform<Bool, ConstantLocation>(value, location);
			boolMap.set(name, bool);
		}

		dirtyBool.push(bool);

		return bool;

	}

	public inline function setInt(name:String, value:Int) {

		var int = intMap.get(name);

		if(int != null) {
			int.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			int = new Uniform<Int, ConstantLocation>(value, location);
			intMap.set(name, int);
		}

		dirtyInt.push(int);

		return int;

	}

	public inline function setFloat(name:String, value:FastFloat) {

		var float = floatMap.get(name);

		if(float != null) {
			float.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float = new Uniform<FastFloat, ConstantLocation>(value, location);
			floatMap.set(name, float);
		}

		dirtyFloat.push(float);

		return float;

	}

	public inline function setFloat2(name:String, value:Array<FastFloat>) {

		var float2 = float2Map.get(name);

		if(float2 != null) {
			float2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float2 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float2Map.set(name, float2);
		}

		dirtyFloat2.push(float2);

		return float2;

	}

	public inline function setFloat3(name:String, value:Array<FastFloat>) {

		var float3 = float3Map.get(name);

		if(float3 != null) {
			float3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float3 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float3Map.set(name, float3);
		}

		dirtyFloat3.push(float3);

		return float3;

	}

	public inline function setFloat4(name:String, value:Array<FastFloat>) {

		var float4 = float4Map.get(name);

		if(float4 != null) {
			float4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float4 = new Uniform<Array<FastFloat>, ConstantLocation>(value, location);
			float4Map.set(name, float4);
		}

		dirtyFloat4.push(float4);

		return float4;

	}

	public inline function setFloats(name:String, value:Float32Array) {

		var floats = floatsMap.get(name);

		if(floats != null) {
			floats.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			floats = new Uniform<Float32Array, ConstantLocation>(value, location);
			floatsMap.set(name, floats);
		}

		dirtyFloats.push(floats);

		return floats;

	}

	public inline function setVector2(name:String, value:FastVector2) {

		var vector2 = vector2Map.get(name);

		if(vector2 != null) {
			vector2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector2 = new Uniform<FastVector2, ConstantLocation>(value, location);
			vector2Map.set(name, vector2);
		}

		dirtyVector2.push(vector2);

		return vector2;

	}

	public inline function setVector3(name:String, value:FastVector3) {

		var vector3 = vector3Map.get(name);

		if(vector3 != null) {
			vector3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector3 = new Uniform<FastVector3, ConstantLocation>(value, location);
			vector3Map.set(name, vector3);
		}

		dirtyVector3.push(vector3);

		return vector3;

	}

	public inline function setVector4(name:String, value:FastVector4) {

		var vector4 = vector4Map.get(name);

		if(vector4 != null) {
			vector4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector4 = new Uniform<FastVector4, ConstantLocation>(value, location);
			vector4Map.set(name, vector4);
		}

		dirtyVector4.push(vector4);

		return vector4;

	}

	public inline function setMatrix3(name:String, value:FastMatrix3) {

		var matrix3 = matrix3Map.get(name);

		if(matrix3 != null) {
			matrix3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix3 = new Uniform<FastMatrix3, ConstantLocation>(value, location);
			matrix3Map.set(name, matrix3);
		}

		dirtyMatrix3.push(matrix3);

		return matrix3;

	}

	public inline function setMatrix4(name:String, value:FastMatrix4) {

		var matrix4 = matrix4Map.get(name);

		if(matrix4 != null) {
			matrix4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix4 = new Uniform<FastMatrix4, ConstantLocation>(value, location);
			matrix4Map.set(name, matrix4);
		}

		dirtyMatrix4.push(matrix4);

		return matrix4;

	}

	public inline function setTexture(name:String, value:Texture) {

		var texture = textureMap.get(name);

		if(texture != null) {
			texture.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			texture = new Uniform<Texture, TextureUnit>(value, location);
			textureMap.set(name, texture);
		}

		dirtyTexture.push(texture);

		return texture;

	}

	public inline function setVideo(name:String, value:VideoResource) {

		var video = videoMap.get(name);

		if(video != null) {
			video.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			video = new Uniform<VideoResource, TextureUnit>(value, location);
			videoMap.set(name, video);
		}

		dirtyVideo.push(video);
		
		return video;

	}

	public inline function apply(g:Graphics) {

		while(dirtyBool.length > 0) {
			var uf = dirtyBool.pop();
			g.setBool(uf.location, uf.value);
		}
		
		while(dirtyInt.length > 0) {
			var uf = dirtyInt.pop();
			g.setInt(uf.location, uf.value);
		}
		
		while(dirtyFloat.length > 0) {
			var uf = dirtyFloat.pop();
			g.setFloat(uf.location, uf.value);
		}
		
		while(dirtyFloat2.length > 0) {
			var uf = dirtyFloat2.pop();
			g.setFloat2(uf.location, uf.value[0], uf.value[1]);
		}
		
		while(dirtyFloat3.length > 0) {
			var uf = dirtyFloat3.pop();
			g.setFloat3(uf.location, uf.value[0], uf.value[1], uf.value[2]);
		}
		
		while(dirtyFloat4.length > 0) {
			var uf = dirtyFloat4.pop();
			g.setFloat4(uf.location, uf.value[0], uf.value[1], uf.value[2], uf.value[3]);
		}

		while(dirtyFloats.length > 0) {
			var uf = dirtyFloats.pop();
			g.setFloats(uf.location, uf.value);
		}

		while(dirtyVector2.length > 0) {
			var uf = dirtyVector2.pop();
			g.setVector2(uf.location, uf.value);
		}

		while(dirtyVector3.length > 0) {
			var uf = dirtyVector3.pop();
			g.setVector3(uf.location, uf.value);
		}

		while(dirtyVector4.length > 0) {
			var uf = dirtyVector4.pop();
			g.setVector4(uf.location, uf.value);
		}

		while(dirtyMatrix3.length > 0) {
			var uf = dirtyMatrix3.pop();
			g.setMatrix3(uf.location, uf.value);
		}

		while(dirtyMatrix4.length > 0) {
			var uf = dirtyMatrix4.pop();
			g.setMatrix(uf.location, uf.value);
		}

		while(dirtyTexture.length > 0) {
			var uf = dirtyTexture.pop();
			g.setTexture(uf.location, uf.value.image);
			g.setTextureParameters(uf.location, uf.value.uAddressing, uf.value.vAddressing, uf.value.filterMin, uf.value.filterMag, uf.value.mipmapFilter);
		}

		while(dirtyVideo.length > 0) {
			var uf = dirtyVideo.pop();
			g.setVideoTexture(uf.location, uf.value.video);
		}

	}


}

@:generic
private class Uniform<T, T1> {

	public var value:T;
	public var location:T1;

	inline public function new(value:T, location:T1) {

		this.value = value;
		this.location = location;

	}

}
