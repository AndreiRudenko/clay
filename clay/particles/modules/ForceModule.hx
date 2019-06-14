package clay.particles.modules;

import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.core.Components;
import clay.particles.components.Velocity;
import clay.math.Vector;

using clay.particles.utils.VectorExtender;


class ForceModule extends ParticleModule {


	public var force(default, null):Vector;
	public var force_random:Vector;

	var vel_comps:Components<Velocity>;


	public function new(_options:ForceModuleOptions) {

		super(_options);

		force = _options.force != null ? _options.force : new Vector();
		force_random = _options.force_random;

	}

	override function init() {

		vel_comps = emitter.components.get(Velocity);

	}

	override function ondisabled() {
		
		particles.for_each(
			function(p) {
				vel_comps.get(p.id).set(0,0);
			}
		);
		
	}
	
	override function onremoved() {

		emitter.remove_module(VelocityUpdateModule);
		vel_comps = null;
		
	}

	override function onunspawn(p:Particle) {

		vel_comps.get(p.id).set(0,0);
		
	}

	override function update(dt:Float) {

		var vel:Vector;
		for (p in particles) {
			vel = vel_comps.get(p.id);
			vel.x += force.x * dt;
			vel.y += force.y * dt;
			if(force_random != null) {
				vel.x += force_random.x * emitter.random_1_to_1() * dt;
				vel.y += force_random.y * emitter.random_1_to_1() * dt;
			}
		}

	}


// import/export

	override function from_json(d:Dynamic) {

		super.from_json(d);

		force.from_json(d.force);

		if(d.force_random != null) {
			if(force_random == null) {
				force_random = new Vector();
			}
			force_random.from_json(d.force_random);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		d.force = force.to_json();

		if(force_random != null) {
			d.force_random = force_random.to_json();
		}

		return d;
	    
	}


}


typedef ForceModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var force : Vector;
	@:optional var force_random : Vector;

}


