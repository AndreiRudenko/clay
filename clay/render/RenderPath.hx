package clay.render;



import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.TextureFormat;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
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

	var vertexbuffers:Array<VertexBuffer>;
	var indexbuffers:Array<IndexBuffer>;

	var renderer:Renderer;
	var current:ObjectRenderer;

    var camera:Camera;
    var layer:Layer;


	public function new(renderer:Renderer) {
		
		this.renderer = renderer;

		max_vertices = renderer.batch_size;
    	var max_quads = Std.int(max_vertices / 4);
    	max_indices = max_quads * 6; // adjusted for quads

    	vertexbuffers = [];
    	indexbuffers = [];

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

	public inline function get_vertexbuffer(size:Int):VertexBuffer {

		var p2 = Mathf.require_pow2(size);
		var idx = Mathf.log2(p2);
		var buffer = vertexbuffers[idx];

		if(buffer == null) {
			var shader = renderer.shaders.get('textured');
			buffer = new VertexBuffer(p2, shader.pipeline.inputLayout[0], Usage.DynamicUsage);
			vertexbuffers[idx] = buffer;
		}

		return buffer;

	}

	public inline function get_indexbuffer(size:Int):IndexBuffer {

		var p2 = Mathf.require_pow2(size);
		var idx = Mathf.log2(p2);
		var buffer = indexbuffers[idx];

		if(buffer == null) {
			buffer = new IndexBuffer(p2, Usage.DynamicUsage);
			indexbuffers[idx] = buffer;
		}

		return buffer;

	}
	
	function setup_default_renderers() {

		quad_renderer = new QuadRenderer(this);
		mesh_renderer = new MeshRenderer(this);
		quadpack_renderer = new QuadPackRenderer(this);
		particles_renderer = new ParticlesRenderer(this);
		static_renderer = new StaticRenderer(this);

	}


}