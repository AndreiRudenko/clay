package clay.graphics.render;

import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.PipelineState;
import kha.graphics4.Graphics;

import clay.utils.Float32Array;
import clay.utils.FastFloat;
import clay.math.FastMatrix3;
import clay.math.FastMatrix4;
import clay.math.FastVector2;
import clay.math.FastVector3;
import clay.math.FastVector4;
import clay.graphics.Texture;
import clay.graphics.Video;
import clay.utils.ArrayTools;

class Uniforms {

	var pipeline:PipelineState;

	var boolMap:Map<String, Uniform<Bool, ConstantLocation>>;
	var intMap:Map<String, Uniform<Int, ConstantLocation>>;
	var floatMap:Map<String, Uniform<FastFloat, ConstantLocation>>;
	var float2Map:Map<String, Uniform<Array<FastFloat>, ConstantLocation>>;
	var float3Map:Map<String, Uniform<Array<FastFloat>, ConstantLocation>>;
	var float4Map:Map<String, Uniform<Array<FastFloat>, ConstantLocation>>;
	var floatsMap:Map<String, Uniform<Float32Array, ConstantLocation>>;
	var vector2Map:Map<String, Uniform<FastVector2, ConstantLocation>>;
	var vector3Map:Map<String, Uniform<FastVector3, ConstantLocation>>;
	var vector4Map:Map<String, Uniform<FastVector4, ConstantLocation>>;
	var matrix4Map:Map<String, Uniform<FastMatrix4, ConstantLocation>>;
	var matrix3Map:Map<String, Uniform<FastMatrix3, ConstantLocation>>;

	var textureMap:Map<String, Uniform<Texture,TextureUnit>>;
	var textureParamsMap:Map<String, Uniform<TextureParameters,TextureUnit>>;
	var videoMap:Map<String, Uniform<Video,TextureUnit>>;

	var dirtyUniforms:Array<UniformBase>;

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
		textureParamsMap = new Map();
		videoMap = new Map();

		dirtyUniforms = [];
	}
	
	public inline function setBool(name:String, value:Bool) {
		var bool = boolMap.get(name);

		if(bool != null) {
			bool.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			bool = new UniformBool(value, location);
			boolMap.set(name, bool);
		}

		dirtyUniforms.push(bool);

		return bool;
	}

	public inline function setInt(name:String, value:Int) {
		var int = intMap.get(name);

		if(int != null) {
			int.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			int = new UniformInt(value, location);
			intMap.set(name, int);
		}

		dirtyUniforms.push(int);

		return int;
	}

	public inline function setFloat(name:String, value:FastFloat) {
		var float = floatMap.get(name);

		if(float != null) {
			float.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float = new UniformFloat(value, location);
			floatMap.set(name, float);
		}

		dirtyUniforms.push(float);

		return float;
	}

	public inline function setFloat2(name:String, value:Array<FastFloat>) {
		var float2 = float2Map.get(name);

		if(float2 != null) {
			float2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float2 = new UniformFloat2(value, location);
			float2Map.set(name, float2);
		}

		dirtyUniforms.push(float2);

		return float2;
	}

	public inline function setFloat3(name:String, value:Array<FastFloat>) {
		var float3 = float3Map.get(name);

		if(float3 != null) {
			float3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float3 = new UniformFloat3(value, location);
			float3Map.set(name, float3);
		}

		dirtyUniforms.push(float3);

		return float3;
	}

	public inline function setFloat4(name:String, value:Array<FastFloat>) {
		var float4 = float4Map.get(name);

		if(float4 != null) {
			float4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			float4 = new UniformFloat4(value, location);
			float4Map.set(name, float4);
		}

		dirtyUniforms.push(float4);

		return float4;
	}

	public inline function setFloats(name:String, value:Float32Array) {
		var floats = floatsMap.get(name);

		if(floats != null) {
			floats.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			floats = new UniformFloats(value, location);
			floatsMap.set(name, floats);
		}

		dirtyUniforms.push(floats);

		return floats;
	}

	public inline function setVector2(name:String, value:FastVector2) {
		var vector2 = vector2Map.get(name);

		if(vector2 != null) {
			vector2.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector2 = new UniformVector2(value, location);
			vector2Map.set(name, vector2);
		}

		dirtyUniforms.push(vector2);

		return vector2;
	}

	public inline function setVector3(name:String, value:FastVector3) {
		var vector3 = vector3Map.get(name);

		if(vector3 != null) {
			vector3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector3 = new UniformVector3(value, location);
			vector3Map.set(name, vector3);
		}

		dirtyUniforms.push(vector3);

		return vector3;
	}

	public inline function setVector4(name:String, value:FastVector4) {
		var vector4 = vector4Map.get(name);

		if(vector4 != null) {
			vector4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			vector4 = new UniformVector4(value, location);
			vector4Map.set(name, vector4);
		}

		dirtyUniforms.push(vector4);

		return vector4;
	}

	public inline function setMatrix3(name:String, value:FastMatrix3) {
		var matrix3 = matrix3Map.get(name);

		if(matrix3 != null) {
			matrix3.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix3 = new UniformMatrix3(value, location);
			matrix3Map.set(name, matrix3);
		}

		dirtyUniforms.push(matrix3);

		return matrix3;
	}

	public inline function setMatrix4(name:String, value:FastMatrix4) {
		var matrix4 = matrix4Map.get(name);

		if(matrix4 != null) {
			matrix4.value = value;
		} else {
			var location = pipeline.getConstantLocation(name);
			matrix4 = new UniformMatrix4(value, location);
			matrix4Map.set(name, matrix4);
		}

		dirtyUniforms.push(matrix4);

		return matrix4;
	}

	public inline function setTexture(name:String, value:Texture) {
		var texture = textureMap.get(name);

		if(texture != null) {
			texture.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			texture = new UniformTexture(value, location);
			textureMap.set(name, texture);
		}

		dirtyUniforms.push(texture);

		return texture;
	}

	public inline function setTextureParameters(name:String, value:TextureParameters) {
		var texParams = textureParamsMap.get(name);

		if(texParams != null) {
			texParams.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			texParams = new UniformTextureParameters(value, location);
			textureParamsMap.set(name, texParams);
		}

		dirtyUniforms.push(texParams);

		return texParams;
	}

	public inline function setVideo(name:String, value:Video) {
		var video = videoMap.get(name);

		if(video != null) {
			video.value = value;
		} else {
			var location = pipeline.getTextureUnit(name);
			video = new UniformVideo(value, location);
			videoMap.set(name, video);
		}

		dirtyUniforms.push(video);
		
		return video;
	}

	public inline function apply(g:Graphics) {
		if(dirtyUniforms.length > 0) {
			var i = 0;
			while(i < dirtyUniforms.length) {
				dirtyUniforms[i].commit(g);
				i++;
			}
			ArrayTools.clear(dirtyUniforms);
		}
	}


}

private class UniformBase {

	public function commit(g:Graphics) {}

}

private class Uniform<T, T1> extends UniformBase {

	public var value:T;
	public var location:T1;

	public function new(value:T, location:T1) {
		this.value = value;
		this.location = location;
	}

}

private class UniformBool extends Uniform<Bool, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setBool(location, value);
	}

}

private class UniformInt extends Uniform<Int, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setInt(location, value);
	}

}

private class UniformFloat extends Uniform<FastFloat, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setFloat(location, value);
	}

}

private class UniformFloat2 extends Uniform<Array<FastFloat>, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setFloat2(location, value[0], value[1]);
	}

}

private class UniformFloat3 extends Uniform<Array<FastFloat>, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setFloat3(location, value[0], value[1], value[2]);
	}

}

private class UniformFloat4 extends Uniform<Array<FastFloat>, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setFloat4(location, value[0], value[1], value[2], value[3]);
	}

}


private class UniformFloats extends Uniform<Float32Array, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setFloats(location, value);
	}

}

private class UniformVector2 extends Uniform<FastVector2, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setVector2(location, value);
	}

}

private class UniformVector3 extends Uniform<FastVector3, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setVector3(location, value);
	}

}

private class UniformVector4 extends Uniform<FastVector4, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setVector4(location, value);
	}

}

private class UniformMatrix3 extends Uniform<FastMatrix3, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setMatrix3(location, value);
	}

}

private class UniformMatrix4 extends Uniform<FastMatrix4, ConstantLocation> {

	override function commit(g:Graphics) {
		g.setMatrix(location, value);
	}

}

private class UniformTexture extends Uniform<Texture, TextureUnit> {

	override function commit(g:Graphics) {
		g.setTexture(location, value != null ? value.image : null);
	}

}

private class UniformTextureParameters extends Uniform<TextureParameters, TextureUnit> {

	override function commit(g:Graphics) {
		g.setTextureParameters(location, value.uAddressing, value.vAddressing, value.filterMin, value.filterMag, value.mipmapFilter);
	}

}

private class UniformVideo extends Uniform<Video, TextureUnit> {

	override function commit(g:Graphics) {
		g.setVideoTexture(location, value != null ? value.video : null);
	}

}

class TextureParameters {

	public var uAddressing:TextureAddressing = TextureAddressing.Clamp;
	public var vAddressing:TextureAddressing = TextureAddressing.Clamp;
	public var filterMin:TextureFilter = TextureFilter.LinearFilter;
	public var filterMag:TextureFilter = TextureFilter.LinearFilter;
	public var mipmapFilter:MipMapFilter = MipMapFilter.NoMipFilter;

	public function new() {

	}

}