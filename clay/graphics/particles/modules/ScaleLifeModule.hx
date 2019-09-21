package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Scale;
import clay.graphics.particles.components.ScaleDelta;
import clay.utils.Mathf;


class ScaleLifeModule extends ParticleModule {


	public var initialScale:Float;
	public var initialScaleMax:Float;
	public var endScale:Float;
	public var endScaleMax:Float;

	var _scale:Components<Scale>;
	var _scaleDelta:Components<ScaleDelta>;


	public function new(_options:ScaleLifeModuleOptions) {

		super(_options);

		initialScale = _options.initialScale != null ? _options.initialScale : 1;
		initialScaleMax = _options.initialScaleMax != null ? _options.initialScaleMax : 0;
		endScale = _options.endScale != null ? _options.endScale : 1;
		endScaleMax = _options.endScaleMax != null ? _options.endScaleMax : 0;

	}

	override function init() {

		_scale = emitter.components.get(Scale);
		_scaleDelta = emitter.components.get(ScaleDelta);

	}

	override function onDisabled() {

		for (p in particles) {
			_scale.set(p.id, 1);
		}
		
	}

	override function onSpawn(p:Particle) {

		var s = _scale.get(p.id);
		var sd = _scaleDelta.get(p.id);

		if(initialScaleMax > initialScale) {
			s = emitter.randomFloat(initialScale, initialScaleMax);
		} else {
			s = initialScale;
		}

		if(endScaleMax > endScale) {
			sd = emitter.randomFloat(endScale, endScaleMax) - s;
		} else {
			sd = endScale - s;
		}

		if(sd != 0) {
			sd /= p.lifetime;
		}

		_scale.set(p.id, s);
		_scaleDelta.set(p.id, sd);
	}

	override function update(dt:Float) {

		var s:Float;
		var sd:Float;
		for (p in particles) {
			sd = _scaleDelta.get(p.id);
			if(sd != 0) {
				s = _scale.get(p.id);
				s = Mathf.clampBottom(s + sd * dt, 0);
				_scale.set(p.id, s);
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


