package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Velocity;
import clay.math.Vector;
import clay.render.RenderContext;

using clay.graphics.particles.utils.VectorExtender;

class MagneticFieldsModule extends ParticleModule {

	public var fields(default, null):Array<MagneticField>;
	#if !release
	public var debugDrawFields:Bool;
	#end
	var _velComps:Components<Velocity>;

	public function new(options:MagneticFieldModuleOptions) {
		super(options);

		fields = [];

		if(options.fields != null) {
			for (f in options.fields) {
				addField(f.pos, f.radius, f.force);
			}
		}

		#if !release
		debugDrawFields = options.debugDrawFields != null ? options.debugDrawFields : false;
		#end
	}

	public function addField(pos:Vector, radius:Float, force:Float):MagneticField {
		var field = new MagneticField(pos, radius, force);
		fields.push(field);

		return field;
	}

	public function removeField(f:MagneticField):Bool {
		return fields.remove(f);
	}

	override function onAdded() {
		_velComps = emitter.components.get(Velocity);
	}

	override function onRemoved() {
		emitter.components.put(_velComps);
		_velComps = null;
	}

	override function onDisabled() {
		particles.forEach(
			function(p) {
				_velComps.get(p.id).set(0,0);
			}
		);
	}
	
	override function update(dt:Float) {
		for (f in fields) {
			for (p in particles) {
				collision(p, f, _velComps.get(p.id), dt);
			}
		}
	}

	#if !release
	override function render(ctx:RenderContext) {
		for (f in fields) {
			Clay.draw.circleOutline({
				x: f.pos.x,
				y: f.pos.y,
				r: f.radius,
			});
		}
	}
	#end

	inline function collision(p:Particle, f:MagneticField, v:Vector, dt:Float) {
		var pradius = 0; //TODO

		var dx = f.pos.x - p.x;
		var dy = f.pos.y - p.y;

		var r = pradius + f.radius;

		var dist2 = dx * dx + dy * dy;

		if(dist2 >= r * r) {
			return;
		}

		var dist = Math.sqrt(dist2); // TODO: workaround this

		if(dist < 0.001) {
			return;
		}

		var normalX = dx / dist;
		var normalY = dy / dist;

		v.x += normalX * f.force * dt;
		v.y += normalY * f.force * dt;
	}

// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		var flds:Array<MagneticFieldOptions> = d.fields;
		for (f in flds) {
			addField(f.pos, f.radius, f.force);
		}

		return this;
	}

	override function toJson():Dynamic {

		var d = super.toJson();
		d.fields = [];

		for (f in fields) {
			d.fields.push(
				{
					pos: f.pos.toJson(),
					radius: f.radius,
					force: f.force
				}
			);
		}

		return d;
	}

}

class MagneticField {

	public var pos:Vector;
	public var radius:Float;
	public var force:Float;

	public function new(pos:Vector, radius:Float, force:Float) {
		this.pos = pos;
		this.radius = radius;
		this.force = force;
	}

}

typedef MagneticFieldModuleOptions = {

	>ParticleModuleOptions,
	
	?fields:Array<MagneticFieldOptions>,
	?debugDrawFields:Bool,

}

typedef MagneticFieldOptions = {

	pos:Vector,
	radius:Float,
	force:Float,

}
