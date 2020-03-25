package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class ForceModule extends ParticleModule {

	public var force(default, null):Vector;
	public var forceRandom:Vector;

	var _velComps:Components<Velocity>;

	public function new(options:ForceModuleOptions) {
		super(options);

		force = def(options.force, new Vector());
		forceRandom = options.forceRandom;
	}

	override function onAdded() {
		_velComps = emitter.components.get(Velocity);
	}

	override function onRemoved() {
		emitter.components.put(_velComps);
		_velComps = null;
	}

	override function onDisabled() {
		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
	}

	override function onUnspawn(p:Particle) {
		_velComps.get(p.id).set(0,0);
	}

	override function update(dt:Float) {
		var vel:Vector;

		var fx = force.x;
		var fy = force.y;

		if(forceRandom != null) {
			var frx = forceRandom.x;
			var fry = forceRandom.y;

			if(!emitter.system.localSpace) {
				fx = emitter.getRotateX(force.x, force.y);
				fy = emitter.getRotateY(force.x, force.y);
				frx = emitter.getRotateX(forceRandom.x, forceRandom.y); // TODO: maybe disable random transformation for random
				fry = emitter.getRotateY(forceRandom.x, forceRandom.y);
			}
			for (p in particles) {
				vel = _velComps.get(p.id);
				vel.x += fx * dt;
				vel.y += fy * dt;
				vel.x += frx * emitter.random1To1() * dt;
				vel.y += fry * emitter.random1To1() * dt;
			}
		} else {
			if(!emitter.system.localSpace) {
				fx = emitter.getRotateX(force.x, force.y);
				fy = emitter.getRotateY(force.x, force.y);
			}
			for (p in particles) {
				vel = _velComps.get(p.id);
				vel.x += fx * dt;
				vel.y += fy * dt;
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
	
	?force:Vector,
	?forceRandom:Vector,

}


