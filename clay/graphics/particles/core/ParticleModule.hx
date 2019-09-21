package clay.graphics.particles.core;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleVector;
import clay.graphics.particles.ParticleEmitter;
import clay.render.Painter;

@:access(clay.graphics.particles.ParticleEmitter)
class ParticleModule {


       /** if the module is enabled it will update */
	public var enabled(default, set):Bool = true;
       /** the name */
	public var name (default, null):String;
       /** the module priority */
	public var priority (get, set) : Int;
	@:noCompletion public var _priority : Int = 0;

        /** if the module is in a emitter, this is not null */
	@:noCompletion public var emitter:ParticleEmitter;
        /** reference to emitter particles */
	var particles:ParticleVector;


	public function new(?_options:ParticleModuleOptions) {

		name = Type.getClassName(Type.getClass(this));

		if(_options != null) {
			if(_options.enabled != null) {
				enabled = _options.enabled;
			}

			if(_options.priority != null) {
				priority = _options.priority;
			}
		}
		
	}

       /** called when the emitter initiated */
	public function init() {}
       /** called when the emitter starts or is reset */
	public function onReset() {}
        /** called when the module is destroyed */
	public function onDestroy() {}

        /** called when the module is attached to an emitter */
	public function onAdded() {}
        /** called when the module is removed from an emitter */
	public function onRemoved() {}

        /** called when the module is enabled */
	public function onEnabled() {}
        /** called when the module is disabled */
	public function onDisabled() {}

        /** called when the emitter spawn particle */
	public function onSpawn(p:Particle) {}
        /** called when the emitter unspawn particle */
	public function onUnSpawn(p:Particle) {}

        /** called once per frame, passing the delta time */
	public function update(dt:Float) {}

        /** called once per frame */
	public function render(p:Painter) {}

        /** save settings to json */
	public function toJson():Dynamic {

		return {
			name : name,
			enabled : enabled,
			priority : priority
		};

	}

        /** load settings from json */
	public function fromJson(d:Dynamic):ParticleModule {
		
		enabled = d.enabled;
		priority = d.priority;

		return this;

	}

	@:allow(clay.graphics.particles.ParticleEmitter)
	inline function _init() {

		init();
		onReset();

	}

	@:allow(clay.graphics.particles.ParticleEmitter)
	inline function _onAdded(_emitter:ParticleEmitter) {

		emitter = _emitter;
		particles = emitter.particles;
		onAdded();

	}
	
	@:allow(clay.graphics.particles.ParticleEmitter)
	inline function _onRemoved() {

		onRemoved();
		emitter = null;
		particles = null;

	}

	function get_priority():Int {
		
		return _priority;

	}

	function set_priority(value:Int):Int {

		_priority = value;

		if(emitter != null && enabled) {
			emitter._sortActive();
		}

		return _priority;

	}

	function set_enabled(value:Bool):Bool {

		if(enabled != value && emitter != null) {
			if(value) {
				emitter._enableModule(this);
			} else {
				emitter._disableModule(this);
			}
		}

		enabled = value;

		return enabled;

	}


}

typedef ParticleModuleOptions = {

	@:optional var enabled:Bool;
	@:optional var priority:Int;

}