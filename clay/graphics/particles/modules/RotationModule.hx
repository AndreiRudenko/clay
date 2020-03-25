package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Rotation;
import clay.graphics.particles.components.RotationDelta;
import clay.utils.Log.*;

class RotationModule extends ParticleModule {

	public var initialRotation:Float;
	public var initialRotationMax:Float;
	public var angularVelocity:Float;
	public var angularVelocityMax:Float;
	public var rotationRandom:Float;

	var _rotation:Components<Rotation>;
	var _rotationDelta:Components<RotationDelta>;

	public function new(options:RotationModuleOptions) {
		super(options);

		initialRotation = def(options.initialRotation, 0);
		initialRotationMax = def(options.initialRotationMax, 0);
		angularVelocity = def(options.angularVelocity, 180);
		angularVelocityMax = def(options.angularVelocityMax, 0);
		rotationRandom = def(options.rotationRandom, 0);
	}

	override function onAdded() {
		_rotation = emitter.components.get(Rotation);
		_rotationDelta = emitter.components.get(RotationDelta);
	}

	override function onRemoved() {
		emitter.components.put(_rotation);
		emitter.components.put(_rotationDelta);
		_rotation = null;
		_rotationDelta = null;
	}

	override function onDisabled() {
		for (p in particles) {
			_rotation.set(p.id, 0);
		}
	}

	override function onSpawn(p:Particle) {
		if(initialRotationMax != 0) {
			_rotation.set(p.id, emitter.randomFloat(initialRotation, initialRotationMax));
		} else {
			_rotation.set(p.id, initialRotation);
		}

		if(angularVelocityMax != 0) {
			_rotationDelta.set(p.id, emitter.randomFloat(angularVelocity, angularVelocityMax));
		} else {
			_rotationDelta.set(p.id, angularVelocity);
		}
	}
	
	override function update(dt:Float) {
		var rd:Float;
		var r:Float;
		if(rotationRandom > 0) {
			for (p in particles) {
				r = _rotation.get(p.id);
				rd = _rotationDelta.get(p.id);
				if(rd != 0) {
					r += rd * dt;
				}
				r += rotationRandom * emitter.random1To1() * dt;
				_rotation.set(p.id, r);
			}
		} else {
			for (p in particles) {
				rd = _rotationDelta.get(p.id);
				if(rd != 0) {
					r = _rotation.get(p.id);
					r += rd * dt;
					_rotation.set(p.id, r);

				}
			}
		}
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		initialRotation = d.initialRotation;
		initialRotationMax = d.initialRotationMax;
		angularVelocity = d.angularVelocity;
		angularVelocityMax = d.angularVelocityMax;
		rotationRandom = d.rotationRandom;
		
		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.initialRotation = initialRotation;
		d.initialRotationMax = initialRotationMax;
		d.angularVelocity = angularVelocity;
		d.angularVelocityMax = angularVelocityMax;
		d.rotationRandom = rotationRandom;

		return d;
	}

}

typedef RotationModuleOptions = {

	>ParticleModuleOptions,
	
	?initialRotation:Float,
	?initialRotationMax:Float,
	?angularVelocity:Float,
	?angularVelocityMax:Float,
	?rotationRandom:Float,

}


