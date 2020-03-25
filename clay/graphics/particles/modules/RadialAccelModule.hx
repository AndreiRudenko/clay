package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.graphics.particles.components.StartPos;
import clay.math.Vector;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class RadialAccelModule extends ParticleModule {

	public var tangentAccel:Float;
	public var tangentAccelVariance:Float;
	public var radialAccel:Float;
	public var radialAccelVariance:Float;
	public var offset:Vector;
	// public var accelRandom:Float;

	var _velComps:Components<Velocity>;
	var _sposComps:Components<StartPos>;
	var _radAccelData:Array<Float>;
	var _tanAccelData:Array<Float>;

	public function new(_options:TangentalAccelModuleOptions) {

		super(_options);

		tangentAccel = _options.tangentAccel != null ? _options.tangentAccel : 60;
		radialAccel = _options.radialAccel != null ? _options.radialAccel : 0;
		radialAccelVariance = _options.radialAccelVariance != null ? _options.radialAccelVariance : 0;
		tangentAccelVariance = _options.tangentAccelVariance != null ? _options.tangentAccelVariance : 0;
		offset = _options.offset != null ? _options.offset : new Vector();
		// accelRandom = _options.accelRandom != null ? _options.accelRandom : 0;

	}

	override function onAdded() {
		_velComps = emitter.components.get(Velocity);
		_sposComps = emitter.components.get(StartPos);
		_radAccelData = [];
		_tanAccelData = [];

		for (_ in 0...emitter.particles.capacity) {
			_radAccelData.push(0);
			_tanAccelData.push(0);
		}
	}

	override function onRemoved() {
		emitter.components.put(_velComps);
		emitter.components.put(_sposComps);
		_radAccelData = null;
		_tanAccelData = null;
		_velComps = null;
		_sposComps = null;
	}

	override function onDisabled() {
		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
	}
	
	override function onSpawn(p:Particle) {
		var sp = _sposComps.get(p.id);
		sp.set(p.x, p.y);

		var a = tangentAccel;
		if(tangentAccelVariance != 0) {
			a += tangentAccelVariance * emitter.random1To1();
		}
		_tanAccelData[p.id] = a;

		a = radialAccel;
		if(radialAccelVariance != 0) {
			a += radialAccelVariance * emitter.random1To1();
		}
		_radAccelData[p.id] = a;
	}

	override function update(dt:Float) {
		var dx:Float;
		var dy:Float;
		var ds:Float;
		var ax:Float;
		var ay:Float;
		var an:Float;

		var v:Velocity;
		var rac:Float;
		var tac:Float;

		var posX:Float = 0;
		var posY:Float = 0;

		if(emitter.system.localSpace) {
			posX = offset.x;
			posY = offset.y;
		} else {
			posX = emitter.getTransformX(offset.x, offset.y);
			posY = emitter.getTransformY(offset.x, offset.y);
		}

		for (p in particles) {
			v = _velComps.get(p.id);
			rac = _radAccelData[p.id];
			tac = _tanAccelData[p.id];

			dx = p.x - posX;
			dy = p.y - posY;

			ds = Math.sqrt(dx * dx + dy * dy); // TODO: get rid of sqrt
			if (ds < 0.01) {
				ds = 0.01;
			}

			ax = dx / ds;
			ay = dy / ds;

			an = ax;
			ax = -ay * tac + ax * rac;
			ay = an * tac + ay * rac;

			v.x += ax * dt;
			v.y += ay * dt;
		}
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		tangentAccel = d.tangentAccel;
		radialAccel = d.radialAccel;
		radialAccelVariance = d.radialAccelVariance;
		tangentAccelVariance = d.tangentAccelVariance;
		offset.fromJson(d.offset);

		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.tangentAccel = tangentAccel;
		d.radialAccel = radialAccel;
		d.radialAccelVariance = radialAccelVariance;
		d.tangentAccelVariance = tangentAccelVariance;
		d.offset = offset.toJson();

		return d;
	}

}

typedef TangentalAccelModuleOptions = {

	>ParticleModuleOptions,
	
	?tangentAccel:Float,
	?radialAccel:Float,
	?radialAccelVariance:Float,
	?tangentAccelVariance:Float,
	?offset:Vector,
	// ?accelRandom:Float,

}

