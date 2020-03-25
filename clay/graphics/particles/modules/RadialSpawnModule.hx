package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;
import clay.utils.Log.*;

class RadialSpawnModule extends ParticleModule {

	public var radius:Float;

	public function new(options:RadialSpawnModuleOptions) {
		super(options);
		radius = def(options.radius, 128);
		_priority = -999;
	}

	override function onSpawn(p:Particle) {
		var a = emitter.random() * Math.PI * 2;
		var r = emitter.random() * radius;

		var x = Math.cos(a) * r;
		var y = Math.sin(a) * r;

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
		radius = d.radius;
		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();
		d.radius = radius;
		return d;
	}

}


typedef RadialSpawnModuleOptions = {

	>ParticleModuleOptions,

	?radius:Float,

}
