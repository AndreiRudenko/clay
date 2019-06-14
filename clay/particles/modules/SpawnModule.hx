package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;


class SpawnModule extends ParticleModule {


	public function new(?_options:ParticleModuleOptions) {

		super(_options);

		_priority = -999;

	}

	override function onspawn(pd:Particle) {

		pd.x = emitter.system.pos.x + emitter.pos.x;
		pd.y = emitter.system.pos.y + emitter.pos.y;

	}


}


