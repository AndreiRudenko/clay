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
	var _regionScaled:Rectangle;
	var _count:Int;


	public function new(options:SpriteRenderModuleOptions) {

		super({});

		texture = options.texture;
		region = options.region;
		_count = 0;
		_matrix = new Matrix();
		_regionScaled = new Rectangle();

	}

	override function render(g:Painter) {

		g.setTexture(texture);
		updateRegionScaled();

		var p:Particle;

		var particles = emitter.getSortedParticles();
		var m = _matrix;
		var emitterMatrix = emitter.system.transform.world.matrix;

		_count = emitter.particles.length;

		for (i in 0..._count) {
			g.ensure(4, 6);

			p = particles[i];

			m.copy(emitterMatrix)
			.translate(p.x, p.y)
			.rotate(Mathf.radians(-p.r))
			.scale(p.s, p.s);

			if(p.centered) {
				m.apply(-p.w * 0.5, -p.h * 0.5);
			} else {
				m.apply(-p.ox, -p.oy);
			}

			g.addIndex(0);
			g.addIndex(1);
			g.addIndex(2);
			g.addIndex(0);
			g.addIndex(2);
			g.addIndex(3);

			g.addVertex(
				m.tx, 
				m.ty, 
				_regionScaled.x,
				_regionScaled.y,
				p.color
			);

			g.addVertex(
				m.a * p.w + m.tx, 
				m.b * p.w + m.ty, 
				_regionScaled.x + _regionScaled.w,
				_regionScaled.y,
				p.color
			);

			g.addVertex(
				m.a * p.w + m.c * p.h + m.tx, 
				m.b * p.w + m.d * p.h + m.ty, 
				_regionScaled.x + _regionScaled.w,
				_regionScaled.y + _regionScaled.h,
				p.color
			);

			g.addVertex(
				m.c * p.h + m.tx, 
				m.d * p.h + m.ty, 
				_regionScaled.x,
				_regionScaled.y + _regionScaled.h,
				p.color
			);

		}

	}

	inline function updateRegionScaled() {
		
		if(region == null || texture == null) {
			_regionScaled.set(0, 0, 1, 1);
		} else {
			_regionScaled.set(
				_regionScaled.x = region.x / texture.widthActual,
				_regionScaled.y = region.y / texture.heightActual,
				_regionScaled.w = region.w / texture.widthActual,
				_regionScaled.h = region.h / texture.heightActual
			);
		}

	}


}


typedef SpriteRenderModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var texture:Texture;
	@:optional var region:Rectangle;

}

