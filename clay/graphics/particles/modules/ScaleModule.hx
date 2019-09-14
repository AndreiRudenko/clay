package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;


class ScaleModule extends ParticleModule {


	public var initialScale:Float;
	public var initialScaleMax:Float;


	public function new(_options:ScaleModuleOptions) {

		super(_options);

		initialScale = _options.initialScale != null ? _options.initialScale : 1;
		initialScaleMax = _options.initialScaleMax != null ? _options.initialScaleMax : 0;

	}

	override function init() {

	}

	override function onDisabled() {

		for (p in particles) {
			p.s = 1;
		}
		
	}

	override function onSpawn(p:Particle) {

		if(initialScaleMax > initialScale) {
			p.s = emitter.randomFloat(initialScale, initialScaleMax);
		} else {
			p.s = initialScale;
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


