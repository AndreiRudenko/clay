package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleData;
import clay.particles.core.ParticleModule;
import clay.particles.core.Components;
import clay.math.Vector;


class AreaSpawnModule extends ParticleModule {


	public var size(default, null):Vector;


	public function new(_options:AreaSpawnModuleOptions) {

		super(_options);

		size = _options.size != null ? _options.size : new Vector(128, 128);

		_priority = -999;
		
	}

	override function onspawn(p:Particle) {

		var pd:ParticleData = emitter.show_particle(p);

		pd.x = emitter.system.position.x + emitter.position.x + (size.x * 0.5 * emitter.random_1_to_1());
		pd.y = emitter.system.position.y + emitter.position.y + (size.y * 0.5 * emitter.random_1_to_1());

	}

	override function onunspawn(p:Particle) {

		emitter.hide_particle(p);

	}

// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		size.from_json(d.size);

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.size = size.to_json();

		return d;
	    
	}


}

typedef AreaSpawnModuleOptions = {

	>ParticleModuleOptions,

	@:optional var size:Vector;

}
