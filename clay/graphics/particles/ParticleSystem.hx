package clay.graphics.particles;


import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.render.DisplayObject;
import clay.render.Painter;
import clay.math.Vector;


@:access(clay.graphics.particles.ParticleEmitter)
class ParticleSystem extends DisplayObject {


		/** if the system is active, it will update */
	public var active:Bool;
		/** whether or not this system has been inited yet */
	public var inited(default, null):Bool = false;
		/** whether or not this system is enabled */
	public var enabled(get, never):Bool;
		/** whether or not this system is paused */
	public var paused(default, null):Bool = false;
		/** the system position */
	public var pos(default, null):Vector;
		/** the system emitters */
	public var emitters(default, null):Array<ParticleEmitter>;

		/** the system active emitters */
	var _activeEmitters:Int = 0;


	public function new(?emitters:Array<ParticleEmitter>) {

		super();

		active = true;
		pos = new Vector();
		this.emitters = emitters != null ? emitters : [];

		_init();

	}
	
		/** update the system */
	override function update(dt:Float) {

		super.update(dt);

		if(active) {
			for (e in emitters) {
				e.update(dt);
			}
		}
		
	}

	override function render(p:Painter) {

		p.setShader(shader != null ? shader : shaderDefault);
		p.clip(clipRect);

		for (e in emitters) {
			e.render(p);
		}
		
	}
	
		/** add emitter to the system */
	public function add(emitter:ParticleEmitter):ParticleSystem {

		emitters.push(emitter);

		emitter.index = _activeEmitters;

		if(inited) {
			emitter.init(this);
		}

		_activeEmitters++;

		return this;

	}

		/** remove a emitter from the system */
	public function remove(emitter:ParticleEmitter) {
		
		var i:Int = 0;
		while(_activeEmitters > i) {
			if(emitters[i] == emitter) {
				emitters.splice(i, 1);
				_activeEmitters--;
			}
			emitters[i].index = i;
			i++;
		}

	}

		/** emit particles */
	public function emit() {

		for (i in 0..._activeEmitters) {
			emitters[i].emit();
		}
		
	}

		/** start update emitters */
	public function start() {
		
		for (i in 0..._activeEmitters) {
			emitters[i].start();
		}

	}

		/** stop update emitters */
	public function stop(kill:Bool = false) {
		
		for (i in 0..._activeEmitters) {
			emitters[i].stop(kill);
		}

	}

		/** pause update emitters */
	public function pause() {

		active = false;
		
	}

		/** unpause update emitters */
	public function unpause() {

		active = true;

	}

		/** destroy all emitters in this system. */
	public function empty() {

		for (e in emitters) {
			e.destroy();
		}

		emitters.splice(0, emitters.length);
		_activeEmitters = 0;
		
	}

		/** destroy the system */
	public function destroy() {

		empty();

		pos = null;
		emitters = null;

	}

	function _init() {

		for (e in emitters) {
			e.init(this);
		}

		inited = true;
		
	}

	function get_enabled():Bool {

		for (e in emitters) {
			if(e.enabled) {
				return true;
			}
		}
		
		return false;

	}


}
