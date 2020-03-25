package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.VelocityDelta;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class ForceLifeModule extends ParticleModule {

	public var initialForce(default, null):Vector;
	public var initialForceMax:Vector;
	public var endForce(default, null):Vector;
	public var endForceMax:Vector;

	public var forceRandom:Vector;

	var _velComps:Components<Velocity>;
	var _velocityDelta:Components<VelocityDelta>;

	public function new(options:ForceLifeModuleOptions) {
		super(options);

		initialForce = def(options.initialForce, new Vector());
		initialForceMax = options.initialForceMax;
		endForce = def(options.endForce, new Vector());
		endForceMax = options.endForceMax;

		forceRandom = options.forceRandom;
	}

	override function onAdded() {
		_velComps = emitter.components.get(Velocity);
		_velocityDelta = emitter.components.get(VelocityDelta);
	}

	override function onRemoved() {
		emitter.components.put(_velComps);
		emitter.components.put(_velocityDelta);
		_velComps = null;
		_velocityDelta = null;
	}

	override function onDisabled() {
		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
	}

	override function onSpawn(p:Particle) {
		var initVelX = 0.0;
		var initVelY = 0.0;
		var velDelta = _velocityDelta.get(p.id);
		if(initialForceMax != null) {
			initVelX = emitter.randomFloat(initialForce.x, initialForceMax.x);
			initVelY = emitter.randomFloat(initialForce.y, initialForceMax.y);
		} else {
			initVelX = initialForce.x;
			initVelY = initialForce.y;
		}
		if(endForceMax != null) {
			velDelta.x = emitter.randomFloat(endForce.x, endForceMax.x) - initVelX;
			velDelta.y = emitter.randomFloat(endForce.y, endForceMax.y) - initVelY;
		} else {
			velDelta.x = endForce.x - initVelX;
			velDelta.y = endForce.y - initVelY;
		}

		if(velDelta.lengthSq != 0) {
			velDelta.divideScalar(p.lifetime);
		}
	}

	override function onUnspawn(p:Particle) {
		_velComps.get(p.id).set(0,0);
	}

	override function update(dt:Float) {
		var vel:Velocity;
		var velDelta:VelocityDelta;

		if(forceRandom != null) {
			if(!emitter.system.localSpace) {
				var frx = emitter.getRotateX(forceRandom.x, forceRandom.y);
				var fry = emitter.getRotateY(forceRandom.x, forceRandom.y);

				for (p in particles) {
					vel = _velComps.get(p.id);
					velDelta = _velocityDelta.get(p.id);
					vel.x += emitter.getRotateX(velDelta.x, velDelta.y) * dt + frx * emitter.random1To1() * dt;
					vel.y += emitter.getRotateY(velDelta.x, velDelta.y) * dt + fry * emitter.random1To1() * dt;
				}
			} else {
				for (p in particles) {
					vel = _velComps.get(p.id);
					velDelta = _velocityDelta.get(p.id);
					vel.x += velDelta.x * dt + forceRandom.x * emitter.random1To1() * dt;
					vel.y += velDelta.y * dt + forceRandom.y * emitter.random1To1() * dt;
				}
			}
		} else {
			if(!emitter.system.localSpace) {
				for (p in particles) {
					vel = _velComps.get(p.id);
					velDelta = _velocityDelta.get(p.id);
					vel.x += emitter.getRotateX(velDelta.x, velDelta.y) * dt;
					vel.y += emitter.getRotateY(velDelta.x, velDelta.y) * dt;
				}
			} else {
				for (p in particles) {
					vel = _velComps.get(p.id);
					velDelta = _velocityDelta.get(p.id);
					vel.x += velDelta.x * dt;
					vel.y += velDelta.y * dt;
				}
			}
		}

	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		initialForce.fromJson(d.initialForce);
		endForce.fromJson(d.endForce);

		if(d.initialForceMax != null) {
			if(initialForceMax == null) {
				initialForceMax = new Vector();
			}
			initialForceMax.fromJson(d.initialForceMax);
		}

		if(d.endForceMax != null) {
			if(endForceMax == null) {
				endForceMax = new Vector();
			}
			endForceMax.fromJson(d.endForceMax);
		}

		if(d.forceRandom != null) {
			if(forceRandom == null) {
				forceRandom = new Vector();
			}
			forceRandom.fromJson(d.forceRandom);
		}

		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.initialForce = initialForce.toJson();
		d.endForce = endForce.toJson();

		if(initialForceMax != null) {
			d.initialForceMax = initialForceMax.toJson();
		}

		if(endForceMax != null) {
			d.endForceMax = endForceMax.toJson();
		}

		if(forceRandom != null) {
			d.forceRandom = forceRandom.toJson();
		}

		return d;
	}

}

typedef ForceLifeModuleOptions = {

	>ParticleModuleOptions,
	
	?initialForce:Vector,
	?initialForceMax:Vector,
	?endForce:Vector,
	?endForceMax:Vector,
	?forceRandom:Vector,

}


