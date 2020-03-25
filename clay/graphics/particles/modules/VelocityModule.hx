package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class VelocityModule extends ParticleModule {

	public var initialVelocity(default, null):Vector;
	public var initialVelocityMax:Vector; // variance?
	public var velocityRandom:Vector;

	var _velComps:Components<Velocity>;

	public function new(options:VelocityModuleOptions) {
		super(options);

		initialVelocity = def(options.initialVelocity, new Vector());
		initialVelocityMax = options.initialVelocityMax;
		velocityRandom = options.velocityRandom;
	}

	override function onAdded() {
		_velComps = emitter.components.get(Velocity);
	}

	override function onRemoved() {
		emitter.components.put(_velComps);
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
		var x = initialVelocity.x;
		var y = initialVelocity.y;
		if(initialVelocityMax != null) {
			x = emitter.randomFloat(initialVelocity.x, initialVelocityMax.x);
			y = emitter.randomFloat(initialVelocity.y, initialVelocityMax.y);
		}
		if(!emitter.system.localSpace) {
			v.x = emitter.getRotateX(x, y);
			v.y = emitter.getRotateY(x, y);
		} else {
			v.x = x;
			v.y = y;
		}
	}

	override function update(dt:Float) {
		if(velocityRandom != null) {
			var vrx = velocityRandom.x;
			var vry = velocityRandom.y;
			if(!emitter.system.localSpace) {
				vrx = emitter.getRotateX(velocityRandom.x, velocityRandom.y); // TODO: maybe disable transformation for random
				vry = emitter.getRotateY(velocityRandom.x, velocityRandom.y);
			}
			var v:Velocity;
			for (p in particles) {
				v = _velComps.get(p.id);
				v.x += vrx * emitter.random1To1();
				v.y += vry * emitter.random1To1();
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
	
	?initialVelocity:Vector,
	?initialVelocityMax:Vector,
	?velocityRandom:Vector,

}


