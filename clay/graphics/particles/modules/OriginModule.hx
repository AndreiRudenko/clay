package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Origin;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class OriginModule extends ParticleModule {

	public var initialOrigin(default, null):Vector;
	public var initialOriginMax:Vector;

	var _origin:Components<Origin>;

	public function new(options:OriginModuleOptions) {
		super(options);

		initialOrigin = def(options.initialOrigin, new Vector(0.5, 0.5));
		initialOriginMax = options.initialOriginMax;
	}

	override function onAdded() {
		_origin = emitter.components.get(Origin);
	}

	override function onRemoved() {
		emitter.components.put(_origin);
		_origin = null;
	}

	override function onSpawn(p:Particle) {
		var o:Vector = _origin.get(p.id);

		if(initialOriginMax != null) {
			o.x = emitter.randomFloat(initialOrigin.x, initialOriginMax.x);
			o.y = emitter.randomFloat(initialOrigin.y, initialOriginMax.y);
		} else {
			o.x = initialOrigin.x;
			o.y = initialOrigin.y;
		}
	}


// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		initialOrigin.fromJson(d.initialOrigin);

		if(d.initialOriginMax != null) {
			if(initialOriginMax == null) {
				initialOriginMax = new Vector();
			}
			initialOriginMax.fromJson(d.initialOriginMax);
		}

		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.initialOrigin = initialOrigin.toJson();

		if(initialOriginMax != null) {
			d.initialOriginMax = initialOriginMax.toJson();
		}

		return d;
	}

}

typedef OriginModuleOptions = {
	
	>ParticleModuleOptions,
	?initialOrigin:Vector,
	?initialOriginMax:Vector,

}


