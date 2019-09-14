package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class VelocityModule extends ParticleModule {


	public var initialVelocity(default, null):Vector;
	public var initialVelocityMax:Vector; // variance?
	public var velocityRandom:Vector;

	var _velComps:Components<Velocity>;


	public function new(_options:VelocityModuleOptions) {

		super(_options);

		initialVelocity = _options.initialVelocity != null ? _options.initialVelocity : new Vector();
		initialVelocityMax = _options.initialVelocityMax;
		velocityRandom = _options.velocityRandom;

	}

	override function init() {

		_velComps = emitter.components.get(Velocity);

	}

	override function onRemoved() {

		_velComps = null;
		
	}

	override function onDisabled() {

		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
		
	}
	
	override function onSpawn(p:Particle) {

		var v:Velocity = _velComps.get(p.id);
		if(initialVelocityMax != null) {
			v.x = emitter.randomFloat(initialVelocity.x, initialVelocityMax.x);
			v.y = emitter.randomFloat(initialVelocity.y, initialVelocityMax.y);
		} else {
			v.x = initialVelocity.x;
			v.y = initialVelocity.y;
		}

	}

	override function update(dt:Float) {

		if(velocityRandom != null) {
			var v:Velocity;
			for (p in particles) {
				v = _velComps.get(p.id);
				v.x += velocityRandom.x * emitter.random1To1();
				v.y += velocityRandom.y * emitter.random1To1();
				// update position
			}
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialVelocity.fromJson(d.initialVelocity);

		if(d.initialVelocityMax != null) {
			if(initialVelocityMax == null) {
				initialVelocityMax = new Vector();
			}
			initialVelocityMax.fromJson(d.initialVelocityMax);
		}
		
		if(d.velocityRandom != null) {
			if(velocityRandom == null) {
				velocityRandom = new Vector();
			}
			velocityRandom.fromJson(d.velocityRandom);
		}

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialVelocity = initialVelocity.toJson();

		if(initialVelocityMax != null) {
			d.initialVelocityMax = initialVelocityMax.toJson();
		}

		if(velocityRandom != null) {
			d.velocityRandom = velocityRandom.toJson();
		}

		return d;
	    
	}


}


typedef VelocityModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialVelocity : Vector;
	@:optional var initialVelocityMax : Vector;
	@:optional var velocityRandom : Vector;

}


