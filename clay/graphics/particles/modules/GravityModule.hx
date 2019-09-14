package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;

using clay.graphics.particles.utils.VectorExtender;


class GravityModule extends ParticleModule {


	public var gravity(default, null):Vector;

	var _velComps:Components<Velocity>;


	public function new(_options:GravityModuleOptions) {

		super(_options);

		gravity = _options.gravity != null ? _options.gravity : new Vector(0, 98);

	}

	override function init() {

		_velComps = emitter.components.get(Velocity);

	}

	override function onRemoved() {

		_velComps = null;
		
	}

	override function onDisabled() {

		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
		
	}

	override function onUnSpawn(p:Particle) {

		_velComps.get(p.id).set(0,0);
		
	}

	override function update(dt:Float) {

		var vel:Vector;
		for (p in particles) {
			vel = _velComps.get(p.id);
			vel.x += gravity.x * dt;
			vel.y += gravity.y * dt;
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
	
	@:optional var gravity : Vector;

}


