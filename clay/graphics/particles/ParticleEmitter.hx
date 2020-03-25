package clay.graphics.particles;

import clay.graphics.particles.core.ComponentManager;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.ParticleVector;
import clay.graphics.particles.core.Particle;
import clay.graphics.Sprite;
import clay.graphics.DisplayObject;
import clay.render.RenderContext;
import clay.math.Vector;
import clay.math.Transform;
import clay.utils.Log.*;
import clay.utils.Color;

class ParticleEmitter {

	public var name:String;
	public var transform(default, null):Transform;

	public var active:Bool;
	public var enabled(default, null):Bool = false;

	@:allow(clay.graphics.particles.ParticleSystem)
	public var system(default, null):ParticleSystem;

	public var particles(default, null):ParticleVector;
	public var components(default, null):ComponentManager;

	public var modules(default, null):Array<ParticleModule>;

	public var count:Int;
	public var countMax:Int;

	public var lifetime:Float;
	public var lifetimeMax:Float;

	public var rate(default, set):Float;
	public var rateMax(default, set):Float;

	public var duration(default, set):Float;
	public var durationMax(default, set):Float;

	public var preprocess:Float;

	public var cacheSize(default, null):Int;
	public var cacheWrap:Bool;

	public var random:()->Float;

	@:noCompletion public var options:ParticleEmitterOptions;

	var _time:Float;
	var _frameTime:Float;
	var _duration:Float;
	var _invRate:Float;
	var _invRateMax:Float;
	var _preprocess:Float;

	var _cosA:Float;
	var _sinA:Float;

	public function new(options:ParticleEmitterOptions) {
		transform = new Transform();
		transform.world.autoDecompose = true;

		modules = [];
		_time = 0;
		_frameTime = 0;
		_duration = 0;
		_invRate = 0;
		_invRateMax = 0;
		_preprocess = 0;
		_cosA = 0;
		_sinA = 0;

		this.options = options;

		name = options.name != null ? options.name : 'emitter.${Math.random()}';

		cacheSize = options.cacheSize != null ? options.cacheSize : 128;
		if(cacheSize <= 0) {
			cacheSize = 1;
		}

		components = new ComponentManager(cacheSize);
		particles = new ParticleVector(components, cacheSize);

		if(options.pos != null) {
			transform.pos.copyFrom(options.pos);
		}

		if(options.scale != null) {
			transform.scale.copyFrom(options.scale);
		}

		if(options.rotation != null) {
			transform.rotation = options.rotation;
		}
		
		active = def(options.active, true);
		enabled = def(options.enabled, false);

		duration = def(options.duration, -1);
		durationMax = def(options.durationMax, -1);
		preprocess = def(options.preprocess, 0);

		count = def(options.count, 1);
		countMax = def(options.countMax, 0);

		lifetime = def(options.lifetime, 1);
		lifetimeMax = def(options.lifetimeMax, 0);

		rate = def(options.rate, 10);
		rateMax = def(options.rateMax, 0);

		random = def(options.random, Math.random);
		
		cacheWrap = def(options.cacheWrap, false);

		if(options.modules != null) {
			for (m in options.modules) {
				addModule(m);
			}
		}
	}

	public function addModule(module:ParticleModule, ?priority:Int):ParticleEmitter {
		var name = Type.getClassName(Type.getClass(module));

		if(getModuleByName(name) != null) {
			log('can`t add particle module: $name already exists');
		} else {
			if(module.emitter != null) {
				log('particle module: $name already in another emitter, remove from it');
				module.emitter.removeModuleInternal(module);
			}
			if(priority != null) {
				module.priority = priority;
			}
			addModuleInternal(module);
		}

		return this;
	}

	public function getModule<T:ParticleModule>(moduleClass:Class<T>):T {
		var name = Type.getClassName(moduleClass);
		return cast getModuleByName(name);
	}

	public function removeModule<T:ParticleModule>(moduleClass:Class<T>):T {
		var m:T = getModule(moduleClass);
		
		if(m != null) {
			removeModuleInternal(m);
		}
		return m;
	}
	
	public function enableModule<T:ParticleModule>(moduleClass:Class<T>) {
		var m:T = getModule(moduleClass);
		
		if(m != null && !m.enabled) {
			m.enabled = true;
			m.onEnabled();
		}
	}

	public function disableModule<T:ParticleModule>(moduleClass:Class<T>) {
		var m:T = getModule(moduleClass);
		
		if(m != null && m.enabled) {
			m.enabled = false;
			m.onDisabled();
		}
	}

	public function emit() {
		var emitCount:Int;

		if(countMax > 0) {
			emitCount = randomInt(count, countMax);
		} else {
			emitCount = count;
		}

		emitCount = emitCount > cacheSize ? cacheSize : emitCount;

		while(emitCount > 0) {
			spawn();
			emitCount--;
		}
	}

	public function start(?duration:Float) {
		enabled = true;
		_time = 0;
		_frameTime = 0;

		_preprocess = preprocess;

		if(duration == null) {
			calcDuration();
		} else {
			_duration = duration;
		}
	}

	public function stop(kill:Bool = false) {
		enabled = false;
		_time = 0;
		_frameTime = 0;

		if(kill) {
			unspawnAll();
		}
	}

	public function pause() {
		active = false;
	}

	public function unpause() {
		active = true;
	}

	public function update(elapsed:Float) {
		updateTransform();

		if(active) {
			// remove ended particles
			var pd:Particle;
			var i:Int = 0;
			var len:Int = particles.length;
			while(i < len) {
				pd = particles.get(i);
				pd.lifetime -= elapsed;
				pd.age += elapsed;
				if(pd.lifetime <= 0) {
					unspawn(pd);
					len = particles.length;
				} else {
					i++;
				}
			}

			if(enabled && rate > 0) {
				_frameTime += elapsed;

				var ir:Float;
				while(_frameTime > 0) {
					emit();

					if(rateMax > 0) {
						ir = randomFloat(_invRate, _invRateMax);
					} else {
						ir = _invRate;
					}

					if(ir == 0) { // TODO: invRate can be 0 from randomFloat(_invRate, _invRateMax);
						_frameTime = 0;
						break;
					}

					_frameTime -= ir;
				}

				_time += elapsed;

				if(_duration >= 0 && _time >= _duration) {
					stop();
				}
			}

			for (m in modules) {
				if(m.enabled) {
					m.update(elapsed);
				}
			}

			// update particles global position
			i = 0;
			len = particles.length;
			if(system.localSpace) {
				while(i < len) {
					pd = particles.get(i);
					pd.globalX = getTransformX(pd.x, pd.y);
					pd.globalY = getTransformY(pd.x, pd.y);
					i++;
				}
			} else {
				while(i < len) {
					pd = particles.get(i);
					pd.globalX = pd.x;
					pd.globalY = pd.y;
					i++;
				}
			}

			// TODO: add modules lateUpdate ?

			if(_preprocess > 0) {
				_preprocess -= elapsed;
				update(elapsed);
			}
		}
	}

	inline function updateTransform() {
		transform.update();
		var r = transform.world.rotation;
		_cosA = Math.cos(r);
		_sinA = Math.sin(r);
	}

	public function render(ctx:RenderContext) {
		for (m in modules) {
			if(m.enabled) {
				m.render(ctx);
			}
		}
	}

	inline function spawn() {
		if(particles.length < particles.capacity) {
			spawnParticle(particles.ensure());
		} else if(cacheWrap) {
			var p:Particle = particles.wrap();
			unspawnParticle(p);
			spawnParticle(p);
		}
	}

	inline function unspawn(p:Particle) {
		particles.remove(p);
		unspawnParticle(p);
	}

	public function unspawnAll() {
		for (p in particles) {
			for (m in modules) {
				m.onUnspawn(p);
			}
		}
		particles.reset();
	}

	inline function spawnParticle(p:Particle) {
		for (m in modules) {
			if(m.enabled) {
				if(lifetimeMax > 0) {
					p.lifetime = randomFloat(lifetime, lifetimeMax);
				} else {
					p.lifetime = lifetime;
				}
				p.age = 0;
				m.onSpawn(p);
			}
		}
	}

	inline function unspawnParticle(p:Particle) {
		for (m in modules) {
			if(m.enabled) {
				m.onUnspawn(p);
			}
		}
	}

	function getModuleByName(name:String):ParticleModule {
		for (m in modules) {
			if(m.name == name) {
				return m;
			}
		}
		return null;
	}

	inline function addModuleSorted(module:ParticleModule) {
		var added:Bool = false;
		var m:ParticleModule = null;
		for (i in 0...modules.length) {
			m = modules[i];
			if (module.priority <= m.priority) {
				modules.insert(i,module);
				added = true;
				break;
			}
		}
		
		if(!added) {
			modules.push(module);
		}
	}

	inline function addModuleInternal(module:ParticleModule) {
		module.emitter = this;
		addModuleSorted(module);
		emitAddModuleSignals(module);
	}

	inline function removeModuleInternal(module:ParticleModule) {
		emitRemoveModuleSignals(module);
		modules.remove(module);
		module.emitter = null;
	}

	inline function emitAddModuleSignals(module:ParticleModule) {
		module.onAdded();
		if(module.enabled) {
			module.onEnabled();
		}
	}

	inline function emitRemoveModuleSignals(module:ParticleModule) {
		if(module.enabled) {
			module.onDisabled();
		}
		module.onRemoved();
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	function sortModules() {
		haxe.ds.ArraySort.sort(modules,sortModulesFunc);
	}

	function sortModulesFunc(a:ParticleModule, b:ParticleModule) {
		if (a.priority < b.priority) {
			return -1;
		} else if (a.priority > b.priority) {
			return 1;
		}
		return 0;
	}

	@:allow(clay.graphics.particles.ParticleSystem)
	function onAdded() {
		transform.parent = system.transform;
	}

	@:allow(clay.graphics.particles.ParticleSystem)
	function onRemoved() {
		transform.parent = null;
	}

	function set_rate(value:Float):Float {
		if(value > 0) {
			_invRate = 1 / value;
		} else {
			value = 0;
			_invRate = 0;
		}

		return rate = value;
	}

	function set_rateMax(value:Float):Float {
		if(value > 0) {
			_invRateMax = 1 / value;
		} else {
			value = 0;
			_invRateMax = 0;
		}

		return rateMax = value;
	}

	function set_duration(value:Float):Float {
		duration = value;
		calcDuration();
		return duration;
	}

	function set_durationMax(value:Float):Float {
		durationMax = value;
		calcDuration();
		return durationMax;
	}

	inline function calcDuration() {
		if(duration >= 0 && durationMax > duration) {
			_duration = randomFloat(duration, durationMax);
		} else {
			_duration = duration;
		}
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function random1To1(){ 
		return random() * 2 - 1; 
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function randomInt(min:Float, ?max:Null<Float>=null):Int {
		return Math.floor(randomFloat(min, max));
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function randomFloat(min:Float, ?max:Null<Float>=null):Float {
		if(max == null) { 
			max = min; 
			min = 0; 
		}
		return random() * (max - min) + min;
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function getTransformX(x:Float, y:Float):Float {
		return transform.world.matrix.getTransformX(x, y);
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function getTransformY(x:Float, y:Float):Float {
		return transform.world.matrix.getTransformY(x, y);
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function getRotateX(x:Float, y:Float):Float {
		return _cosA * x - _sinA * y;
	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function getRotateY(x:Float, y:Float):Float {
		return _sinA * x + _cosA * y;
	}

	@:access(clay.graphics.particles.core.ComponentManager)
	@:noCompletion public function toJson():ParticleEmitterOptions {

		var _modules:Array<Dynamic> = [];
		for (m in modules) {
			_modules.push(m.toJson());
		}

		return { 
			name : name, 
			active : active, 
			enabled : enabled, 

			cacheWrap : cacheWrap, 
			cacheSize : particles.capacity, 
			count : count, 
			countMax : countMax, 
			lifetime : lifetime, 
			lifetimeMax : lifetimeMax, 
			rate : rate,
			rateMax : rateMax,
			duration : duration,
			durationMax : durationMax,
			preprocess : preprocess,
			modulesData : _modules
		};
		
	}

}

typedef ParticleEmitterOptions = {

	?name:String,

	?active:Bool,
	?enabled:Bool,
	?pos:Vector,
	?rotation:Float,
	?scale:Vector,

	?cacheWrap:Bool,
	?cacheSize:Int,
	?count:Int,
	?countMax:Int,
	?lifetime:Float,
	?lifetimeMax:Float,
	?rate:Float,
	?rateMax:Float,
	?duration:Float,
	?durationMax:Float,
	?preprocess:Float,

	?modules:Array<ParticleModule>,

	?modulesData:Array<Dynamic>, // used for json import
	?random:()->Float,
	// ?options:Dynamic,

}
