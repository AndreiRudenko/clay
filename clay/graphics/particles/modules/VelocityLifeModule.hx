package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.VelocityDelta;
import clay.graphics.particles.modules.VelocityModule;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class VelocityLifeModule extends VelocityModule {


	public var endVelocity(default, null):Vector;
	public var endVelocityMax:Vector;

	var _velocityDelta:Components<VelocityDelta>;


	public function new(_options:VelocityLifeModuleOptions) {

		super(_options);

		endVelocity = _options.endVelocity != null ? _options.endVelocity : new Vector();
		endVelocityMax = _options.endVelocityMax;

	}

	override function init() {

		super.init();

		_velocityDelta = emitter.components.get(VelocityDelta);
	    
	}

	override function onSpawn(p:Particle) {

		var v:Velocity = _velComps.get(p.id);
		if(initialVelocityMax != null) {
			v.x = emitter.randomFloat(initialVelocity.x, initialVelocityMax.x);
			v.y = emitter.randomFloat(initialVelocity.y, initialVelocityMax.y);
		} else {
			v.x = initialVelocity.x;
			v.y = initialVelocity.y;
		}

		if(endVelocityMax != null) {
			_velocityDelta.get(p.id).x = emitter.randomFloat(endVelocity.x, endVelocityMax.x) - v.x;
			_velocityDelta.get(p.id).y = emitter.randomFloat(endVelocity.y, endVelocityMax.y) - v.y;
		} else {
			_velocityDelta.get(p.id).x = endVelocity.x - v.x;
			_velocityDelta.get(p.id).y = endVelocity.y - v.y;
		}

		if(_velocityDelta.get(p.id).lengthSq != 0) {
			_velocityDelta.get(p.id).divideScalar(p.lifetime);
		}

	}

	override function update(dt:Float) {

		var v:Vector;
		if(velocityRandom != null) {
			for (p in particles) {
				v = _velComps.get(p.id);
				v.x += _velocityDelta.get(p.id).x * dt + velocityRandom.x * emitter.random1To1();
				v.y += _velocityDelta.get(p.id).y * dt + velocityRandom.y * emitter.random1To1();
			}
		} else {
			for (p in particles) {
				v = _velComps.get(p.id);
				v.x += _velocityDelta.get(p.id).x * dt;
				v.y += _velocityDelta.get(p.id).y * dt;
			}
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		endVelocity.fromJson(d.endVelocity);

		if(d.endVelocityMax != null) {
			if(endVelocityMax == null) {
				endVelocityMax = new Vector();
			}
			endVelocityMax.fromJson(d.endVelocityMax);
		}

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.endVelocity = endVelocity.toJson();

		if(endVelocityMax != null) {
			d.endVelocityMax = endVelocityMax.toJson();
		}

		return d;
	    
	}


}


typedef VelocityLifeModuleOptions = {

	> VelocityModuleOptions,
	
	@:optional var endVelocity : Vector;
	@:optional var endVelocityMax : Vector;

}


