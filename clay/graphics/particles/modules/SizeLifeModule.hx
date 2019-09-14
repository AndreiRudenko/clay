package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.SizeDelta;
import clay.math.Vector;
import clay.utils.Mathf;

using clay.graphics.particles.utils.VectorExtender;


class SizeLifeModule extends ParticleModule {


	public var initialSize(default, null):Vector;
	public var endSize(default, null):Vector;
	public var initialSizeMax:Vector;
	public var endSizeMax:Vector;

	var _sizeDelta:Components<SizeDelta>;


	public function new(_options:SizeLifeModuleOptions) {

		super(_options);

		initialSize = _options.initialSize != null ? _options.initialSize : new Vector(32, 32);
		initialSizeMax = _options.initialSizeMax;
		endSize = _options.endSize != null ? _options.endSize : new Vector(8, 8);
		endSizeMax = _options.endSizeMax;

	}

	override function init() {

		_sizeDelta = emitter.components.get(SizeDelta);
		
	}

	override function onSpawn(pd:Particle) {

		var szd:Vector = _sizeDelta.get(pd.id);
		var lf:Float = pd.lifetime;

		if(initialSizeMax != null) {
			pd.w = emitter.randomFloat(initialSize.x, initialSizeMax.x);
			pd.h = emitter.randomFloat(initialSize.y, initialSizeMax.y);
		} else {
			pd.w = initialSize.x;
			pd.h = initialSize.y;
		}
		
		if(endSizeMax != null) {
			szd.x = emitter.randomFloat(endSize.x, endSizeMax.x) - pd.w;
			szd.y = emitter.randomFloat(endSize.y, endSizeMax.y) - pd.h;
		} else {
			szd.x = endSize.x - pd.w;
			szd.y = endSize.y - pd.h;
		}

		if(szd.x != 0) {
			szd.x /= lf;
		}

		if(szd.y != 0) {
			szd.y /= lf;
		}

	}

	override function update(dt:Float) {

		var szd:Vector;
		for (p in particles) {
			szd = _sizeDelta.get(p.id);
			p.w = Mathf.clampBottom(p.w + szd.x * dt, 0);
			p.h = Mathf.clampBottom(p.h + szd.y * dt, 0);
		}

	}


// import/export

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		initialSize.fromJson(d.initialSize);
		endSize.fromJson(d.endSize);

		if(d.initialSizeMax != null) {
			if(initialSizeMax == null) {
				initialSizeMax = new Vector();
			}
			initialSizeMax.fromJson(d.initialSizeMax);
		}
		
		if(d.endSizeMax != null) {
			if(endSizeMax == null) {
				endSizeMax = new Vector();
			}
			endSizeMax.fromJson(d.endSizeMax);
		}

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		d.initialSize = initialSize.toJson();
		d.endSize = endSize.toJson();

		if(initialSizeMax != null) {
			d.initialSizeMax = initialSizeMax.toJson();
		}
		if(endSizeMax != null) {
			d.endSizeMax = endSizeMax.toJson();
		}

		return d;
	    
	}


}


typedef SizeLifeModuleOptions = {
	
	>ParticleModuleOptions,
	@:optional var initialSize : Vector;
	@:optional var initialSizeMax : Vector;
	@:optional var endSize : Vector;
	@:optional var endSizeMax : Vector;

}


