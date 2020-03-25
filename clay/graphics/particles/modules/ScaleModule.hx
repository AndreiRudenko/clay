package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Scale;
import clay.utils.Log.*;

class ScaleModule extends ParticleModule {

	public var initialScale:Float;
	public var initialScaleMax:Float;

	var _scale:Components<Scale>;

	public function new(options:ScaleModuleOptions) {
		super(options);

		initialScale = def(options.initialScale, 1);
		initialScaleMax = def(options.initialScaleMax, 0);
	}

	override function onAdded() {
		_scale = emitter.components.get(Scale);
	}

	override function onRemoved() {
		emitter.components.put(_scale);
		_scale = null;
	}

	override function onDisabled() {
		for (p in particles) {
			_scale.set(p.id, 1);
		}
	}

	override function onSpawn(p:Particle) {
		if(initialScaleMax > initialScale) {
			_scale.set(p.id, emitter.randomFloat(initialScale, initialScaleMax));
		} else {
			_scale.set(p.id, initialScale);
		}
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		initialScale = d.initialScale;
		initialScaleMax = d.initialScaleMax;
		
		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.initialScale = initialScale;
		d.initialScaleMax = initialScaleMax;

		return d;
	}

}

typedef ScaleModuleOptions = {

	>ParticleModuleOptions,
	
	?initialScale:Float,
	?initialScaleMax:Float,

}
