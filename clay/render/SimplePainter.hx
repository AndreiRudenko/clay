package clay.render;


import kha.Color;
import kha.Framebuffer;
import kha.Shaders;
import kha.math.FastMatrix3;
import kha.graphics4.BlendingOperation;
import kha.graphics4.BlendingFactor;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;
import kha.Image;

import clay.components.Camera;
import clay.components.Texture;
import clay.components.Geometry;
import clay.render.Painter;
import clay.render.Shader;
import clay.render.BlendMode;
import clay.math.Matrix;
import clay.utils.Log.*;

using clay.render.utils.FastMatrix3Extender;


@:access(clay.components.Geometry)
class SimplePainter extends Painter {


	var buffer_size:Int = 1024;
	var max_indices:Int = 0;
	var max_vertices:Int = 0;
	var draw_calls:Int = 0;

	// colored
	var geometry_colored:Geometry;

	var geom_count_colored:Int = 0;
	var vert_count_colored:Int = 0;
	var indices_count_colored:Int = 0;

	var last_shader:Shader;

	var shader_colored:Shader;
	var vertexbuffer_colored:VertexBuffer;
	var vertices_colored:Float32Array;
	var indexbuffer_colored:IndexBuffer;
	var indices_colored:Uint32Array;

	var projection_loc_colored:ConstantLocation;

	// textured
	var geometry_textured:Geometry;

	var geom_count_textured:Int = 0;
	var vert_count_textured:Int = 0;
	var indices_count_textured:Int = 0;

	var shader_textured:Shader;
	var vertexbuffer_textured:VertexBuffer;
	var vertices_textured:Float32Array;
	var indexbuffer_textured:IndexBuffer;
	var indices_textured:Uint32Array;

	var projection_loc_textured:ConstantLocation;
	var texture_loc:TextureUnit;
	var last_texture:Image;

	var draw_state:DrawState = DrawState.none;


	public function new() {

		super();

    	buffer_size = Renderer.buffer_size;
    	max_indices = buffer_size * 3;
		max_vertices = buffer_size * 3;
		// colored
		var structure = new VertexStructure();
		structure.add("a_position", VertexData.Float2);
		structure.add("a_colored", VertexData.Float4);

		shader_colored = new Shader();
		shader_colored.inputLayout = [structure];
		shader_colored.vertexShader = Shaders.colored_vert;
		shader_colored.fragmentShader = Shaders.colored_frag;
		shader_colored.blendSource = BlendingFactor.SourceAlpha;
		shader_colored.blendDestination = BlendingFactor.InverseSourceAlpha;
		shader_colored.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_colored.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_colored.compile();

		projection_loc_colored = shader_colored.getConstantLocation("u_mvpmatrix");
		vertexbuffer_colored = new VertexBuffer(max_indices, structure, Usage.DynamicUsage);
		vertices_colored = vertexbuffer_colored.lock();
		indexbuffer_colored = new IndexBuffer(max_vertices, Usage.DynamicUsage);
		indices_colored = indexbuffer_colored.lock();

		geometry_colored = null;

		// textured
		structure = new VertexStructure();
		structure.add("a_position", VertexData.Float2);
		structure.add("a_texpos", VertexData.Float2);
		structure.add("a_color", VertexData.Float4);

		shader_textured = new Shader();
		shader_textured.inputLayout = [structure];
		shader_textured.vertexShader = Shaders.textured_vert;
		shader_textured.fragmentShader = Shaders.textured_frag;
		shader_textured.blendSource = BlendingFactor.SourceAlpha;
		shader_textured.blendDestination = BlendingFactor.InverseSourceAlpha;
		
		// shader_textured.blendSource = BlendMode.SourceAlpha;
		// shader_textured.blendDestination = BlendMode.BlendOne;
		shader_textured.alphaBlendSource = BlendingFactor.SourceAlpha;
		shader_textured.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
		shader_textured.compile();

		projection_loc_textured = shader_textured.getConstantLocation("u_mvpmatrix");
		texture_loc = shader_textured.getTextureUnit("tex");

		vertexbuffer_textured = new VertexBuffer(max_indices, structure, Usage.DynamicUsage);
		vertices_textured = vertexbuffer_textured.lock();
		
		indexbuffer_textured = new IndexBuffer(max_vertices, Usage.DynamicUsage);
		indices_textured = indexbuffer_textured.lock();

		geometry_textured = null;

	}

	override function destroy() {}

	override function onenter(l:Layer, g:Graphics, cam:Camera) {
		
		super.onenter(l, g, cam);


		shader_textured.blendSource = l.blend_src;
		shader_textured.alphaBlendSource = l.blend_src;
		shader_textured.blendDestination = l.blend_dst;
		shader_textured.alphaBlendDestination = l.blend_dst;
		shader_textured.blendOperation = l.blend_eq;

		shader_colored.blendSource = l.blend_src;
		shader_colored.alphaBlendSource = l.blend_src;
		shader_colored.blendDestination = l.blend_dst;
		shader_colored.alphaBlendDestination = l.blend_dst;
		shader_colored.blendOperation = l.blend_eq;

		last_shader = null;
    	last_texture = null;
		draw_calls = 0;

	}

	override function onleave(l:Layer, g:Graphics) {

		if(draw_state == DrawState.textured) {
			g.setTexture(texture_loc, null);
		}
		_verboser('draw calls: $draw_calls');

	}

	override function batch(g:Graphics, geom:Geometry) {

		_verboser('batch: ${geom.id}, order: ${geom.order}, sort_key ${geom.sort_key}');

		var can_draw:Bool = true;

		if(geom.texture == null) { // colored
			if(draw_state != DrawState.colored) {
				draw(g);
				can_draw = false;
				g.setTexture(texture_loc, null);
				last_texture = null;
			}
			batch_colored(g, geom, can_draw);
		} else { // textured
			if(draw_state != DrawState.textured) {
				draw(g);
				can_draw = false;
				last_texture = null;
			}
			batch_textured(g, geom, can_draw);
		}

	}

	override function draw(g:Graphics) {

		draw_colored(g);
		draw_textured(g);

	}
	
	inline function update_vbo_colored() {

		var offset:Int = 0;
		var n:Int = 0;
		var m:Matrix = null;
		var v:Vertex = null;
		var g:Geometry = geometry_colored;
		for (_ in 0...geom_count_colored) {
			m = g.transform_matrix;

			for (i in 0...g.vertices.length) {
				n = i * 6 + offset;
				v = g.vertices[i];
				vertices_colored.set(n, m.a * v.pos.x + m.c * v.pos.y + m.tx);
				vertices_colored.set(n + 1, m.b * v.pos.x + m.d * v.pos.y + m.ty);
				vertices_colored.set(n + 2, v.color.r);
				vertices_colored.set(n + 3, v.color.g);
				vertices_colored.set(n + 4, v.color.b);
				vertices_colored.set(n + 5, v.color.a);
			}
			offset += g.vertices.length * 6;

			g = g.next;
		}

	}

	inline function update_vbo_textured() {

		var offset:Int = 0;
		var n:Int = 0;
		var m:Matrix = null;
		var v:Vertex = null;
		var g:Geometry = geometry_textured;
		for (_ in 0...geom_count_textured) {
			m = g.transform_matrix;

			for (i in 0...g.vertices.length) {
				n = i * 8 + offset;
				v = g.vertices[i];
				vertices_textured.set(n, m.a * v.pos.x + m.c * v.pos.y + m.tx);
				vertices_textured.set(n + 1, m.b * v.pos.x + m.d * v.pos.y + m.ty);
				vertices_textured.set(n + 2, v.tcoord.x);
				vertices_textured.set(n + 3, v.tcoord.y);
				vertices_textured.set(n + 4, v.color.r);
				vertices_textured.set(n + 5, v.color.g);
				vertices_textured.set(n + 6, v.color.b);
				vertices_textured.set(n + 7, v.color.a);
			}
			offset += g.vertices.length * 8;

			g = g.next;
		}

	}

	inline function update_indices(_geom:Geometry, _indices:Uint32Array, _count:Int) {

		if(_indices.length == 0) {
			return;
		}

		var _offset:Int = 0;
		var j:Int = 0;

		var g:Geometry = _geom;
		for (_ in 0..._count) {

			for (ind in g.indices) {
				_indices[j] = ind+_offset;
				j++;
			}
			_offset += g.vertices.length;

			g = g.next;
		}

	}

	inline function set_shader_colored(g:Graphics, sh:Shader) {

		last_shader = sh;
		g.setPipeline(sh);
		projection_loc_colored = sh.getConstantLocation("u_mvpmatrix");

	}

	inline function set_shader_textured(g:Graphics, sh:Shader) {

		if(last_shader != null && last_texture != null) {
			g.setTexture(texture_loc, null);
			last_texture = null;
		}

		last_shader = sh;
		g.setPipeline(sh);
		projection_loc_textured = sh.getConstantLocation("u_mvpmatrix");
		texture_loc = sh.getTextureUnit("tex");

	}

	inline function set_texture(g:Graphics, t:Texture) {

		last_texture = t.image;
		g.setTexture(texture_loc, last_texture);
		g.setTextureParameters(
			texture_loc, 
			t.u_addressing, 
			t.v_addressing, 
			t.filter_min, 
			t.filter_mag, 
			t.mipmap_filter
		);

	}

	inline function batch_colored(g:Graphics, geom:Geometry, can_draw:Bool) {

		if(vert_count_colored+geom.vertices.length >= max_vertices 
		|| indices_count_colored+geom.indices.length >= max_indices) {
			draw(g);
			can_draw = false;
		}

		if(geom.shader != null) {
			if(last_shader != geom.shader) {
				if(last_shader != null && can_draw) {
					draw(g);
				}
				set_shader_colored(g, geom.shader);
				_debug('set geometry shader');
			}

		} else if(last_shader != shader_colored) {
			if(can_draw) {
				draw(g);
			}
			_debug('set default color shader');
			set_shader_colored(g, shader_colored);				
		}

		if(geometry_colored == null) {
			geometry_colored = geom;
		}

		draw_state = DrawState.colored;

		geom_count_colored++;
		vert_count_colored += geom.vertices.length;
		indices_count_colored += geom.indices.length;

	}

	inline function batch_textured(g:Graphics, geom:Geometry, can_draw:Bool) {

		if(vert_count_textured+geom.vertices.length >= max_vertices 
		|| indices_count_textured+geom.indices.length >= max_indices) {
			draw(g);
			can_draw = false;
		}

		if(geom.shader != null) {
			if(last_shader != geom.shader) {
				if(last_shader != null && can_draw) {
					draw(g);
				}
				set_shader_textured(g, geom.shader);
				_debug('set geometry shader');
			}

		} else if(last_shader != shader_textured) {
			if(can_draw) {
				draw(g);
			}
			set_shader_textured(g, shader_textured);
			_debug('set default texture shader');
		}

		if(last_texture != geom.texture.image) {
			if(last_texture != null && can_draw) {
				draw(g);
			}
			set_texture(g, geom.texture);
			_debug('set new texture');
		}

		if(geometry_textured == null) {
			geometry_textured = geom;
		}

		draw_state = DrawState.textured;

		geom_count_textured++;
		vert_count_textured += geom.vertices.length;
		indices_count_textured += geom.indices.length;

	}

	inline function draw_colored(g:Graphics) {
		
		if(vert_count_colored == 0) {
			return;
		}

		_verboser('draw colored: vertices: $vert_count_colored, indices: $indices_count_colored');

		update_vbo_colored();
		update_indices(geometry_colored, indices_colored, geom_count_colored);

		vertexbuffer_colored.unlock();
		indexbuffer_colored.unlock();

		g.setMatrix3(projection_loc_colored, camera.projection_matrix);

		g.setVertexBuffer(vertexbuffer_colored);
		g.setIndexBuffer(indexbuffer_colored);

		g.drawIndexedVertices(0, indices_count_colored);

		vertices_colored = vertexbuffer_colored.lock();
		indices_colored = indexbuffer_colored.lock();

		geom_count_colored = 0;
		vert_count_colored = 0;
		indices_count_colored = 0;

		last_shader = null;
		geometry_colored = null;
		draw_calls++;

	}

	inline function draw_textured(g:Graphics) {

		if(vert_count_textured == 0) {
			return;
		}

		_verboser('draw textured: vertices: $vert_count_textured, indices: $indices_count_textured');

		update_vbo_textured();
		update_indices(geometry_textured, indices_textured, geom_count_textured);

		vertexbuffer_textured.unlock();
		indexbuffer_textured.unlock();

		g.setMatrix3(projection_loc_textured, camera.projection_matrix);

		g.setVertexBuffer(vertexbuffer_textured);
		g.setIndexBuffer(indexbuffer_textured);

		g.drawIndexedVertices(0, indices_count_textured);

		vertices_textured = vertexbuffer_textured.lock();
		indices_textured = indexbuffer_textured.lock();

		geom_count_textured = 0;
		vert_count_textured = 0;
		indices_count_textured = 0;

		last_shader = null;
		geometry_textured = null;
		draw_calls++;

	}


}
