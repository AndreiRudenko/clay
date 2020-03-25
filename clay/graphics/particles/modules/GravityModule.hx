package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Transform;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class GravityModule extends ParticleModule {

	public var gravity:Vector;
	var _velComps:Components<Velocity>;

	public function new(options:GravityModuleOptions) {
		super(options);
		gravity = def(options.gravity, new Vector(0, 98));
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
		var gx = gravity.x;
		var gy = gravity.y;
		if(!emitter.system.localSpace) {
			gx = emitter.getRotateX(gravity.x, gravity.y); // TODO: remove transformation?
			gy = emitter.getRotateY(gravity.x, gravity.y);
		}
		var vel:Vector;
		for (p in particles) {
			vel = _velComps.get(p.id);
			vel.x += gx * dt;
			vel.y += gy * dt;
		}
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);
		gravity.fromJson(d.gravity);

		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();
		d.gravity = gravity.toJson();

		return d;
	}

}

typedef GravityModuleOptions = {

	>ParticleModuleOptions,
	
	?gravity:Vector

}


