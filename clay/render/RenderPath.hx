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
import clay.components.InstancedGeometry;
import clay.render.Shader;
import clay.math.Matrix;
import clay.utils.Log.*;


@:access(clay.components.Geometry)
class RenderPath {


	var buffer_size:Int = 2048;
	var max_indices:Int = 0;
	var max_vertices:Int = 0;
	var draw_calls:Int = 0;
	var draw_geoms:Int = 0;

	var geom_count:Int = 0;
	var vert_count:Int = 0;
	var indices_count:Int = 0;

	var renderer:Renderer;
    var camera:Camera;
    var layer:Layer;

	var geometry:Geometry;

	var last_shader:Shader;
	var last_texture:Texture;

	var vertexbuffer:VertexBuffer;
	var vertexbuffer_colored:VertexBuffer;
	var vertexbuffer_textured:VertexBuffer;
	var vertices:Float32Array;

	var indexbuffer:IndexBuffer;
	var indexbuffer_poly:IndexBuffer;
	var indexbuffer_quad:IndexBuffer;
	var indices:Uint32Array;

	var texture_loc:TextureUnit;
	var projection_loc:ConstantLocation;

	var draw_type:GeometryType = GeometryType.none;
	var draw_textured:Bool = false;


	public function new(_renderer:Renderer) {

		renderer = _renderer;

    	buffer_size = Renderer.buffer_size;
    	max_indices = buffer_size * 3;
		max_vertices = buffer_size * 3;

		vertexbuffer_colored = new VertexBuffer(max_indices, renderer.shader_colored.inputLayout[0], Usage.DynamicUsage);
		vertexbuffer_textured = new VertexBuffer(max_indices, renderer.shader_textured.inputLayout[0], Usage.DynamicUsage);
		indexbuffer_poly = new IndexBuffer(max_vertices, Usage.DynamicUsage);

		texture_loc = renderer.shader_textured.getTextureUnit("tex");
		indices = indexbuffer_poly.lock();

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
		
        camera = cam;
        layer = l;

		last_shader = null;
    	last_texture = null;
		draw_calls = 0;
		draw_geoms = 0;

	}

	public function onleave(l:Layer, g:Graphics) {

		if(last_texture != null) {
			g.setTexture(texture_loc, null);
			last_texture = null;
		}

	}

	public function batch(g:Graphics, geom:Geometry) {

		_verboser('batch order: ${geom.order}, sort_key ${geom.sort_key}');

		var was_draw = false;

		if(vert_count + geom.vertices.length >= max_vertices 
			|| indices_count + geom.indices.length >= max_indices
			|| draw_type != geom.geometry_type
		) {
			draw(g);
			was_draw = true;
		}

		var shader = geom.shader;

		if(shader == null) {
			if(geom.texture == null) {
				if(geom.geometry_type == GeometryType.instanced) {
					shader = renderer.shader_instanced;
				} else {
					shader = renderer.shader_colored;
				}
			} else {
				if(geom.geometry_type == GeometryType.instanced) {
					shader = renderer.shader_instanced_textured;
				} else if(geom.geometry_type == GeometryType.text) {
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

			if(geom.geometry_type != GeometryType.instanced) {
				projection_loc = shader.getConstantLocation("mvpMatrix");
			}

			g.setPipeline(shader);

			update_blendmode(shader);

			last_shader = shader;
		}

		if(geom.texture != null) {
			if(last_texture != geom.texture) {
				if(!was_draw) {
					draw(g);
					was_draw = true;
				}
				last_texture = geom.texture;
			}
			draw_textured = true;
		} else {
			draw_textured = false;
		}

		if(geometry == null) {
			geometry = geom;
		}

		draw_type = geom.geometry_type;

		draw_geoms++;
		geom_count++;

		vert_count += geom.vertices.length;
		if(draw_type == GeometryType.quad || draw_type == GeometryType.text) {
			indices_count += Std.int(geom.vertices.length * 1.5);
		} else {
			indices_count += geom.indices.length;
		}

	}

	public function draw(g:Graphics) {

		if(vert_count == 0) {
			return;
		}

		_verboser('draw, vertices: $vert_count, indices: $indices_count');

		if(draw_type == GeometryType.instanced) {
			if (g.instancedRenderingAvailable()) {
				var inst_geom:InstancedGeometry = cast geometry;
				inst_geom.update_instances(camera.projection_matrix);

				update_texture(g);

				g.setVertexBuffers(inst_geom.vertexbuffers);
				g.setIndexBuffer(inst_geom.indexbuffer);

				g.drawIndexedVerticesInstanced(inst_geom.instances_count);
			}
		} else {
			update_vbo();
			update_indices();
			update_texture(g);

			g.setMatrix3(projection_loc, camera.projection_matrix);

			g.setVertexBuffer(vertexbuffer);
			g.setIndexBuffer(indexbuffer);

			g.drawIndexedVertices(0, indices_count);
		}

		geom_count = 0;
		vert_count = 0;
		indices_count = 0;

		geometry = null;
		draw_calls++;

	}
	
	inline function update_vbo() {

		var offset:Int = 0;
		var n:Int = 0;
		var m:Matrix = null;
		var v:Vertex = null;
		var g:Geometry = geometry;

		if(draw_textured) {
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

			vertexbuffer.unlock();
		} else {
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

			vertexbuffer.unlock();
		}

	}

	inline function update_indices() {

		if(draw_type == GeometryType.quad || draw_type == GeometryType.text) {
			indexbuffer = indexbuffer_quad;
		} else {
			indexbuffer = indexbuffer_poly;
			indices = indexbuffer.lock();

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

			indexbuffer.unlock();
		}

	}

	inline function update_texture(g:Graphics) {
		
		if(last_texture != null) {
			g.setTexture(texture_loc, last_texture.image);
			g.setTextureParameters(
				texture_loc, 
				last_texture.u_addressing, 
				last_texture.v_addressing, 
				last_texture.filter_min, 
				last_texture.filter_mag, 
				last_texture.mipmap_filter
			);
		}

	}

	inline function update_blendmode(sh:Shader) {

		sh.blendSource = layer.blend_src;
		sh.alphaBlendSource = layer.blend_src;
		sh.blendDestination = layer.blend_dst;
		sh.alphaBlendDestination = layer.blend_dst;
		sh.blendOperation = layer.blend_eq;

	}


}
