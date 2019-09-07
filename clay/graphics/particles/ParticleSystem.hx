package clay.graphics.particles;


import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Particle;
import clay.render.DisplayObject;
import clay.render.Painter;
import clay.render.Camera;
import clay.math.Vector;


@:access(clay.graphics.particles.ParticleEmitter)
class ParticleSystem extends DisplayObject {


		/** if the system is active, it will update */
	public var active:Bool;
		/** whether or not this system has been inited yet */
	public var inited  (default, null):Bool = false;
		/** whether or not this system is enabled */
	public var enabled (get, never):Bool;
		/** whether or not this system is paused */
	public var paused  (default, null):Bool = false;
		/** the system position */
	public var pos(default, null):Vector;
		/** the system emitters */
	public var emitters(default, null):Array<ParticleEmitter>;

		/** the system active emitters */
	var active_emitters:Int = 0;


	public function new(?emitters:Array<ParticleEmitter>) {

		super();

		active = true;
		pos = new Vector();
		this.emitters = emitters != null ? emitters : [];

		_init();

	}

	override function render(p:Painter) {

		p.set_shader(shader != null ? shader : shader_default);
		p.clip(clip_rect);

		for (e in emitters) {
			e.render(p);
		}
		
	}
	
		/** add emitter to the system */
	public function add(_emitter:ParticleEmitter):ParticleSystem {

		emitters.push(_emitter);

		_emitter.index = active_emitters;

		if(inited) {
			_emitter.init(this);
		}

		active_emitters++;

		return this;

	}

		/** remove a emitter from the system */
	public function remove(_emitter:ParticleEmitter) {
		
		var i:Int = 0;
		while(active_emitters > i) {
			if(emitters[i] == _emitter) {
				emitters.splice(i, 1);
				active_emitters--;
			}
			emitters[i].index = i;
			i++;
		}

	}

		/** emit particles */
	public function emit() {

		for (i in 0...active_emitters) {
			emitters[i].emit();
		}
		
	}

		/** start update emitters */
	public function start() {
		
		for (i in 0...active_emitters) {
			emitters[i].start();
		}

	}

		/** stop update emitters */
	public function stop(_kill:Bool = false) {
		
		for (i in 0...active_emitters) {
			emitters[i].stop(_kill);
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
		active_emitters = 0;
		
	}

		/** destroy the system */
	public function destroy() {

		empty();

		pos = null;
		emitters = null;

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
