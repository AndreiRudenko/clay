package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class ForceModule extends ParticleModule {


	public var force(default, null):Vector;
	public var forceRandom:Vector;

	var _velComps:Components<Velocity>;


	public function new(_options:ForceModuleOptions) {

		super(_options);

		force = _options.force != null ? _options.force : new Vector();
		forceRandom = _options.forceRandom;

	}

	override function init() {

		_velComps = emitter.components.get(Velocity);

	}

	override function onDisabled() {
		
		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
		
	}
	
	override function onRemoved() {

		emitter.removeModule(VelocityUpdateModule);
		_velComps = null;
		
	}

	override function onUnSpawn(p:Particle) {

		_velComps.get(p.id).set(0,0);
		
	}

	override function update(dt:Float) {

		var vel:Vector;
		for (p in particles) {
			vel = _velComps.get(p.id);
			vel.x += force.x * dt;
			vel.y += force.y * dt;
			if(forceRandom != null) {
				vel.x += forceRandom.x * emitter.random1To1() * dt;
				vel.y += forceRandom.y * emitter.random1To1() * dt;
			}
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		force.fromJson(d.force);

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

		d.force = force.toJson();

		if(forceRandom != null) {
			d.forceRandom = forceRandom.toJson();
		}

		return d;
	    
	}


}


typedef ForceModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var force : Vector;
	@:optional var forceRandom : Vector;

}


