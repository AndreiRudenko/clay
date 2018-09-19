package clay.particles.modules.helpers;

import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleData;
import clay.particles.core.Components;
import clay.particles.components.Velocity;

/*
	don't add this module manually to emitter, only from modules that have Velocity
 */

class VelocityUpdateModule extends ParticleModule {


	var vel_comps:Components<Velocity>;
	var particles_data:Array<ParticleData>;


	public function new() {

		super({});

		_priority = 999;

	}

	override function init() {
		
		vel_comps = emitter.components.get(Velocity);

		if(vel_comps == null) {
			vel_comps = emitter.components.set(
				particles, 
				Velocity, 
				function() {
					return new Velocity();
				}
			);
		}
		
		particles_data = emitter.particles_data;
	    
	}

	override function update(dt:Float) {

		var v:Velocity;
		var pd:ParticleData;
		for (p in particles) {
			v = vel_comps.get(p);
			pd = particles_data[p.id];

			pd.x += v.x * dt;
			pd.y += v.y * dt;
		}

	}


}
