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
import clay.render.renderers.ObjectRenderer;
import clay.render.Color;
import clay.utils.Bits;
import clay.utils.Log.*;
import clay.ds.IntRingBuffer;


@:allow(clay.system.App)
class Renderer {


	@:noCompletion public var batch_size   (default, null):Int = 8192; // 8192 // 16384 // 32768 // 65535
	@:noCompletion public var sort_options (default, null):SortOptions;

	public var rendering        (default, null):Bool = false;

	public var target           (default, set):Texture;

	public var renderpath 	  	(default, null):RenderPath;
	public var frontbuffer	  	(default, null):FrontBuffer;

	public var cameras	        (default, null):CameraManager;
	public var layers 	        (default, null):LayerManager;
	public var shaders    	  	(default, null):Map<String, Shader>;

	public var shader_textured	(default, null):Shader;
	public var shader_text    	(default, null):Shader;

	public var camera:Camera;
	public var layer:Layer;
	public var font:FontResource;
	public var clear_color:Color;

	#if !no_debug_console
	public var stats:RenderStats;
	#end
	
	var _texture_ids:IntRingBuffer;
	var _textures_used:Int = 0;


	public function new(_options:RendererOptions) {

		if(_options.batch_size != null) {
			batch_size = _options.batch_size;
		}

		var layers_max = def(_options.layers_max, 64);

		sort_options = new SortOptions(_options.shader_bits, _options.texture_bits, _options.geomtype_bits);
		cameras = new CameraManager();
		layers = new LayerManager(layers_max);
		clear_color = new Color(0.1,0.1,0.1,1);
		shaders = new Map();
		_texture_ids = new IntRingBuffer(sort_options.texture_max+1);

	}

	public function update(dt:Float) {

		layers.update(dt);
		
	}

	public function process(f:Framebuffer) {

		rendering = true;

		#if !no_debug_console
		stats.reset();
		#end

	    target.image.g4.begin();
		target.image.g4.clear(clear_color.to_int()); //todo: move to camera?

		for (cam in cameras.active_cameras) {
			cam.update();
		    cam.prerender(target.image.g4);
			layers.render(target.image.g4, cam);
		    cam.postrender(target.image.g4);
		}

		target.image.g4.end();

		frontbuffer.render(target, f, kha.System.screenRotation);

		rendering = false;

	}

	public function register_shader(_name:String, _shader:Shader) {

		if(shaders.exists(_name)) {
			log('shader: $_name already exists, this will overwrite to new shader');
		}

		shaders.set(_name, _shader);
		
	}

	@:noCompletion public function pop_texture_id():Int {

		if(_textures_used >= sort_options.texture_max) {
			throw('Out of textures, max allowed ${sort_options.texture_max}');
		}

		++_textures_used;
		return _texture_ids.pop();

	}

	@:noCompletion public function push_texture_id(_id:Int) {

		--_textures_used;
		_texture_ids.push(_id);

	}

	function init() {

		target = Clay.screen.buffer;

		create_default_shaders();

		layer = layers.create('default_layer');
		camera = cameras.create('default_camera');

		frontbuffer = new FrontBuffer(this);
		renderpath = new RenderPath(this);
		
		#if !no_default_font
		font = Clay.resources.font('assets/Montserrat-Regular.ttf');
		#end

		#if !no_debug_console
		stats = new RenderStats();
		#end

	}

	function destroy() {}

	function create_default_shaders() {

		var structure = new VertexStructure();
		structure.add("vertexPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		structure.add("texPosition", VertexData.Float2);

	// textured
		shader_textured = new Shader([structure], Shaders.textured_vert, Shaders.textured_frag);
		shader_textured.set_blendmode(BlendingFactor.BlendOne, BlendingFactor.InverseSourceAlpha, BlendingOperation.Add);
		shader_textured.compile();
		register_shader('textured', shader_textured);

	// text
		shader_text = new Shader([structure], Shaders.textured_vert, Shaders.text_frag);
		shader_text.set_blendmode(BlendingFactor.SourceAlpha, BlendingFactor.InverseSourceAlpha, BlendingOperation.Add);
		shader_text.compile();
		register_shader('text', shader_text);

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
			v.image.g4.clear(clear_color.to_int()); //todo: move to camera?
		}

		target = v;

		return target;
		
	}


}

typedef RendererOptions = {

	@:optional var shader_bits:Int;
	@:optional var texture_bits:Int;
	@:optional var geomtype_bits:Int;
	@:optional var layers_max:Int;
	@:optional var batch_size:Int;

}