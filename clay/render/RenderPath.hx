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

import clay.render.Camera;
import clay.resources.Texture;
import clay.components.graphics.Geometry;
import clay.components.graphics.Geometry.InstancedGeometry;
import clay.render.Shader;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.math.Matrix;
import clay.math.Rectangle;
import clay.math.Mathf;
import clay.utils.Log.*;


@:access(clay.components.graphics.Geometry)
class RenderPath {


	var max_vertices:Int = 0;
	var max_indices:Int = 0;

	var draw_calls:Int = 0;
	var visible_geom_count:Int = 0;
	var geom_count:Int = 0;
	var vert_count:Int = 0;
	var indices_count:Int = 0;

	var renderer:Renderer;
    var camera:Camera;
    var layer:Layer;

	var geometry:Array<Geometry>;

	var last_shader:Shader;
	var last_texture:Texture;
	var last_clip_rect:Rectangle;

	var vertices:Float32Array;
	var vertexbuffer:VertexBuffer;
	var buffers_colored:Array<VertexBuffer>;
	var buffers_textured:Array<VertexBuffer>;

	var indices:Uint32Array;
	var indexbuffer:IndexBuffer;
	var indexbuffer_poly:IndexBuffer;
	var indexbuffer_quad:IndexBuffer;

	var texture_loc:TextureUnit;
	var projection_loc:ConstantLocation;

	var last_geom_type:GeometryType = GeometryType.none;
	var draw_instanced:Bool = false;


	public function new(_renderer:Renderer) {

		renderer = _renderer;

		max_vertices = _renderer.batch_size;
		var quads = Std.int(max_vertices / 4);
    	max_indices = quads * 6; // adjust for quads

    	geometry = [];
    	buffers_colored = [];
    	buffers_textured = [];

    	var verts_pow = Mathf.require_pow2(max_vertices);
    	var i:Int = 4;
    	while(i <= verts_pow) {
    		buffers_colored.push(new VertexBuffer(i, renderer.shader_colored.inputLayout[0], Usage.DynamicUsage));
    		buffers_textured.push(new VertexBuffer(i, renderer.shader_textured.inputLayout[0], Usage.DynamicUsage));
    		_debug('create buffer for $i vertices');
    		i *= 2;
    	}

		indexbuffer_poly = new IndexBuffer(max_indices, Usage.DynamicUsage);

		texture_loc = renderer.shader_textured.getTextureUnit("tex");
		indices = indexbuffer_poly.lock();

		indexbuffer_quad = new IndexBuffer(max_indices, Usage.StaticUsage);
		var indquad = indexbuffer_quad.lock();
		for (i in 0...quads) {
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
    	last_clip_rect = null;

		draw_calls = 0;
		geom_count = 0;
		visible_geom_count = 0;

	}

	public function onleave(l:Layer, g:Graphics) {

		if(last_texture != null) {
			g.setTexture(texture_loc, null);
			last_texture = null;
		}

		#if !no_debug_console

		layer.stats.geometry += geom_count;
		layer.stats.visible_geometry += visible_geom_count;
		layer.stats.draw_calls += draw_calls;

		#end

		_verboser('draw_calls: ${draw_calls}');

	}

	public function batch(g:Graphics, geom:Geometry) {

		_verboser('batch: ${geom.name} vertices: ${geom.vertices.length}, sort_key ${geom.sort_key}');

		if(geom.visible) {

			if(geom.vertices.length > max_vertices || geom.indices.length > max_indices) {
	            log('WARNING can`t batch a geometry `${geom.name}` 
	            	verts: (${geom.vertices.length} vs max vertices: $max_vertices), 
	            	indices: (${geom.indices.length} vs max indices: $max_indices)');
				// todo: make it static?
				return;
			}

			if(vert_count + geom.vertices.length > max_vertices 
				|| indices_count + geom.indices.length > max_indices
				|| last_geom_type != geom.geometry_type 
				|| last_clip_rect != null && !last_clip_rect.equals(geom.clip_rect)
				|| last_shader != geom.shader 
				|| last_texture != geom.texture 
				|| geom.instanced 
				|| draw_instanced
			) {
				draw(g);
			}

			var shader = geom.shader;

			geometry.push(geom);

			last_geom_type = geom.geometry_type;
			last_texture = geom.texture;
			last_clip_rect = geom.clip_rect;

			draw_instanced = geom.instanced && g.instancedRenderingAvailable();

			// if we can`t render instanced, fall back to default shader
			if(geom.instanced && !g.instancedRenderingAvailable()) {
				if(!geom._custom_shader) {
					shader = geom.get_default_shader(false);
				}
			}

			if(shader != last_shader) {

				if(!draw_instanced) {
					projection_loc = shader.getConstantLocation("mvpMatrix");
				}

				update_blendmode(shader);
				g.setPipeline(shader);

				if(geom.texture != null) {
					texture_loc = shader.getTextureUnit("tex");
				} else {
					g.setTexture(texture_loc, null);
				}

				last_shader = shader;
			}

			visible_geom_count++;

			if(!geom.instanced) {
				vert_count += geom.vertices.length;
				if(geom.geometry_type == GeometryType.polygon) {
					indices_count += geom.indices.length;
				} else { // quad
					indices_count += Std.int(geom.vertices.length * 1.5);
				}
			} else {
				if(draw_instanced) {
					vert_count += geom.vertices.length;
					#if !no_debug_console
					layer.stats.instanced += geom.instances_count;
					#end
				} else {
					vert_count += geom.instances_count * geom.vertices.length;
					if(geom.geometry_type == GeometryType.polygon) {
						indices_count += geom.instances_count * geom.indices.length;
					} else { // quad
						indices_count += geom.instances_count * Std.int(geom.vertices.length * 1.5);
					}
				}
			}

		}

		geom_count++;

	}

	public function draw(g:Graphics) {

		if(vert_count == 0) {
			_verboser('no draw, vert_count == 0');
			return;
		}

		if(!set_vertices(g)) {
			return;
		}

		#if !no_debug_console

		layer.stats.vertices += vert_count;
		layer.stats.indices += indices_count;

		#end

		_verboser('draw, vertices: $vert_count, indices: $indices_count');

		if(last_clip_rect != null) {
			g.scissor(Std.int(last_clip_rect.x), Std.int(last_clip_rect.y), Std.int(last_clip_rect.w), Std.int(last_clip_rect.h));
			last_clip_rect = null;
		} else {
			g.scissor(Std.int(camera.viewport.x), Std.int(camera.viewport.y), Std.int(camera.viewport.w), Std.int(camera.viewport.h));
		}

		if(draw_instanced) {
			var geom = geometry[0];
			geom.update_instance_buffer(camera.projection_matrix);

			update_texture(g);

			g.setVertexBuffers(geom.vertexbuffers);
			g.setIndexBuffer(geom.indexbuffer);

			_verboser('--draw instanced-- indices: ${geom.instances_count}');
			g.drawIndexedVerticesInstanced(geom.instances_count);
		} else {
			update_texture(g);

			g.setMatrix3(projection_loc, camera.projection_matrix);

			g.setVertexBuffer(vertexbuffer);
			g.setIndexBuffer(indexbuffer);

			_verboser('--draw-- indices: $indices_count');
			g.drawIndexedVertices(0, indices_count);
		}

		vert_count = 0;
		indices_count = 0;

		geometry.splice(0, geometry.length);
		draw_instanced = false;
		draw_calls++;

	}

	function set_vertices(g:Graphics):Bool {

		var m:Matrix;
		var geom = geometry[0];
		var is_poly = geom.geometry_type == GeometryType.polygon;
		var is_textured = geom.texture != null;

		if(!geom.instanced) {

			lock_vbo(vert_count, is_textured);
			lock_ibo(is_poly);

			var n:Int = 0;

			for (_g in geometry) {
				m = _g.transform_matrix;
				for (v in _g.vertices) {
					vertices.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
					vertices.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);
					vertices.set(n++, v.color.r);
					vertices.set(n++, v.color.g);
					vertices.set(n++, v.color.b);
					vertices.set(n++, v.color.a);
					if(is_textured) {
						vertices.set(n++, v.tcoord.x);
						vertices.set(n++, v.tcoord.y);
					}
				}
			}

			if(is_poly) {
				var i:Int = 0;
				n = 0;
				for (_g in geometry) {
					for (ind in _g.indices) {
						indices[i++] = ind + n;
					}
					n += _g.vertices.length;
				}
			}

			unlock_vbo();
			unlock_ibo(is_poly);

		
		} else if(!draw_instanced) {

			if(geom.instances_count <= 0) {
				return false;
			}

			if(vert_count > max_vertices || indices_count > max_indices) {
	            log('WARNING can`t batch a instanced geometry `${geom.name}` with not avaible instanced rendering, to many instances 
	            	verts: (${geom.instances_count * geom.vertices.length} vs max vertices: $max_vertices), 
	            	indices: (${geom.instances_count * geom.indices.length} vs max indices: $max_indices)');
	            vert_count = 0;
	            indices_count = 0;
				return false;
			}

			var bs:Int = geom.instances_count * geom.vertices.length;

			lock_vbo(bs, is_textured);
			lock_ibo(is_poly);

			var m:Matrix;

			var n:Int = 0;
			var i:Int = 0;
			var offset:Int = 0;
			for (inst in geom.instances) {

				geom.update_instance_matrix(inst);
				m = inst.transform_matrix;

				for (v in geom.vertices) {
					vertices.set(n++, m.a * v.pos.x + m.c * v.pos.y + m.tx);
					vertices.set(n++, m.b * v.pos.x + m.d * v.pos.y + m.ty);
					vertices.set(n++, inst.color.r);
					vertices.set(n++, inst.color.g);
					vertices.set(n++, inst.color.b);
					vertices.set(n++, inst.color.a);
					if(is_textured) {
						vertices.set(n++, v.tcoord.x + inst.texture_offset.x);
						vertices.set(n++, v.tcoord.y + inst.texture_offset.y);
					}
				}

				if(is_poly) {
					for (ind in geom.indices) {
						indices[i++] = ind + offset;
					}
					offset += geom.vertices.length;
				}

			}

			unlock_vbo();
			unlock_ibo(is_poly);
		}

		return true;

	}

	inline function lock_vbo(_count:Int, _textured:Bool) {
		
		var p2 = Mathf.require_pow2(_count);
		var l2 = Mathf.log2(p2)-2;

		vertexbuffer = _textured ? buffers_textured[l2] : buffers_colored[l2];
		vertices = vertexbuffer.lock();

	}

	inline function unlock_vbo() {

		vertexbuffer.unlock();

	}

	inline function lock_ibo(is_poly:Bool) {
		
		if(is_poly) {
			indexbuffer = indexbuffer_poly;
			indices = indexbuffer.lock();
		} else {
			indexbuffer = indexbuffer_quad;
		}

	}

	inline function unlock_ibo(is_poly:Bool) {

		if(is_poly) {
			indexbuffer.unlock();
		}

	}


	inline function update_texture(g:Graphics) {
		
		if(last_texture != null) {
			_verboser('update_texture: ${last_texture.id}');
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

		if(layer.blend_src != BlendMode.Undefined && layer.blend_dst != BlendMode.Undefined) {
			sh.blendSource = layer.blend_src;
			sh.alphaBlendDestination = layer.blend_dst;
			sh.alphaBlendSource = layer.blend_src;
			sh.blendDestination = layer.blend_dst;
			sh.blendOperation = layer.blend_eq;
		} else { // set default blend modes
			sh.reset_blendmodes();
		}

	}


}
