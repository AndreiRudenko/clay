package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Rotation;
import clay.graphics.particles.components.RotationDelta;
import clay.graphics.particles.components.Velocity;
import clay.utils.Mathf;


class RotationBySpeedModule extends ParticleModule {


	public var initialRotation:Float;
	public var initialRotationMax:Float;
	public var angularVelocity:Float;
	public var angularVelocityMax:Float;

	public var minSpeed:Float;
	public var maxSpeed:Float;

	var _velocity:Components<Velocity>;
	var _rotation:Components<Rotation>;
	var _rotationDelta:Components<RotationDelta>;




	public function new(options:RotationBySpeedModuleOptions) {

		super(options);

		initialRotation = options.initialRotation != null ? options.initialRotation : 0;
		initialRotationMax = options.initialRotationMax != null ? options.initialRotationMax : 0;
		angularVelocity = options.angularVelocity != null ? options.angularVelocity : 180;
		angularVelocityMax = options.angularVelocityMax != null ? options.angularVelocityMax : 0;

		minSpeed = options.minSpeed != null ? options.minSpeed : 0;
		maxSpeed = options.maxSpeed != null ? options.maxSpeed : 1;

	}

	override function init() {

		_velocity = emitter.components.get(Velocity);
		_rotation = emitter.components.get(Rotation);
		_rotationDelta = emitter.components.get(RotationDelta);
	    
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
		for (p in particles) {
			rd = _rotationDelta.get(p.id);
			if(rd != 0) {
				_rotation.set(p.id, _rotation.get(p.id) + getRotationDeltaFromVelocity(rd, _velocity.get(p.id)) * dt);
			}
		}
	}
	
	inline function getRotationDeltaFromVelocity(rd:RotationDelta, vel:Velocity) {

		var lenSq = vel.lengthSq;
		var minSpeedSq = minSpeed * minSpeed;
		var maxSpeedSq = maxSpeed * maxSpeed;
		var t:Float = 0;

		if(maxSpeed - minSpeedSq != 0) {
			t = Mathf.inverseLerp(minSpeedSq, maxSpeedSq, lenSq);
		}

		return rd * t;
		
	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialRotation = d.initialRotation;
		initialRotationMax = d.initialRotationMax;
		angularVelocity = d.angularVelocity;
		angularVelocityMax = d.angularVelocityMax;
		minSpeed = d.minSpeed;
		maxSpeed = d.maxSpeed;
		
		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialRotation = initialRotation;
		d.initialRotationMax = initialRotationMax;
		d.angularVelocity = angularVelocity;
		d.angularVelocityMax = angularVelocityMax;
		d.minSpeed = minSpeed;
		d.maxSpeed = maxSpeed;

		return d;
	    
	}


}


typedef RotationBySpeedModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialRotation:Float;
	@:optional var initialRotationMax:Float;
	@:optional var angularVelocity:Float;
	@:optional var angularVelocityMax:Float;
	@:optional var minSpeed:Float;
	@:optional var maxSpeed:Float;


}


