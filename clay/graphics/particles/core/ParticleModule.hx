package clay.graphics.particles.core;

import clay.render.RenderContext;
import clay.graphics.particles.core.ParticleVector;

// @:access(clay.graphics.particles.ParticleEmitter)
class ParticleModule {

	public var name:String;
	// public var moduleName:String; // TODO: get full path to class from macro for json export
	public var enabled:Bool;
	@:allow(clay.graphics.particles.ParticleEmitter)
	public var emitter(default, null):ParticleEmitter;
	public var priority(get, set):Int;
	var _priority:Int;
	var particles(get, never):ParticleVector;

	public function new(?options:ParticleModuleOptions) {
		name = Type.getClassName(Type.getClass(this));
		enabled = true;
		_priority = 0;

		if(options != null) {
			if(options.enabled != null) {
				enabled = options.enabled;
			}

			if(options.priority != null) {
				_priority = options.priority;
			}
		}
	}

	public function onAdded() {}
	public function onRemoved() {}
	public function onEnabled() {}
	public function onDisabled() {}
	public function onSpawn(p:Particle) {}
	public function onUnspawn(p:Particle) {}
	public function update(elapsed:Float) {}
	public function render(ctx:RenderContext) {}

	public function toJson():Dynamic {
		return {
			name: name,
			enabled: enabled,
			priority: priority
		};
	}

	public function fromJson(d:Dynamic):ParticleModule {
		enabled = d.enabled;
		priority = d.priority;
		return this;
	}

	inline function get_priority():Int {
		return _priority;
	}

	function set_priority(value:Int):Int {
		_priority = value;

		if(emitter != null && enabled) {
			emitter.sortModules();
		}

		return _priority;
	}

	inline function get_particles():ParticleVector {
		return emitter.particles;	
	}

}

typedef ParticleModuleOptions = {
	?enabled:Bool,
	?priority:Int,
}