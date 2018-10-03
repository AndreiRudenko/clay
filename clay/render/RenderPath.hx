package clay.render;


import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;
import kha.arrays.Uint32Array;
import kha.Image;

import clay.components.Camera;
import clay.components.Texture;
import clay.components.Geometry;
import clay.render.Shader;
import clay.math.Matrix;
import clay.utils.Log.*;


@:access(clay.components.Geometry)
class RenderPath {


	var buffer_size:Int = 1024;
	var max_indices:Int = 0;
	var max_vertices:Int = 0;
	var draw_calls:Int = 0;

	var geom_count:Int = 0;
	var vert_count:Int = 0;
	var indices_count:Int = 0;

	var renderer:Renderer;
    var camera:Camera;
    var layer:Layer;

	var geometry:Geometry;

	var last_shader:Shader;
	var last_texture:Image;

	var vertexbuffer:VertexBuffer;
	var vertexbuffer_colored:VertexBuffer;
	var vertexbuffer_textured:VertexBuffer;
	var vertices:Float32Array;
	var indexbuffer:IndexBuffer;
	var indexbuffer_quad:IndexBuffer;
	var indices:Uint32Array;

	var texture_loc:TextureUnit;
	var projection_loc:ConstantLocation;

	var geom_type:GeometryType = GeometryType.none;
	var draw_state:DrawState = DrawState.none;


	public function new(_renderer:Renderer) {

		renderer = _renderer;

    	buffer_size = Renderer.buffer_size;
    	max_indices = buffer_size * 3;
		max_vertices = buffer_size * 3;

		vertexbuffer_colored = new VertexBuffer(max_indices, renderer.shader_colored.inputLayout[0], Usage.DynamicUsage);
		vertexbuffer_textured = new VertexBuffer(max_indices, renderer.shader_textured.inputLayout[0], Usage.DynamicUsage);
		indexbuffer = new IndexBuffer(max_vertices, Usage.DynamicUsage);

		texture_loc = renderer.shader_textured.getTextureUnit("tex");
		indices = indexbuffer.lock();

		indexbuffer_quad = new IndexBuffer(buffer_size * 6, Usage.StaticUsage);
		var indquad = indexbuffer_quad.lock();
		for (i in 0...buffer_size) {
			indquad[i * 3 * 2 + 0] = i * 4 + 0;
			indquad[i * 3 * 2 + 1] = i * 4 + 1;
			indquad[i * 3 * 2 + 2] = i * 4 + 2;
			indquad[i * 3 * 2 + 3] = i * 4 + 0;
			indquad[i * 3 * 2 + 4] = i * 4 + 2;
			indquad[i * 3 * 2 + 5] = i * 4 + 3;
		}
		indexbuffer_quad.unlock();

	}

	public function onenter(l:Layer, g:Graphics, cam:Camera) {
		
		draw_state = DrawState.none;
        camera = cam;
        layer = l;

		last_shader = null;
    	last_texture = null;
		draw_calls = 0;

	}

	public function onleave(l:Layer, g:Graphics) {

		if(last_texture != null) {
			g.setTexture(texture_loc, null);
			last_texture = null;
		}
		_verboser('draw calls: $draw_calls');

	}

	inline function update_blendmode(sh:Shader) {

		sh.blendSource = layer.blend_src;
		sh.alphaBlendSource = layer.blend_src;
		sh.blendDestination = layer.blend_dst;
		sh.alphaBlendDestination = layer.blend_dst;
		sh.blendOperation = layer.blend_eq;

	}
	
	inline function update_vbo() {

		var offset:Int = 0;
		var n:Int = 0;
		var m:Matrix = null;
		var v:Vertex = null;
		var g:Geometry = geometry;

		if(draw_state == DrawState.colored) {

			vertexbuffer = vertexbuffer_colored;
			vertices = vertexbuffer.lock();

			for (_ in 0...geom_count) {
				m = g.transform_matrix;

				for (i in 0...g.vertices.length) {
					n = i * 6 + offset;
					v = g.vertices[i];
					vertices.set(n, m.a * v.pos.x + m.c * v.pos.y + m.tx);
					vertices.set(n + 1, m.b * v.pos.x + m.d * v.pos.y + m.ty);
					vertices.set(n + 2, v.color.r);
					vertices.set(n + 3, v.color.g);
					vertices.set(n + 4, v.color.b);
					vertices.set(n + 5, v.color.a);
				}
				offset += g.vertices.length * 6;

				g = g.next;
			}
		} else if(draw_state == DrawState.textured) {

			vertexbuffer = vertexbuffer_textured;
			vertices = vertexbuffer.lock();

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

	}

	inline function update_indices() {

		if(indices.length == 0) {
			return;
		}

		var _offset:Int = 0;
		var j:Int = 0;

		var g:Geometry = geometry;
		for (_ in 0...geom_count) {
			for (ind in g.indices) {
				indices[j] = ind+_offset;
				j++;
			}
			_offset += g.vertices.length;
			g = g.next;
		}

	}

	public function batch(g:Graphics, geom:Geometry) {

		_verboser('batch order: ${geom.order}, sort_key ${geom.sort_key}');

		var was_draw = false;

		if(vert_count + geom.vertices.length >= max_vertices 
			|| indices_count + geom.indices.length >= max_indices
			|| geom_type != geom.geometry_type
			) {
			draw(g);
			was_draw = true;
		}

		var shader = geom.shader;

		if(shader == null) {
			if(geom.texture == null) {
				shader = renderer.shader_colored;
			} else {
				if(geom.geometry_type == GeometryType.text) {
					shader = renderer.shader_text;
				} else {
					shader = renderer.shader_textured;
				}
			}
		}

		if(shader != last_shader) {
			if(!was_draw) {
				draw(g);
				was_draw = true;
			}
			if(geom.texture != null) {
				texture_loc = shader.getTextureUnit("tex");
			} else {
				g.setTexture(texture_loc, null);
				last_texture = null;
			}
			projection_loc = shader.getConstantLocation("mvpMatrix");
			g.setPipeline(shader);

			update_blendmode(shader);

			last_shader = shader;
		}

		if(geom.texture != null) {
			if(last_texture != geom.texture.image) {
				if(!was_draw) {
					draw(g);
					was_draw = true;
				}
				var t = geom.texture;
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
			draw_state = DrawState.textured;
		} else {
			draw_state = DrawState.colored;
		}

		if(geometry == null) {
			geometry = geom;
		}

		geom_type = geom.geometry_type;

		geom_count++;
		vert_count += geom.vertices.length;
		indices_count += geom.indices.length;

	}

	public function draw(g:Graphics) {

		if(vert_count == 0) {
			return;
		}

		_verboser('draw, vertices: $vert_count, indices: $indices_count');

		if(geom_type == GeometryType.polygon) {
			update_vbo();
			update_indices();

			vertexbuffer.unlock();
			indexbuffer.unlock();

			g.setMatrix3(projection_loc, camera.projection_matrix);

			g.setVertexBuffer(vertexbuffer);
			g.setIndexBuffer(indexbuffer);

			g.drawIndexedVertices(0, indices_count);

			vertices = vertexbuffer.lock();
			indices = indexbuffer.lock();
		} else if(geom_type == GeometryType.quad || geom_type == GeometryType.text) {
			update_vbo();

			vertexbuffer.unlock();

			g.setMatrix3(projection_loc, camera.projection_matrix);

			g.setVertexBuffer(vertexbuffer);
			g.setIndexBuffer(indexbuffer_quad);

			g.drawIndexedVertices(0, Std.int(vert_count * 1.5));

			vertices = vertexbuffer.lock();
		}

		geom_count = 0;
		vert_count = 0;
		indices_count = 0;

		last_shader = null;
		geometry = null;
		draw_calls++;

	}


}

@:enum abstract DrawState(UInt) from UInt to UInt {

    var none              = 0;
    var colored           = 1;
    var textured          = 2;

}
