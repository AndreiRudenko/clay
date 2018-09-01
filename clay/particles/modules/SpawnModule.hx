package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleData;
import clay.particles.core.ParticleModule;


class SpawnModule extends ParticleModule {


	public function new(_options:ParticleModuleOptions) {

		super(_options);

		_priority = -999;

	}

	override function onspawn(p:Particle) {

		var pd:ParticleData = emitter.show_particle(p);

		pd.x = emitter.system.position.x + emitter.position.x;
		pd.y = emitter.system.position.y + emitter.position.y;

	}

	override function onunspawn(p:Particle) {

		emitter.hide_particle(p);

	}


}


