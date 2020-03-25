package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;


class SpawnModule extends ParticleModule {

	public function new(?options:ParticleModuleOptions) {
		super(options);

		_priority = -999;
	}

	override function onSpawn(p:Particle) {
		if(emitter.system.localSpace) {
			p.x = 0;
			p.y = 0;
		} else {
			// p.x = emitter.getTransformX(0,0);
			// p.y = emitter.getTransformY(0,0);
			p.x = emitter.transform.world.matrix.tx;
			p.y = emitter.transform.world.matrix.ty;
		}
	}

}


