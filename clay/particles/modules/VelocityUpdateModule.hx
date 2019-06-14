package clay.particles.modules;

import clay.particles.core.ParticleModule;
import clay.particles.core.Particle;
import clay.particles.core.Components;
import clay.particles.components.Velocity;
import clay.math.Mathf;
import clay.math.Vector;
import clay.math.Rectangle;


class VelocityUpdateModule extends ParticleModule {


	public var damping:Float = 0;

	var vel_comps:Components<Velocity>;


	public function new(options:VelocityUpdateModuleOptions) {

		super({});

		damping = options.damping != null ? options.damping : 0;

	}

	override function init() {
		
		vel_comps = emitter.components.get(Velocity);
		
	}

	override function update(dt:Float) {

		var v:Velocity;
		var pd:Particle;
		for (p in particles) {
			v = vel_comps.get(p.id);
			v.multiply_scalar(Mathf.clamp(1 - dt * damping, 0, 1));
			p.x += v.x * dt;
			p.y += v.y * dt;
		}

	}


}


typedef VelocityUpdateModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var damping:Float;

}

