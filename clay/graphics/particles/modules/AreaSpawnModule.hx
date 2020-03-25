package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class AreaSpawnModule extends ParticleModule {

	public var size(default, null):Vector;

	public function new(options:AreaSpawnModuleOptions) {
		super(options);

		size = def(options.size, new Vector(128, 128));

		_priority = -999;
	}

	override function onSpawn(p:Particle) {
		var x = size.x * 0.5 * emitter.random1To1();
		var y = size.y * 0.5 * emitter.random1To1();

		if(emitter.system.localSpace) {
			p.x = x;
			p.y = y;
		} else {
			p.x = emitter.getTransformX(x, y);
			p.y = emitter.getTransformY(x, y);
		}
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

	?size:Vector

}
