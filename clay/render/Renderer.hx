package clay.render;


import kha.Framebuffer;
import kha.Scaler;
import kha.Shaders;
// import kha.ScreenRotation;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.graphics4.Graphics;
import kha.graphics4.BlendingFactor;

import clay.components.misc.Camera;
import clay.components.graphics.Geometry;
import clay.components.graphics.Texture;
import clay.resources.FontResource;
import clay.data.Color;
import clay.utils.Bits;
import clay.utils.Log.*;
import clay.ds.Int32RingBuffer;


@:allow(clay.Engine)
class Renderer {


	public static var buffer_size(default, null):Int = 128;

	public var layers:LayerManager;
	public var clear_color:Color;
	
	public var target(default, set):Texture;
	public var rendering(default, null):Bool = false;

	public var cameras:CameraManager;

	public var shader_colored:Shader;
	public var shader_textured:Shader;
	public var shader_text:Shader;
	public var shader_instanced:Shader;
	public var shader_instanced_textured:Shader;

	var renderpath:RenderPath;

	// geometry sorting
	var geomtype_bits:Int;
	var texture_bits:Int;
	var shader_bits:Int;
	var depth_bits:Int;

	var geomtype_offset:Int;
	var texture_offset:Int;
	var shader_offset:Int;
	var depth_offset:Int;

	var geomtype_max:Int;
	var texture_max:Int;
	var shader_max:Int;
	var depth_max:Int;

	var layers_max:Int;

	var _texture_ids:Int32RingBuffer;
	var _textures_used:Int = 0;


	public function new(_options:RendererOptions) {

		depth_bits = def(_options.depth_bits, 8);
		shader_bits = def(_options.shader_bits, 9);
		texture_bits = def(_options.texture_bits, 12);
		geomtype_bits = def(_options.geomtype_bits, 2);

		layers_max = def(_options.layers_max, 64);

		geomtype_offset = 0;
		texture_offset = geomtype_bits;
		shader_offset = geomtype_bits + texture_bits;
		depth_offset = geomtype_bits + texture_bits + shader_bits;

		geomtype_max = Bits.count_singed(geomtype_bits);
		texture_max = Bits.count_singed(texture_bits);
		shader_max = Bits.count_singed(shader_bits);
		depth_max = Bits.count_singed(depth_bits);

		cameras = new CameraManager();

		layers = new LayerManager();
		clear_color = new Color(0.1,0.1,0.1,1);
		// clear_color = new Color(0,0,0,1);

		_texture_ids = new Int32RingBuffer(texture_max+1);

	}

	function init() {

		target = Clay.screen.buffer;
		create_default_shaders();
		layers.create();
		renderpath = new RenderPath(this);

	}

	function create_default_shaders() {

		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);

		shader_colored = new Shader();
		shader_colored.inputLayout = [structure];
		shader_colored.vertexShader = Shaders.colored_vert;
		shader_colored.fragmentShader = Shaders.colored_frag;
		shader_colored.blendSource = BlendingFactor.SourceAlpha;
		shader_colored.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_colored.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_colored.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_colored.compile();

		structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);

		shader_textured = new Shader();
		shader_textured.inputLayout = [structure];
		shader_textured.vertexShader = Shaders.textured_vert;
		shader_textured.fragmentShader = Shaders.textured_frag;
		shader_textured.blendSource = BlendingFactor.SourceAlpha;
		shader_textured.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_textured.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_textured.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_textured.compile();

		shader_text = new Shader();
		shader_text.inputLayout = [structure];
		shader_text.vertexShader = Shaders.text_vert;
		shader_text.fragmentShader = Shaders.text_frag;
		shader_text.blendSource = BlendingFactor.SourceAlpha;
		shader_text.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_text.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_text.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_text.compile();

		var structures = new Array<VertexStructure>();
		structures[0] = new VertexStructure();
		structures[0].add("vertexPosition", VertexData.Float2);
		structures[1] = new VertexStructure();
		structures[1].add("m", VertexData.Float4x4);
		structures[1].add("vertexColor", VertexData.Float4);
		structures[1].instanced = true;

		shader_instanced = new Shader();
		shader_instanced.inputLayout = structures;
		shader_instanced.vertexShader = Shaders.coloredinst_vert;
		shader_instanced.fragmentShader = Shaders.colored_frag;
		shader_instanced.blendSource = BlendingFactor.SourceAlpha;
		shader_instanced.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_instanced.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_instanced.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_instanced.compile();

		structures = new Array<VertexStructure>();
		structures[0] = new VertexStructure();
		structures[0].add("vertexPosition", VertexData.Float2);
		structures[0].add("texPosition", VertexData.Float2);
		structures[1] = new VertexStructure();
		structures[1].add("m", VertexData.Float4x4);
		structures[1].add("vertexColor", VertexData.Float4);
		structures[1].add("texOffset", VertexData.Float2);
		structures[1].instanced = true;

		shader_instanced_textured = new Shader();
		shader_instanced_textured.inputLayout = structures;
		shader_instanced_textured.vertexShader = Shaders.texturedinst_vert;
		shader_instanced_textured.fragmentShader = Shaders.textured_frag;
		shader_instanced_textured.blendSource = BlendingFactor.SourceAlpha;
		shader_instanced_textured.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_instanced_textured.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_instanced_textured.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_instanced_textured.compile();

	}

	function destroy() {
		
	}

	function set_target(v:Texture):Texture {

		if(v == null) {
			v = Clay.screen.buffer;
		}

		if(rendering) {
			if(target != null) {
				target.image.g4.end();
			}

			v.image.g4.begin();
			v.image.g4.clear(clear_color.to_int());
		}

		target = v;

		return target;
		
	}

	@:noCompletion public function pop_texture_id():Int {

		if(_textures_used >= texture_max) {
			throw('Out of textures, max allowed ${texture_max}');
		}

		++_textures_used;
		return _texture_ids.pop();

	}

	@:noCompletion public function push_texture_id(_id:Int) {

		--_textures_used;
		_texture_ids.push(_id);

	}

	public function update(dt:Float) {
		
		for (cam in cameras) {
			if(cam.active) {
				cam.update();
			}
		}

	}

	public function process(f:Framebuffer) {

		rendering = true;

	    target.image.g4.begin();
		target.image.g4.clear(clear_color.to_int());

		for (cam in cameras) {
			if(cam.active) {
		    	cam.prerender(target.image.g4);
				layers.render(target.image.g4, cam);
		    	cam.postrender(target.image.g4);
			}
		}

		target.image.g4.end();

		f.g2.begin();
		// set shader here
		// frame.g2.pipeline = postfx;
		Scaler.scale(target.image, f, kha.System.screenRotation);
		f.g2.end();

		rendering = false;

	}


}

typedef RendererOptions = {

	@:optional var depth_bits:Int;
	@:optional var shader_bits:Int;
	@:optional var texture_bits:Int;
	@:optional var geomtype_bits:Int;
	@:optional var layers_max:Int;

}