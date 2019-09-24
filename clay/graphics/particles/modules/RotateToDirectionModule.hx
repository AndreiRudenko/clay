package clay.graphics.particles.modules;


import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.Rotation;
import clay.utils.Mathf;


class RotateToDirectionModule extends ParticleModule {


	public var rotation:Float;

	var _rotation:Components<Rotation>;
	var _velocity:Components<Velocity>;


	public function new(_options:RotateToDirectionModuleOptions) {

		super(_options);

		rotation = _options.rotation != null ? _options.rotation : 0;

	}

	override function init() {

		_rotation = emitter.components.get(Rotation);
		_velocity = emitter.components.get(Velocity);
	    
	}

	override function onSpawn(p:Particle) {

		setRotationFromVelocity(p, _velocity.get(p.id));

	}


	override function update(dt:Float) {

		for (p in particles) {
			setRotationFromVelocity(p, _velocity.get(p.id));
		}

	}

	inline function setRotationFromVelocity(p:Particle, vel:Velocity) {

		_rotation.set(p.id, Mathf.degrees((Math.atan2(vel.y, vel.x))) + rotation);
		
	}

// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		rotation = d.rotation;

		return this;

	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.rotation = rotation;
		return d;

	}


}

typedef RotateToDirectionModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var rotation:Float;

}


