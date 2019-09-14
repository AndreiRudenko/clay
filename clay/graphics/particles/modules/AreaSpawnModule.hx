package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class AreaSpawnModule extends ParticleModule {


	public var size(default, null):Vector;


	public function new(_options:AreaSpawnModuleOptions) {

		super(_options);

		size = _options.size != null ? _options.size : new Vector(128, 128);

		_priority = -999;
		
	}

	override function onSpawn(p:Particle) {

		p.x = emitter.system.pos.x + emitter.pos.x + (size.x * 0.5 * emitter.random1To1());
		p.y = emitter.system.pos.y + emitter.pos.y + (size.y * 0.5 * emitter.random1To1());

	}

// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		size.fromJson(d.size);

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.size = size.toJson();

		return d;
	    
	}


}

typedef AreaSpawnModuleOptions = {

	>ParticleModuleOptions,

	@:optional var size:Vector;

}
