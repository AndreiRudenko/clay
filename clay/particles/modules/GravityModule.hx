package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.Components;
import clay.particles.components.Velocity;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class GravityModule extends ParticleModule {


	public var gravity(default, null):Vector;

	var vel_comps:Components<Velocity>;


	public function new(_options:GravityModuleOptions) {

		super(_options);

		gravity = _options.gravity != null ? _options.gravity : new Vector(0, 98);

	}

	override function init() {

		vel_comps = emitter.components.get(Velocity);

	}

	override function onremoved() {

		vel_comps = null;
		
	}

	override function ondisabled() {

		particles.for_each(
			function(p) {
				vel_comps.get(p.id).set(0,0);
			}
		);
		
	}

	override function onunspawn(p:Particle) {

		vel_comps.get(p.id).set(0,0);
		
	}

	override function update(dt:Float) {

		var vel:Vector;
		for (p in particles) {
			vel = vel_comps.get(p.id);
			vel.x += gravity.x * dt;
			vel.y += gravity.y * dt;
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		gravity.from_json(d.gravity);

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.gravity = gravity.to_json();

		return d;
	    
	}


}


typedef GravityModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var gravity : Vector;

}


