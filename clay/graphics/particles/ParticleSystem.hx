package clay.graphics.particles;

// import clay.graphics.particles.ParticleEmitter;
// import clay.graphics.particles.core.ParticleModule;
// import clay.graphics.particles.core.Particle;
import clay.graphics.Sprite;
import clay.graphics.DisplayObject;
import clay.render.RenderContext;
import clay.math.Vector;
import clay.utils.Log.*;
import clay.utils.Color;

class ParticleSystem extends DisplayObject {

	public static function createFromJson(json:Dynamic):ParticleSystem {
	    return null;
	}

	public var enabled(get, never):Bool;
	public var paused(default, null):Bool = false;
	public var emitters(default, null):Array<ParticleEmitter>;
	public var localSpace(get, set):Bool;
	var _localSpace:Bool = true;

	public function new(?emitters:Array<ParticleEmitter>) {
		super();
		this.emitters = def(emitters, []);

		for (e in emitters) {
			addEmitter(e);
		}
	}
	
	override function update(elapsed:Float) {
		super.update(elapsed);
		if(!paused) {
			for (e in emitters) {
				e.update(elapsed);
			}
		}
	}

	override function render(ctx:RenderContext) {
		var shader = getRenderShader();
		ctx.setShader(shader);
		ctx.clip(clipRect);

		for (e in emitters) {
			e.render(ctx);
		}
	}
	
	public function addEmitter(emitter:ParticleEmitter):ParticleSystem {
		if(hasEmitter(emitter)) {
			log('ParticleEmitter already exists in ParticleSystem: ${name}');
			return this;
		}
		emitters.push(emitter);
		onAddEmitter(emitter);

		return this;
	}

	public function removeEmitter(emitter:ParticleEmitter) {
		var removed = emitters.remove(emitter);
		if(removed) {
			onRemoveEmitter(emitter);
		}
	}

	public function emit() {
		for (e in emitters) {
			e.emit();
		}
	}

	public function start() {
		for (e in emitters) {
			e.start();
		}
	}

	public function stop(kill:Bool = false) {
		for (e in emitters) {
			e.stop(kill);
		}
	}

	public function pause() {
		active = false;
	}

	public function unpause() {
		active = true;
	}

	inline function onAddEmitter(e:ParticleEmitter) {
		e.system = this;
		e.onAdded();
	}

	inline function onRemoveEmitter(e:ParticleEmitter) {
		e.system = null;
		e.onRemoved();
	}

	inline function hasEmitter(e:ParticleEmitter):Bool {
		return emitters.indexOf(e) != -1;
	}

	function get_enabled():Bool {
		return false;
	}

	inline function get_localSpace():Bool { 
		return _localSpace; 
	}
	
	function set_localSpace(value:Bool):Bool {
		_localSpace = value;
		unspawnAll();
		return value;
	}

	inline function unspawnAll() {
		for (e in emitters) {
			e.unspawnAll();
		}
	}

}
