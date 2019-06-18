package clay.render;



import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.TextureFormat;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;
import kha.Image;

import clay.math.Vector;
import clay.render.Color;
import clay.render.renderers.ObjectRenderer;
import clay.render.renderers.QuadRenderer;
import clay.render.renderers.MeshRenderer;
import clay.render.renderers.QuadPackRenderer;
import clay.render.renderers.ParticlesRenderer;
import clay.render.renderers.StaticRenderer;
import clay.render.Camera;
import clay.render.RenderStats;
import clay.resources.Texture;
import clay.render.Shader;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.utils.Mathf;
import clay.utils.Log.*;

@:allow(
	clay.render.Renderer, 
	clay.render.renderers.ObjectRenderer
)
class RenderPath {


    public var quad_renderer:QuadRenderer;
    public var mesh_renderer:MeshRenderer;
    public var quadpack_renderer:QuadPackRenderer;
    public var particles_renderer:ParticlesRenderer;
    public var static_renderer:StaticRenderer;

    public var texture_blank:Texture;

	public var max_vertices	    (default, null):Int = 0;
	public var max_indices 	    (default, null):Int = 0;

	public var g:Graphics;

	// #if !no_debug_console
	public var stats:RenderStats;
	// #end

	var buffers:Array<VertexBuffer>;

	var renderer:Renderer;
	var current:ObjectRenderer;

    var camera:Camera;
    var layer:Layer;


	public function new(renderer:Renderer) {
		
		this.renderer = renderer;

		max_vertices = renderer.batch_size;
    	var max_quads = Std.int(max_vertices / 4);
    	max_indices = max_quads * 6; // adjusted for quads

    	buffers = [];

    	setup_buffers();
    	setup_default_renderers();

		texture_blank = Texture.create(1, 1, TextureFormat.RGBA32, Usage.StaticUsage, true);
		var pixels = texture_blank.lock();
		pixels.setInt32(0, 0xffffffff);
		texture_blank.unlock();

		#if !no_debug_console
		stats = new RenderStats();
		#end

	}

	@:noCompletion public function init(_layer:Layer, _graphics:Graphics, _camera:Camera) {
		
		g = _graphics;
        camera = _camera;
        layer = _layer;

        current = quad_renderer;

	}

	@:noCompletion public function start() {

		#if !no_debug_console
		stats.reset();
		#end

		current.start();
		
	}

	@:noCompletion public function end() {

		current.end();
		
		#if !no_debug_console
		layer.stats.add(stats);
		#end

	}

	@:noCompletion public function render(objects:Array<DisplayObject>) {

		var r:ObjectRenderer;
		for (o in objects) {
			#if !no_debug_console
			stats.geometry++;
			#end
			if(o.visible && o.renderable) {
				#if !no_debug_console
				stats.visible_geometry++;
				#end
				o.render(this, camera);
			}
		}

	}

	public function set_object_renderer(_or:ObjectRenderer) {

		if(_or != current) {
			current.end();
			current = _or;
			current.start();
		}
		
	}
	
	public inline function clip(clip_rect:Rectangle) {

		if(clip_rect != null) {
			g.scissor(Std.int(clip_rect.x), Std.int(clip_rect.y), Std.int(clip_rect.w), Std.int(clip_rect.h));
		} else {
			g.scissor(Std.int(camera.viewport.x), Std.int(camera.viewport.y), Std.int(camera.viewport.w), Std.int(camera.viewport.h));
		}

	}

	// public inline function set_projection(_loc:ConstantLocation) {

	// 	g.setMatrix3(_loc, camera.projection_matrix);

	// }

	public inline function get_buffer(_count:Int):VertexBuffer {

		return buffers[get_buffer_index(_count)];
		// return buffers[buffers.length-1];

	}

	// public function set_blendmode(sh:Shader) {

	// 	if(layer.blend_src != BlendMode.Undefined && layer.blend_dst != BlendMode.Undefined) {
	// 		sh.blendSource = layer.blend_src;
	// 		sh.alphaBlendDestination = layer.blend_dst;
	// 		sh.alphaBlendSource = layer.blend_src;
	// 		sh.blendDestination = layer.blend_dst;
	// 		sh.blendOperation = layer.blend_eq;
	// 	} else { // set default blend modes
	// 		sh.reset_blendmodes();
	// 	}

	// }

	// public inline function set_texture(_loc:TextureUnit, _texture:Texture) {
		
	// 	if(_texture == null) {
	// 		_texture = texture_blank;
	// 	}
		
	// 	g.setTexture(_loc, _texture.image);
	// 	g.setTextureParameters(
	// 		_loc, 
	// 		_texture.u_addressing, 
	// 		_texture.v_addressing, 
	// 		_texture.filter_min, 
	// 		_texture.filter_mag, 
	// 		_texture.mipmap_filter
	// 	);

	// }

	// public inline function remove_texture(_loc:TextureUnit) {

	// 	g.setTexture(_loc, null);

	// }

	function setup_buffers() {

		var shader = renderer.shaders.get('textured');
		
    	var size_pow = Mathf.require_pow2(max_vertices);
    	var i:Int = 4;
    	while(i <= size_pow) {
    		buffers.push(new VertexBuffer(i, shader.pipeline.inputLayout[0], Usage.DynamicUsage));
    		_debug('create buffer for $i vertices');
    		i *= 2;
    	}

	}
	
	function setup_default_renderers() {

		quad_renderer = new QuadRenderer(this);
		mesh_renderer = new MeshRenderer(this);
		quadpack_renderer = new QuadPackRenderer(this);
		particles_renderer = new ParticlesRenderer(this);
		static_renderer = new StaticRenderer(this);

	}

	function get_buffer_index(_count:Int):Int {
		
		if(_count > renderer.batch_size) { //todo: assert
			_count = renderer.batch_size;
		}
		
		var p2 = Mathf.require_pow2(_count);
		return Mathf.log2(p2)-2;

	}

}