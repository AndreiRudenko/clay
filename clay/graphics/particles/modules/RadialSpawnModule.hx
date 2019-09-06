package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;


class RadialSpawnModule  extends ParticleModule {


	public var radius:Float;


	public function new(_options:RadialSpawnModuleOptions) {

		super(_options);

		radius = _options.radius != null ? _options.radius : 128;

		_priority = -999;
		
	}

	override function onspawn(p:Particle) {

		var a = emitter.random() * Math.PI * 2;
		var r = emitter.random() * radius;

		p.x = emitter.system.pos.x + emitter.pos.x + Math.cos(a) * r;
		p.y = emitter.system.pos.y + emitter.pos.y + Math.sin(a) * r;

	}

// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		radius = d.radius;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.radius = radius;

		return d;
	    
	}


}


typedef RadialSpawnModuleOptions = {

	>ParticleModuleOptions,

	@:optional var radius:Float;

}


