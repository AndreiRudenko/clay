package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;


class RadialEdgeSpawnModule  extends ParticleModule {


	public var radius:Float;
	public var radius_max:Float;


	public function new(_options:RadialEdgeSpawnModuleModuleOptions) {

		super(_options);

		radius = _options.radius != null ? _options.radius : 64;
		radius_max = _options.radius_max != null ? _options.radius_max : 128;

		_priority = -999;
		
	}

	override function onspawn(p:Particle) {

		var a = emitter.random() * Math.PI * 2;
		var r = emitter.random_float(radius, radius_max);

		p.x = emitter.system.pos.x + emitter.pos.x + Math.cos(a) * r;
		p.y = emitter.system.pos.y + emitter.pos.y + Math.sin(a) * r;

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		radius = d.radius;
		radius_max = d.radius_max;
		
		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.radius = radius;
		d.radius_max = radius_max;

		return d;
	    
	}


}


typedef RadialEdgeSpawnModuleModuleOptions = {

	>ParticleModuleOptions,

	@:optional var radius:Float;
	@:optional var radius_max:Float;

}


