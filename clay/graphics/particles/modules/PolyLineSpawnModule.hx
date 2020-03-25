package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class PolyLineSpawnModule extends ParticleModule {

	public var points(default, null):Array<Vector>;

	public function new(options:PolyLineSpawnModuleOptions) {
		super(options);
		points = def(options.points, []);
		_priority = -999;
	}

	override function onSpawn(p:Particle) {
		if(points.length > 1) {
			var rndIdx = emitter.randomInt(points.length-1);
			var p0 = points[rndIdx];
			var p1 = points[rndIdx+1];

			var rnd = emitter.randomFloat(1);

			var x = p0.x + (p1.x - p0.x) * rnd;
			var y = p0.y + (p1.y - p0.y) * rnd;

			if(emitter.system.localSpace) {
				p.x = x;
				p.y = y;
			} else {
				p.x = emitter.getTransformX(x, y);
				p.y = emitter.getTransformY(x, y);
			}
		}
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);
		for (i in 0...d.points.length) {
			points[i].fromJson(d.points[i]);
		}
		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();
		d.points = [];
		for (p in points) {
			d.points.push(p.toJson());
		}
		return d; 
	}

}

typedef PolyLineSpawnModuleOptions = {

	>ParticleModuleOptions,

	?points:Array<Vector>,

}
