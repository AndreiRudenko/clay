package clay.render.renderers;


import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;


import clay.graphics.Mesh;
import clay.graphics.particles.ParticleSystem;
import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.core.Particle;
import clay.render.Camera;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.utils.ArrayTools;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.math.Vector;
import clay.utils.Mathf;


class ParticlesRenderer extends ObjectRenderer {


	var g:Graphics;

	var _quads_total:Int = 0;
	var _quads_draw:Int = 0;
	var _quads_max:Int = 0;
	var _buffer_index:Int = 0;

	var _emitters:Array<ParticleEmitter>;
	var m:Matrix;

	var _shader:Shader;
	var _texture:Texture;
	var _clip_rect:Rectangle;
	var _region_scaled:Rectangle;

	var _vertexbuffer:VertexBuffer;
	var _indexbuffer:IndexBuffer;

	var _texture_loc:TextureUnit;

	var _blend_src:BlendMode;
	var _blend_dst:BlendMode;
	var _blend_op:BlendEquation;

	var _alpha_blend_dst:BlendMode;
	var _alpha_blend_src:BlendMode;
	var _alpha_blend_op:BlendEquation;


	public function new(renderpath:RenderPath) {

		super(renderpath);

    	_emitters = [];
    	_quads_max = Std.int(renderpath.max_vertices / 4);

		_indexbuffer = new IndexBuffer(_quads_max * 6, Usage.StaticUsage);
		var indices = _indexbuffer.lock();
		for (i in 0..._quads_max) {
			indices[i * 3 * 2 + 0] = i * 4 + 0;
			indices[i * 3 * 2 + 1] = i * 4 + 1;
			indices[i * 3 * 2 + 2] = i * 4 + 2;
			indices[i * 3 * 2 + 3] = i * 4 + 0;
			indices[i * 3 * 2 + 4] = i * 4 + 2;
			indices[i * 3 * 2 + 5] = i * 4 + 3;
		}
		_indexbuffer.unlock();

		m = new Matrix();
		_region_scaled = new Rectangle();

	}

	override function start() {
		
		_shader = null;
		_texture = null;
		_clip_rect = null;
		g = renderpath.g;

	}

	override function end() {

		flush();
		
	}

	public function render(ps:ParticleSystem) {

		for (em in ps.emitters) {

			if(em.particles.length == 0) {
				continue;
			}

			if(_shader != ps.shader 
				|| _texture != em.texture
				|| !check_blendmode(em)
				|| _clip_rect != null && !_clip_rect.equals(ps.clip_rect)
			) {
				flush();
			}

			_emitters.push(em);

			_shader = ps.shader;
			_texture = em.texture;
			_clip_rect = ps.clip_rect;

			_blend_src = em.blend_src; 
			_blend_dst = em.blend_dst; 
			_blend_op = em.blend_eq;

			_alpha_blend_src = em.alpha_blend_src;
			_alpha_blend_dst = em.alpha_blend_dst;
			_alpha_blend_op = em.alpha_blend_eq;

			_quads_total += em.particles.length;

			#if !no_debug_console
			renderpath.stats.vertices += em.particles.length * 4;
			renderpath.stats.indices += em.particles.length * 6;
			#end

		}

		
	}

	function flush() {

		if(_quads_total == 0) {
			_verboser('nothing draw, _quads_total == 0');
			return;
		}

		upload_buffer();
		draw_buffer();

		ArrayTools.clear(_emitters);

	}

	function draw_buffer() {

		renderpath.clip(_clip_rect);

		if(_texture == null) {
			_texture = renderpath.texture_blank;
		}

		_texture_loc = _shader.set_texture('tex', _texture).location;
		_shader.set_matrix3('mvpMatrix', renderpath.camera.projection_matrix);

		_shader.set_blendmode(
			_blend_src, _blend_dst, _blend_op, 
			_alpha_blend_src, _alpha_blend_dst, _alpha_blend_op
		);

		_shader.use(g);
		_shader.apply(g);

		g.setVertexBuffer(_vertexbuffer);
		g.setIndexBuffer(_indexbuffer);

		g.drawIndexedVertices(0, _quads_draw * 6);

		g.setTexture(_texture_loc, null);

		_quads_total -= _quads_draw;
		_quads_draw = 0;
		_buffer_index = 0;

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end

	}

	function upload_buffer() {

		_vertexbuffer = renderpath.get_buffer(_quads_total * 4);
		var vertices = _vertexbuffer.lock();

		var particles:haxe.ds.Vector<Particle>;
		var pd:Particle;

		for (em in _emitters) {
			set_region(em.region, _texture);
			particles = em.get_sorted_particles();
			for (i in 0...em.particles.length) {
				pd = particles[i];
				if(_quads_draw + 1 > _quads_max) {
					_vertexbuffer.unlock();
					// _indexbuffer.unlock(_quads_draw * 6);
					draw_buffer();
					_vertexbuffer = renderpath.get_buffer(_quads_total * 4);
					vertices = _vertexbuffer.lock();
				}
				set_particle_vertices(vertices, pd);
			}	
		}

		_vertexbuffer.unlock();
		// _indexbuffer.unlock(_quads_draw * 6);
		
	}
	
	function set_particle_vertices(data:Float32Array, p:Particle) {

		m.identity()
		.translate(p.x, p.y)
		.rotate(Mathf.radians(-p.r))
		.scale(p.s, p.s);
		
		if(p.centered) {
			m.apply(-p.w * 0.5, -p.h * 0.5);
		} else {
			m.apply(-p.ox, -p.oy);
		}

		var r = p.color.r;
		var g = p.color.g;
		var b = p.color.b;
		var a = p.color.a;

		// v0
		data.set(_buffer_index++, m.tx);
		data.set(_buffer_index++, m.ty);

		data.set(_buffer_index++, r);
		data.set(_buffer_index++, g);
		data.set(_buffer_index++, b);
		data.set(_buffer_index++, a);

		data.set(_buffer_index++, _region_scaled.x);
		data.set(_buffer_index++, _region_scaled.y);

		// v1
		data.set(_buffer_index++, m.a * p.w + m.tx);
		data.set(_buffer_index++, m.b * p.w + m.ty);

		data.set(_buffer_index++, r);
		data.set(_buffer_index++, g);
		data.set(_buffer_index++, b);
		data.set(_buffer_index++, a);

		data.set(_buffer_index++, _region_scaled.x + _region_scaled.w);
		data.set(_buffer_index++, _region_scaled.y);

		// v2
		data.set(_buffer_index++, m.a * p.w + m.c * p.h + m.tx);
		data.set(_buffer_index++, m.b * p.w + m.d * p.h + m.ty);

		data.set(_buffer_index++, r);
		data.set(_buffer_index++, g);
		data.set(_buffer_index++, b);
		data.set(_buffer_index++, a);

		data.set(_buffer_index++, _region_scaled.x + _region_scaled.w);
		data.set(_buffer_index++, _region_scaled.y + _region_scaled.h);

		// v3
		data.set(_buffer_index++, m.c * p.h + m.tx);
		data.set(_buffer_index++, m.d * p.h + m.ty);

		data.set(_buffer_index++, r);
		data.set(_buffer_index++, g);
		data.set(_buffer_index++, b);
		data.set(_buffer_index++, a);

		data.set(_buffer_index++, _region_scaled.x);
		data.set(_buffer_index++, _region_scaled.y + _region_scaled.h);

		_quads_draw++;

	}

	inline function check_blendmode(em:ParticleEmitter):Bool {

		return em.blend_src == _blend_src 
			&& em.blend_dst == _blend_dst 
			&& em.blend_eq == _blend_op
			&& em.alpha_blend_src == _alpha_blend_src
			&& em.alpha_blend_dst == _alpha_blend_dst
			&& em.alpha_blend_eq == _alpha_blend_op;

	}
	

	inline function set_region(region:Rectangle, texture:Texture) {
		
		if(region == null || texture == null) {
			_region_scaled.set(0, 0, 1, 1);
		} else {
			_region_scaled.set(
				_region_scaled.x = region.x / texture.width_actual,
				_region_scaled.y = region.y / texture.height_actual,
				_region_scaled.w = region.w / texture.width_actual,
				_region_scaled.h = region.h / texture.height_actual
			);
		}

	}


}