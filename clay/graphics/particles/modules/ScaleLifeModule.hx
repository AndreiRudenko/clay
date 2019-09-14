package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.ScaleDelta;
import clay.utils.Mathf;


class ScaleLifeModule extends ParticleModule {


	public var initialScale:Float;
	public var initialScaleMax:Float;
	public var endScale:Float;
	public var endScaleMax:Float;

	var _scaleDelta:Components<ScaleDelta>;


	public function new(_options:ScaleLifeModuleOptions) {

		super(_options);

		initialScale = _options.initialScale != null ? _options.initialScale : 1;
		initialScaleMax = _options.initialScaleMax != null ? _options.initialScaleMax : 0;
		endScale = _options.endScale != null ? _options.endScale : 1;
		endScaleMax = _options.endScaleMax != null ? _options.endScaleMax : 0;

	}

	override function init() {

		_scaleDelta = emitter.components.get(ScaleDelta);

	}

	override function onDisabled() {

		for (pd in particles) {
			pd.s = 1;
		}
		
	}

	override function onSpawn(p:Particle) {

		if(initialScaleMax > initialScale) {
			p.s = emitter.randomFloat(initialScale, initialScaleMax);
		} else {
			p.s = initialScale;
		}

		if(endScaleMax > endScale) {
			_scaleDelta.get(p.id).value = emitter.randomFloat(endScale, endScaleMax) - p.s;
		} else {
			_scaleDelta.get(p.id).value = endScale - p.s;
		}

		if(_scaleDelta.get(p.id).value != 0) {
			_scaleDelta.get(p.id).value /= p.lifetime;
		}

	}

	override function update(dt:Float) {

		for (p in particles) {
			if(_scaleDelta.get(p.id).value != 0) {
				p.s = Mathf.clampBottom(p.s + _scaleDelta.get(p.id).value * dt, 0);
			}
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialScale = d.initialScale;
		initialScaleMax = d.initialScaleMax;
		endScale = d.endScale;
		endScaleMax = d.endScaleMax;
		
		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialScale = initialScale;
		d.initialScaleMax = initialScaleMax;
		d.endScale = endScale;
		d.endScaleMax = endScaleMax;

		return d;
	    
	}


}


typedef ScaleLifeModuleOptions = {

	>ParticleModuleOptions,
	
	@:optional var initialScale : Float;
	@:optional var initialScaleMax : Float;
	@:optional var endScale : Float;
	@:optional var endScaleMax : Float;

}


