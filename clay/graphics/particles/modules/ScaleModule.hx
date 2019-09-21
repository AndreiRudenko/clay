package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Scale;


class ScaleModule extends ParticleModule {


	public var initialScale:Float;
	public var initialScaleMax:Float;

	var _scale:Components<Scale>;


	public function new(_options:ScaleModuleOptions) {

		super(_options);

		initialScale = _options.initialScale != null ? _options.initialScale : 1;
		initialScaleMax = _options.initialScaleMax != null ? _options.initialScaleMax : 0;

	}

	override function init() {

		_scale = emitter.components.get(Scale);

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
	
	@:optional var initialScale : Float;
	@:optional var initialScaleMax : Float;

}


