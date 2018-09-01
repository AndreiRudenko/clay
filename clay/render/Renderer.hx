package clay.render;


import kha.Framebuffer;
import kha.Scaler;
// import kha.ScreenRotation;
import kha.graphics4.Graphics;

import clay.components.Camera;
import clay.components.Geometry;
import clay.components.Texture;
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

	public var default_font:FontResource;
	public var target(default, set):Texture;
	public var rendering(default, null):Bool = false;

	public var cameras:CameraManager;
	var painters:Array<Painter>;

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

		geomtype_bits = def(_options.geomtype_bits, 7);
		texture_bits = def(_options.texture_bits, 9);
		shader_bits = def(_options.shader_bits, 12);
		depth_bits = def(_options.depth_bits, 3);
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
		painters = [];

		layers = new LayerManager();
		clear_color = new Color(0.1,0.1,0.1,1);
		// clear_color = new Color(0,0,0,1);

		_texture_ids = new Int32RingBuffer(texture_max+1);

	}

	function init() {

		target = Clay.screen.buffer;

		layers.create();

		painters[GeometryType.simple] = new SimplePainter();
		painters[GeometryType.text] = new TextPainter();
		painters[GeometryType.quad] = new QuadPainter();

		default_font = Clay.resources.font('assets/Montserrat-Regular.ttf');

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