package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.RotationDelta;


class RotationLifeModule extends ParticleModule {


	public var initialRotation:Float;
	public var initialRotationMax:Float;
	public var endRotation:Float;
	public var endRotationMax:Float;
	public var rotationRandom:Float;

	var rotationDelta:Components<RotationDelta>;


	public function new(_options:RotationLifeModuleOptions) {

		super(_options);

		initialRotation = _options.initialRotation != null ? _options.initialRotation : 0;
		initialRotationMax = _options.initialRotationMax != null ? _options.initialRotationMax : 0;
		endRotation = _options.endRotation != null ? _options.endRotation : 1;
		endRotationMax = _options.endRotationMax != null ? _options.endRotationMax : 0;
		rotationRandom = _options.rotationRandom != null ? _options.rotationRandom : 0;

	}

	override function init() {

		rotationDelta = emitter.components.get(RotationDelta);

	}

	override function onDisabled() {
		
		for (p in particles) {
			p.r = 0;
		}

	}

	override function onSpawn(p:Particle) {

		if(initialRotationMax != 0) {
			p.r = emitter.randomFloat(initialRotation, initialRotationMax) * 360;
		} else {
			p.r = initialRotation * 360;
		}

		if(endRotationMax != 0) {
			rotationDelta.get(p.id).value = emitter.randomFloat(endRotation, endRotationMax) * 360 - p.r;
		} else {
			rotationDelta.get(p.id).value = endRotation * 360 - p.r;
		}

		if(rotationDelta.get(p.id).value != 0) {
			rotationDelta.get(p.id).value /= p.lifetime;
		}

	}
	
	override function update(dt:Float) {

		if(rotationRandom > 0) {
			for (p in particles) {
				if(rotationDelta.get(p.id).value != 0) {
					p.r += rotationDelta.get(p.id).value * dt;
				}
				p.r += rotationRandom * 360 * emitter.random1To1() * dt;
			}
		} else {
			for (p in particles) {
				if(rotationDelta.get(p.id).value != 0) {
					p.r += rotationDelta.get(p.id).value * dt;
				}
			}
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialRotation = d.initialRotation;
		initialRotationMax = d.initialRotationMax;
		endRotation = d.endRotation;
		endRotationMax = d.endRotationMax;
		rotationRandom = d.rotationRandom;
		
		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialRotation = initialRotation;
		d.initialRotationMax = initialRotationMax;
		d.endRotation = endRotation;
		d.endRotationMax = endRotationMax;
		d.rotationRandom = rotationRandom;

		return d;
	    
	}


}


typedef RotationLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialRotation : Float;
	@:optional var initialRotationMax : Float;
	@:optional var endRotation : Float;
	@:optional var endRotationMax : Float;
	@:optional var rotationRandom : Float;

}


