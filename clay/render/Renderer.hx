package clay.render;


import kha.Framebuffer;
import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.Graphics;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;

import clay.render.Camera;
import clay.resources.Texture;
import clay.resources.FontResource;
import clay.render.Layer;
import clay.render.SortKey;
import clay.render.Color;
import clay.utils.Bits;
import clay.utils.Log.*;
import clay.ds.IntRingBuffer;


@:allow(clay.system.App)
class Renderer {


	@:noCompletion public var batchSize   (default, null):Int = 8192; // 8192 // 16384 // 32768 // 65535
	@:noCompletion public var sortOptions (default, null):SortOptions;

	public var rendering        (default, null):Bool = false;

	public var target           (default, set):Texture;

	public var painter 	  	    (default, null):Painter;
	public var frontbuffer	  	(default, null):FrontBuffer;

	public var cameras	        (default, null):CameraManager;
	public var layers 	        (default, null):LayerManager;
	public var shaders    	  	(default, null):Map<String, Shader>;

	public var shaderTextured	(default, null):Shader;
	public var shaderText    	(default, null):Shader;

	public var camera:Camera;
	public var layer:Layer;
	public var font:FontResource;
	public var clearColor:Color;

	#if !no_debug_console
	public var stats:RenderStats;
	#end
	
	var _textureIds:IntRingBuffer;
	var _texturesUsed:Int = 0;


	public function new(_options:RendererOptions) {

		if(_options.batchSize != null) {
			batchSize = _options.batchSize;
		}

		var layersMax = def(_options.layersMax, 64);

		sortOptions = new SortOptions(_options.shaderBits, _options.textureBits);
		cameras = new CameraManager();
		layers = new LayerManager(layersMax);
		clearColor = new Color(0.1,0.1,0.1,1);
		shaders = new Map();
		_textureIds = new IntRingBuffer(sortOptions.textureMax+1);

	}

	public function update(dt:Float) {

		layers.update(dt);
		
	}

	public function process(f:Framebuffer) {

		rendering = true;

		#if !no_debug_console
		stats.reset();
		#end

		var buffer = Clay.screen.buffer.image.g4;
	    buffer.begin();
		buffer.clear(clearColor.toInt());

		for (cam in cameras.activeCameras) {
			cam.preRender();
			layers.render(cam);
			cam.postRender();
		}

		// buffer.disableScissor();
	    buffer.end();

		var g = f.g4;
		g.begin();
		// g.clear();
		g.scissor(0, 0, Clay.screen.width, Clay.screen.height);
		frontbuffer.render(Clay.screen.buffer, f, shaderTextured, kha.ScreenRotation.RotationNone); // todo: kha.System.screenRotation
		g.disableScissor();
		g.end();

		rendering = false;

	}

	public function registerShader(_name:String, _shader:Shader) {

		if(shaders.exists(_name)) {
			log("shader: " + _name + " already exists, this will overwrite to new shader");
		}

		shaders.set(_name, _shader);
		
	}

	@:noCompletion public function popTextureID():Int {

		if(_texturesUsed >= sortOptions.textureMax) {
			throw("Out of textures, max allowed " + sortOptions.textureMax);
		}

		++_texturesUsed;
		return _textureIds.pop();

	}

	@:noCompletion public function pushTextureID(_id:Int) {

		--_texturesUsed;
		_textureIds.push(_id);

	}

	function init() {

		createDefaultShaders();

		layer = layers.create("defaultLayer");
		camera = cameras.create("defaultCamera");

		frontbuffer = new FrontBuffer(this);
		painter = new Painter(this, batchSize);
		
		#if !no_default_font
		font = Clay.resources.font("assets/Muli-Regular.ttf");
		#end

		#if !no_debug_console
		stats = new RenderStats();
		#end

	}

	function destroy() {}

	function createDefaultShaders() {

		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		structure.add("texPosition", VertexData.Float2);

	// textured
		shaderTextured = new Shader([structure], Shaders.textured_vert, Shaders.textured_frag);
		shaderTextured.setBlendMode(BlendingFactor.BlendOne, BlendingFactor.InverseSourceAlpha, BlendingOperation.Add);
		shaderTextured.compile();
		registerShader("textured", shaderTextured);

	// text
		shaderText = new Shader([structure], Shaders.textured_vert, Shaders.text_frag);
		shaderText.setBlendMode(BlendingFactor.SourceAlpha, BlendingFactor.InverseSourceAlpha, BlendingOperation.Add);
		shaderText.compile();
		registerShader("text", shaderText);

	}

	function set_target(v:Texture):Texture {

		if(rendering) {
			if(target != null) {
				target.image.g4.end();
			}
			if(v != null) {
				v.image.g4.begin();
				v.image.g4.clear(clearColor.toInt());
			} else {
				Clay.screen.buffer.image.g4.begin();
				Clay.screen.buffer.image.g4.clear(clearColor.toInt());
			}
		}

		target = v;

		return target;
		
	}


}

typedef RendererOptions = {

	@:optional var shaderBits:Int;
	@:optional var textureBits:Int;
	@:optional var layersMax:Int;
	@:optional var batchSize:Int;

}