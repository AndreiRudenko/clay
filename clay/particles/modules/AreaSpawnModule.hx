package clay.particles.modules;


import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class AreaSpawnModule extends ParticleModule {


	public var size(default, null):Vector;


	public function new(_options:AreaSpawnModuleOptions) {

		super(_options);

		size = _options.size != null ? _options.size : new Vector(128, 128);

		_priority = -999;
		
	}

	override function onspawn(p:Particle) {

		p.x = emitter.system.pos.x + emitter.pos.x + (size.x * 0.5 * emitter.random_1_to_1());
		p.y = emitter.system.pos.y + emitter.pos.y + (size.y * 0.5 * emitter.random_1_to_1());

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
