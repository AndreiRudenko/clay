package clay.render;

import kha.Framebuffer;
import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.Graphics;

import clay.render.Camera;
import clay.resources.Texture;
import clay.resources.FontResource;
import clay.render.Layer;
import clay.render.SortKey;
import clay.utils.Color;
import clay.render.types.BlendFactor;
import clay.render.types.BlendOperation;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.utils.Bits;
import clay.utils.Log.*;
import clay.utils.IntRingBuffer;

@:allow(clay.system.App)
class Renderer {

	@:noCompletion public var batchSize(default, null):Int = 8192; // 8192 // 16384 // 32768 // 65535
	@:noCompletion public var sortOptions(default, null):SortOptions;

	public var rendering(default, null):Bool = false;

	public var target(default, set):Texture;

	public var ctx(default, null):RenderContext;

	public var cameras(default, null):CameraManager;
	public var layers(default, null):Layers;
	public var shaders(default, null):Map<String, Shader>; // TODO: move to resources

	public var shaderTextured(default, null):Shader;
	public var shaderText(default, null):Shader;

	public var camera:Camera;
	public var font:FontResource;
	public var clearColor:Color;

	#if !no_debug_console
	public var stats:RenderStats;
	#end
	
	var _textureIds:IntRingBuffer;
	var _texturesUsed:Int = 0;

	public function new(options:RendererOptions) {
		if(options.batchSize != null) {
			batchSize = options.batchSize;
		}

		sortOptions = new SortOptions(options.shaderBits, options.textureBits);
		cameras = new CameraManager();
		layers = new Layers();
		clearColor = new Color(0.1, 0.1, 0.1, 1);
		shaders = new Map();
		_textureIds = new IntRingBuffer(sortOptions.textureMax+1);
	}

	public function update(dt:Float) {
		layers.update(dt);
	}

	public function process(framebuffer:Framebuffer) {
		rendering = true;

		#if !no_debug_console
		stats.reset();
		#end
		// layers -> cameras
		for (cam in cameras.activeCameras) {
			if(cam.canRender()) {
				cam.preRender(ctx);
				layers.render(ctx, cam);
				cam.postRender(ctx);
				// camera internal buffer -> buffer
				cam.renderBuffer();
			}
		}

		ctx.assertLeftStates();

		// cameras -> screen
		var screen = Clay.screen;
		screen.preRender(ctx);
		for (cam in cameras.activeCameras) {
			screen.render(ctx, cam);
		}
		screen.postRender(ctx);

		ctx.assertLeftStates();

		// screen -> framebuffer
		ctx.drawToCanvas(Clay.screen.buffer, framebuffer, shaderTextured);

		rendering = false;
	}

	public function registerShader(name:String, shader:Shader) {
		if(shaders.exists(name)) {
			log("shader: " + name + " already exists, this will overwrite to new shader");
		}

		shaders.set(name, shader);
	}

	@:noCompletion public function popTextureID():Int {
		if(_texturesUsed >= sortOptions.textureMax) {
			throw("Out of textures, max allowed " + sortOptions.textureMax);
		}

		++_texturesUsed;
		return _textureIds.pop();
	}

	@:noCompletion public function pushTextureID(id:Int) {
		--_texturesUsed;
		_textureIds.push(id);
	}

	function init() {
		createDefaultShaders();

		camera = cameras.create("defaultCamera");

		ctx = new RenderContext(this, batchSize);
		
		#if !no_default_font
		font = Clay.resources.font("Muli-Regular.ttf");
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
		shaderTextured.setBlending(BlendFactor.BlendOne, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		shaderTextured.compile();
		registerShader("textured", shaderTextured);

		// text
		shaderText = new Shader([structure], Shaders.textured_vert, Shaders.text_frag);
		shaderText.setBlending(BlendFactor.SourceAlpha, BlendFactor.InverseSourceAlpha, BlendOperation.Add);
		shaderText.compile();
		registerShader("text", shaderText);
	}

	function set_target(v:Texture):Texture {
		// if(rendering) {
		// 	if(target != null) {
		// 		target.image.g4.end();
		// 	}
			// if(v != null) {
			// 	v.image.g4.begin();
			// 	// v.image.g4.clear(clearColor.toInt());
			// 	v.image.g4.clear(kha.Color.Transparent);
			// } else {
			// 	Clay.screen.buffer.image.g4.begin();
			// 	Clay.screen.buffer.image.g4.clear(clearColor.toInt());
			// }
		// }

		target = v;

		return target;
	}

}

typedef RendererOptions = {

	@:optional var shaderBits:Int;
	@:optional var textureBits:Int;
	@:optional var batchSize:Int;

}