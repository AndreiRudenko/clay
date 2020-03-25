package clay.graphics.particles.modules;

import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Size;
import clay.graphics.particles.components.SizeDelta;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class SizeLifeModule extends ParticleModule {

	public var initialSize(default, null):Vector;
	public var endSize(default, null):Vector;
	public var initialSizeMax:Vector;
	public var endSizeMax:Vector;

	var _size:Components<Size>;
	var _sizeDelta:Components<SizeDelta>;

	public function new(options:SizeLifeModuleOptions) {
		super(options);

		initialSize = def(options.initialSize, new Vector(32, 32));
		initialSizeMax = options.initialSizeMax;
		endSize = def(options.endSize, new Vector(8, 8));
		endSizeMax = options.endSizeMax;
	}

	override function onAdded() {
		_size = emitter.components.get(Size);
		_sizeDelta = emitter.components.get(SizeDelta);
	}
	
	override function onRemoved() {
		emitter.components.put(_size);
		emitter.components.put(_sizeDelta);
		_size = null;
		_sizeDelta = null;
	}

	override function onSpawn(pd:Particle) {
		var szd:Vector = _sizeDelta.get(pd.id);
		var sz:Vector = _size.get(pd.id);
		var lf:Float = pd.lifetime;

		if(initialSizeMax != null) {
			sz.x = emitter.randomFloat(initialSize.x, initialSizeMax.x);
			sz.y = emitter.randomFloat(initialSize.y, initialSizeMax.y);
		} else {
			sz.x = initialSize.x;
			sz.y = initialSize.y;
		}
		
		if(endSizeMax != null) {
			szd.x = emitter.randomFloat(endSize.x, endSizeMax.x) - sz.x;
			szd.y = emitter.randomFloat(endSize.y, endSizeMax.y) - sz.y;
		} else {
			szd.x = endSize.x - sz.x;
			szd.y = endSize.y - sz.y;
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
		var sz:Vector;
		for (p in particles) {
			szd = _sizeDelta.get(p.id);
			sz = _size.get(p.id);
			sz.set(Mathf.clampBottom(sz.x + szd.x * dt, 0), Mathf.clampBottom(sz.y + szd.y * dt, 0));
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
	?initialSize:Vector,
	?initialSizeMax:Vector,
	?endSize:Vector,
	?endSizeMax:Vector,

}