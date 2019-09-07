package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.Sprite;
import clay.graphics.shapes.Quad;
import clay.utils.Mathf;
import clay.math.Vector;
import clay.render.Color;
import clay.render.Vertex;
import clay.math.Rectangle;
import clay.math.Transform;
import clay.math.Matrix;
import clay.render.Painter;
import clay.resources.Texture;


class SpriteRenderModule extends ParticleModule {


	public var texture:Texture;
	public var region:Rectangle;
	var _matrix:Matrix;
	var _region_scaled:Rectangle;
	var _count:Int;


	public function new(options:SpriteRenderModuleOptions) {

		super({});

		texture = options.texture;
		region = options.region;
		_count = 0;
		_matrix = new Matrix();
		_region_scaled = new Rectangle();

	}

	override function render(g:Painter) {

		g.set_texture(texture);
		update_region_scaled();

		var p:Particle;

		var particles = emitter.get_sorted_particles();
		var m = _matrix;
		var emitter_matrix = emitter.system.transform.world.matrix;

		_count = emitter.particles.length;

		for (i in 0..._count) {
			g.ensure(4, 6);

			p = particles[i];

			m.copy(emitter_matrix)
			.translate(p.x, p.y)
			.rotate(Mathf.radians(-p.r))
			.scale(p.s, p.s);

			if(p.centered) {
				m.apply(-p.w * 0.5, -p.h * 0.5);
			} else {
				m.apply(-p.ox, -p.oy);
			}

			g.add_index(0);
			g.add_index(1);
			g.add_index(2);
			g.add_index(0);
			g.add_index(2);
			g.add_index(3);

			g.add_vertex(
				m.tx, 
				m.ty, 
				_region_scaled.x,
				_region_scaled.y,
				p.color
			);

			g.add_vertex(
				m.a * p.w + m.tx, 
				m.b * p.w + m.ty, 
				_region_scaled.x + _region_scaled.w,
				_region_scaled.y,
				p.color
			);

			g.add_vertex(
				m.a * p.w + m.c * p.h + m.tx, 
				m.b * p.w + m.d * p.h + m.ty, 
				_region_scaled.x + _region_scaled.w,
				_region_scaled.y + _region_scaled.h,
				p.color
			);

			g.add_vertex(
				m.c * p.h + m.tx, 
				m.d * p.h + m.ty, 
				_region_scaled.x,
				_region_scaled.y + _region_scaled.h,
				p.color
			);

		}

	}

	inline function update_region_scaled() {
		
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


typedef SpriteRenderModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var texture:Texture;
	@:optional var region:Rectangle;

}

