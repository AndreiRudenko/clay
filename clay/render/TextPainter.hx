package clay.render;


import kha.Color;
import kha.Framebuffer;
import kha.Shaders;
import kha.math.FastMatrix3;
import kha.Kravur;
import kha.graphics4.BlendingOperation;
import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;

import clay.components.Texture;
import clay.components.Camera;
import clay.components.Geometry;
import clay.render.Shader;
import clay.math.Matrix;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


@:access(clay.components.Geometry)
class TextPainter extends Painter {


    var geometry:Geometry;

	var geom_count:Int = 0;
	var vert_count:Int = 0;
	var last_shader:Shader;

	var buffer_size:Int = 1024;
	var buffer_idx:Int = 0;

	var shader:Shader;
	var vertexbuffer:VertexBuffer;
	var vertices:Float32Array;
	var indexbuffer:IndexBuffer;

	var projection_loc:ConstantLocation;
	var texture_loc:TextureUnit;

	var last_texture:Texture;

	var font:Kravur;


    public function new() {

    	super();

		var structure = new VertexStructure();
		structure.add("a_position", VertexData.Float2);
		structure.add("a_texpos", VertexData.Float2);
		structure.add("a_color", VertexData.Float4);

		shader = new Shader();
		shader.inputLayout = [structure];
		shader.vertexShader = Shaders.text_vert;
		shader.fragmentShader = Shaders.text_frag;
		shader.blendSource = BlendingFactor.SourceAlpha;
		shader.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader.compile();

		projection_loc = shader.getConstantLocation("u_mvpmatrix");
		texture_loc = shader.getTextureUnit("tex");

		vertexbuffer = new VertexBuffer(buffer_size * 4, structure, Usage.DynamicUsage);
		vertices = vertexbuffer.lock();
		
		indexbuffer = new IndexBuffer(buffer_size * 6, Usage.StaticUsage);
		var indices = indexbuffer.lock();
		for (i in 0...buffer_size) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		indexbuffer.unlock();

		geometry = null;

    }

    override function destroy() {}

    override function onenter(l:Layer, g:Graphics, cam:Camera) {
        
    	super.onenter(l, g, cam);

		shader.blendSource = l.blend_src;
		shader.alphaBlendSource = l.blend_src;
		shader.blendDestination = l.blend_dst;
		shader.alphaBlendDestination = l.blend_dst;
		shader.blendOperation = l.blend_eq;

    	last_shader = null;
    	last_texture = null;

    }

    override function onleave(l:Layer, g:Graphics) {

		g.setTexture(texture_loc, null);

    }

    override function batch(g:Graphics, geom:Geometry) {

		if(geom.texture == null) { // todo: can be?
			return;
		}

		_verboser('batch: ${geom.id}, order: ${geom.order}, sort_key ${geom.sort_key}');

		var was_draw:Bool = false;
		if(vert_count+1 >= buffer_size) {
			draw(g);
			was_draw = true;
		}

		if(geom.shader != null) {
			if(last_shader != geom.shader) {
				if(last_shader != null && !was_draw) {
					draw(g);
					was_draw = true;
				}
				set_shader(g, geom.shader);
				_debug('set geometry shader');
			}

		} else if(last_shader != shader) {
			set_shader(g, shader);
			_debug('set default shader');
		}

		if(last_texture != geom.texture) {
			if(last_texture != null && !was_draw) {
				draw(g);
			}
			set_texture(g, geom.texture);
			_debug('set new texture');
		}

		if(geometry == null) {
			geometry = geom;
		}

		geom_count++;
		vert_count += geom.vertices.length;
		buffer_idx += Std.int(geom.vertices.length / 4 * 6);

    }

    override function draw(g:Graphics) {

    	if(vert_count == 0) {
    		return;
    	}
    	
		_verboser('draw text: vertices: $vert_count');

		update_vbo();

		vertexbuffer.unlock();

		g.setMatrix3(projection_loc, camera.projection_matrix);

		g.setVertexBuffer(vertexbuffer);
		g.setIndexBuffer(indexbuffer);

		g.drawIndexedVertices(0, buffer_idx);

		vertices = vertexbuffer.lock();

		geom_count = 0;
		vert_count = 0;
		buffer_idx = 0;

    	last_shader = null;
		geometry = null;
    	
    }

	inline function update_vbo() {

		var offset:Int = 0;
		var n:Int = 0;
		var m:Matrix = null;
		var v:Vertex = null;
		var g:Geometry = geometry;
		for (_ in 0...geom_count) {
			m = g.transform_matrix;

			for (i in 0...g.vertices.length) {
				n = i * 8 + offset;
				v = g.vertices[i];
				vertices.set(n, m.a * v.pos.x + m.c * v.pos.y + m.tx);
				vertices.set(n + 1, m.b * v.pos.x + m.d * v.pos.y + m.ty);
				vertices.set(n + 2, v.tcoord.x);
				vertices.set(n + 3, v.tcoord.y);
				vertices.set(n + 4, v.color.r);
				vertices.set(n + 5, v.color.g);
				vertices.set(n + 6, v.color.b);
				vertices.set(n + 7, v.color.a);
			}
			offset += g.vertices.length * 8;

			g = g.next;
		}

	}

    inline function set_shader(g:Graphics, sh:Shader) {

    	if(last_shader != null) {
			g.setTexture(texture_loc, null);
    		last_texture = null;
    	}

    	last_shader = sh;
		g.setPipeline(sh);
		projection_loc = sh.getConstantLocation("u_mvpmatrix");
		texture_loc = sh.getTextureUnit("tex");

    }

    inline function set_texture(g:Graphics, t:Texture) {

		last_texture = t;
		g.setTexture(texture_loc, last_texture.image);

		g.setTextureParameters(
			texture_loc, 
			TextureAddressing.Clamp, 
			TextureAddressing.Clamp, 
			t.filter_min, 
			t.filter_mag, 
			t.mipmap_filter
		);

    }

}