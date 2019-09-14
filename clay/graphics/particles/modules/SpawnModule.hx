package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;


class SpawnModule extends ParticleModule {


	public function new(?_options:ParticleModuleOptions) {

		super(_options);

		_priority = -999;

	}

	override function onSpawn(pd:Particle) {

		pd.x = emitter.system.pos.x + emitter.pos.x;
		pd.y = emitter.system.pos.y + emitter.pos.y;

	}


}


