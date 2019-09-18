package clay.graphics.particles;


import clay.graphics.particles.ParticleSystem;
import clay.graphics.particles.core.ComponentManager;
import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.ParticleVector;
import clay.graphics.particles.utils.ModulesFactory;
import clay.math.Vector;
import clay.math.Rectangle;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.render.Painter;
import clay.render.types.BlendEquation;
import clay.resources.Texture;


class ParticleEmitter {


	public var inited(default, null):Bool = false;
		/** if the emitter is active, it will update */
	public var active:Bool;
		/** if the emitter is enabled, it's spawn and update modules */
	public var enabled(default, null):Bool = false;
		/** emitter name */
	public var name:String;
		/** offset from system position */
	public var pos(default, null):Vector;

		/** emitter particles */
	public var particles(default, null):ParticleVector;
		/** particles components */
	public var components(default, null):ComponentManager;
		/** emitter modules */
	public var modules(default, null):Map<String, ParticleModule>;
		/** active emitter modules */
	public var activeModules(default, null):Array<ParticleModule>;
		/** reference to system */
	public var system(default, null):ParticleSystem;

		/** number of particles per emit */
	public var count:Int; // todo: if cacheSize < count
		/** number of particles per emit max */
	public var countMax:Int;

		/** lifetime for particles */
	public var lifetime:Float;
		/** max lifetime for particles, if > 0, 
			particle lifetime is random between lifetime and lifetimeMax */
	public var lifetimeMax:Float;

		/** emitter rate, particles per sec */
	public var rate(default, set):Float;
		/** emitter rate, max particles per sec */
	public var rateMax(default, set):Float;

		/** emitter duration */
	public var duration(default, set):Float;
		/** emitter duration max*/
	public var durationMax(default, set):Float;
		/** preprocess particles in seconds */
	public var preprocess(default, null):Float;
		/** emitter cache size */
	public var cacheSize(default, null):Int;
		/** emitter cache wrap */
	public var cacheWrap:Bool;

		/** emitter random function */
	public var random:()->Float;

		/** blending src */
	public var blendSrc:BlendMode;
		/** blending dest */
	public var blendDst:BlendMode;
		/** blending equation */
	public var blendEq:BlendEquation;
		/** alpha blending src */
	public var alphaBlendSrc:BlendMode;
		/** alpha blending dest */
	public var alphaBlendDst:BlendMode;
		/** alpha blending equation */
	public var alphaBlendEq:BlendEquation;

		/** emitter particles sort mode */
	public var sortmode:ParticlesSortMode;
		/** custom particles sort function */
	public var sortFunc:(p1:Particle, p2:Particle)->Int;

		/** emitter index in particle system */
	public var index(default, null):Int = 0;

	@:noCompletion public var options:ParticleEmitterOptions;

	var _time:Float;
	var _frameTime:Float;
	var _invRate:Float;
	var _invRateMax:Float;
	var _duration:Float;
	var _preprocess:Float;
	var _needReset:Bool = true;


	public function new(_options:ParticleEmitterOptions) {

		options = _options;

		name = options.name != null ? options.name : 'emitter.${Math.random()}';

		modules = new Map();
		activeModules = [];

		_time = 0;
		_frameTime = 0;
		_preprocess = 0;

		cacheSize = options.cacheSize != null ? options.cacheSize : 128;
		if(cacheSize <= 0) {
			cacheSize = 1;
		}

		components = new ComponentManager(cacheSize);
		particles = new ParticleVector(components, cacheSize);

		pos = options.pos != null ? options.pos : new Vector();
		
		active = options.active != null ? options.active : true;
		enabled = options.enabled != null ? options.enabled : false;

		duration = options.duration != null ? options.duration : -1;
		durationMax = options.durationMax != null ? options.durationMax : -1;
		preprocess = options.preprocess != null ? options.preprocess : 0;

		count = options.count != null ? options.count : 1;
		countMax = options.countMax != null ? options.countMax : 0;

		lifetime = options.lifetime != null ? options.lifetime : 1;
		lifetimeMax = options.lifetimeMax != null ? options.lifetimeMax : 0;

		rate = options.rate != null ? options.rate : 10;
		rateMax = options.rateMax != null ? options.rateMax : 0;

		random = options.random != null ? options.random : Math.random;

		// if(options.texture != null) {
		// 	texture = options.texture;
		// } else if(options.imagePath != null) {
		// 	imagePath = options.imagePath;
		// }

		// region = options.region;
		sortFunc = options.sortFunc;
		
		cacheWrap = options.cacheWrap != null ? options.cacheWrap : false;
		sortmode = options.sortmode != null ? options.sortmode : ParticlesSortMode.NONE;
		
		blendSrc = options.blendSrc != null ? options.blendSrc : BlendMode.BlendOne;
		blendDst = options.blendDst != null ? options.blendDst : BlendMode.InverseSourceAlpha;
		blendEq = options.blendEq != null ? options.blendEq : BlendEquation.Add;

		alphaBlendSrc = options.alphaBlendSrc != null ? options.alphaBlendSrc : BlendMode.BlendOne;
		alphaBlendDst = options.alphaBlendDst != null ? options.alphaBlendDst : BlendMode.InverseSourceAlpha;
		alphaBlendEq = options.alphaBlendEq != null ? options.alphaBlendEq : BlendEquation.Add;

		if(options.modules != null) {
			for (m in options.modules) {
				addModule(m);
			}
		}
		
		// create modules from data
		if(options.modulesData != null) {
			var _classname:String;
			for (md in options.modulesData) {
				_classname = md.name;
				var m = ModulesFactory.create(_classname, md);
				if(m != null) {
					addModule(m.fromJson(md));
				}
			}
		}

	}

	public function destroy() {
		
		for (m in modules) {
			m.onDestroy();
		}

		components.clear();

		name = null;
		particles = null;
		components = null;
		modules = null;
		activeModules = null;
		system = null;

	}

	public function reset() {

		for (m in modules) {
			m.onReset();
		}

	}

	public function addModule(_module:ParticleModule):ParticleEmitter {

		var cname:String = Type.getClassName(Type.getClass(_module));

		if(modules.exists(cname)) {
			throw('particle module: $cname already exists');
		}

		modules.set(cname, _module);
		_module._onAdded(this);

		if(_module.enabled) {
			_enableM(_module);
		}

		if(inited) {
			_module._init();
		}

		return this;

	}

	public function getModule<T:ParticleModule>(_moduleClass:Class<T>):T {

		return cast modules.get(Type.getClassName(_moduleClass));
		
	}

	public function removeModule<T:ParticleModule>(_moduleClass:Class<T>):T {

		var cname:String = Type.getClassName(_moduleClass);

		var _module:T = cast modules.get(cname);

		if(_module != null) {
			if(_module.enabled) {
				_disableM(_module);
			}

			modules.remove(cname);
			_module._onRemoved();

			if(_needReset) {
				resetModules();
			}
		}

		return _module;
		
	}

	public function enableModule(_moduleClass:Class<Dynamic>) {
		
		var cname:String = Type.getClassName(_moduleClass);
		var m = modules.get(cname);
		if(m == null) {
			throw('module: $cname doesnt exists');
		}

		if(!m.enabled) {
			_enableM(m);
		}

	}

	public function disableModule(_moduleClass:Class<Dynamic>) {
		
		var cname:String = Type.getClassName(_moduleClass);
		var m = modules.get(cname);
		if(m == null) {
			throw('module: $cname doesnt exists');
		}

		if(m.enabled) {
			_disableM(m);
		}

	}

	public function update(dt:Float) {

		if(active) {

			// check lifetime
			var pd:Particle;
			var i:Int = 0;
			var len:Int = particles.length;
			while(i < len) {
				pd = particles.get(i);
				pd.lifetime -=dt;
				pd.age += dt;
				if(pd.lifetime <= 0) {
					unspawn(pd);
					len = particles.length;
				} else {
					i++;
				}
			}

			if(enabled && rate > 0) {

				_frameTime += dt;

				var ir:Float;

				while(_frameTime > 0) {

					_emit();

					if(rateMax > 0) {
						ir = randomFloat(_invRate, _invRateMax);
					} else {
						ir = _invRate;
					}

					if(ir == 0) {
						_frameTime = 0;
						break;
					}

					_frameTime -= ir;

				}

				_time += dt;

				if(_duration >= 0 && _time >= _duration) {
					stop();
				}

			}

			for (m in activeModules) {
				m.update(dt);
			}

			if(_preprocess > 0) {
				while((_preprocess -= dt) > 0) {
					update(dt);
				}
			}

		}
		
	}

	public function render(p:Painter) {

		p.setBlendMode(blendSrc, blendDst, blendEq, alphaBlendSrc, alphaBlendDst, alphaBlendEq);

		for (m in activeModules) {
			m.render(p);
		}
		
	}

	public function emit() {

		_emit();

	}
	
	public function start(?_dur:Float) {

		enabled = true;
		_time = 0;
		_frameTime = 0;

		_preprocess = preprocess;

		if(_dur == null) {
			calcDuration();
		} else {
			_duration = _dur;
		}

	}

	public function stop(_kill:Bool = false) {

		enabled = false;
		_time = 0;
		_frameTime = 0;

		if(_kill) {
			unspawnAll();
		}

	}

	public function unspawnAll() {
		
		for (p in particles) {
			for (m in modules) {
				m.onUnSpawn(p);
			}
		}
		particles.reset();

	}

	public function pause() {
		
		active = false;

	}

	public function unpause() {

		active = true;
		
	}

	public function unspawn(p:Particle) {

		particles.remove(p);
		_unspawnParticle(p);
		
	}

	public function getSortedParticles():haxe.ds.Vector<Particle> {
		
		switch (sortmode) {
			case ParticlesSortMode.LIFETIME: return particles.sort(lifetimeSort);
			case ParticlesSortMode.YOUNGEST: return particles.sort(youngestSort);
			case ParticlesSortMode.OLDEST: return particles.sort(oldestSort);
			case ParticlesSortMode.CUSTOM: return particles.sort(sortFunc);
			default: return particles.buffer;
		}
	}

	@:allow(clay.graphics.particles.ParticleSystem)
	function init(_ps:ParticleSystem) {

		system = _ps;
		inited = true;

		for (m in modules) {
			m._init();
		}

	}

	function _emit() {

		var _count:Int;

		if(countMax > 0) {
			_count = randomInt(count, countMax);
		} else {
			_count = count;
		}

		_count = _count > cacheSize ? cacheSize : _count;

		for (_ in 0..._count) {
			spawn();
		}

	}

	function resetModules() { // todo: remove this?

		_needReset = false;

		for (m in activeModules) {
			m.onDisabled();
		}

		for (m in modules) {
			m._onRemoved();
		}

		for (m in modules) {
			m._onAdded(this);
		}

		for (m in activeModules) {
			m.onEnabled();
		}

		for (m in modules) {
			m._init();
		}
		
		_needReset = true;

	}

	inline function _enableM(m:ParticleModule) {
		
		var added:Bool = false;
		var am:ParticleModule = null;
		for (i in 0...activeModules.length) {
			am = activeModules[i];
			if (m.priority <= am.priority) {
				activeModules.insert(i,m);
				added = true;
				break;
			}
		}
		
		if(!added) {
			activeModules.push(m);
		}

		m.onEnabled();

	}

	inline function _disableM(m:ParticleModule) {

		m.onDisabled();
		activeModules.remove(m);
		
	}

	inline function _sortActive() {

		haxe.ds.ArraySort.sort(
			activeModules,
			function(a,b) {
				if (a.priority < b.priority) {
					return -1;
				} else if (a.priority > b.priority) {
					return 1;
				}
				return 0;
			}
		);
		
	}

	inline function spawn() {

		if(particles.length < particles.capacity) {
			_spawnParticle(particles.ensure());
		} else if(cacheWrap) {
			var p:Particle = particles.wrap();
			_unspawnParticle(p);
			_spawnParticle(p);
		}

	}

	inline function _spawnParticle(p:Particle) {

		for (m in activeModules) {
			if(lifetimeMax > 0) {
				p.lifetime = randomFloat(lifetime, lifetimeMax);
			} else {
				p.lifetime = lifetime;
			}
			p.age = 0;
			m.onSpawn(p);
		}
		
	}

	inline function _unspawnParticle(p:Particle) {
		
		for (m in activeModules) {
			m.onUnSpawn(p);
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

		return random() * ( max - min ) + min;
		
	}

	inline function calcDuration() {

		if(duration >= 0 && durationMax > duration) {
			_duration = randomFloat(duration, durationMax);
		} else {
			_duration = duration;
		}
		
	}

	function lifetimeSort(a:Particle, b:Particle):Int {

		return a.lifetime < b.lifetime ? -1 : 1;
		
	}

	function youngestSort(a:Particle, b:Particle):Int {

		return a.age > b.age ? -1 : 1;

	}

	function oldestSort(a:Particle, b:Particle):Int {

		return a.age < b.age ? -1 : 1;

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
			// imagePath : imagePath, 
			blendSrc : blendSrc, 
			blendDst : blendDst, 
			modulesData : _modules,
			sortmode : sortmode
		};
		
	}

}

typedef ParticleEmitterOptions = {

	@:optional var name:String;

	@:optional var active:Bool;
	@:optional var enabled:Bool;
	@:optional var pos:Vector;

	@:optional var cacheWrap:Bool;
	@:optional var cacheSize:Int;
	@:optional var count:Int;
	@:optional var countMax:Int;
	@:optional var lifetime:Float;
	@:optional var lifetimeMax:Float;
	@:optional var rate:Float;
	@:optional var rateMax:Float;
	@:optional var duration:Float;
	@:optional var durationMax:Float;
	@:optional var preprocess:Float;

	// @:optional var imagePath:String;
	// @:optional var texture:Texture;
	// @:optional var region:Rectangle;

	@:optional var blendSrc:BlendMode;
	@:optional var blendDst:BlendMode;
	@:optional var blendEq:BlendEquation;
	@:optional var alphaBlendSrc:BlendMode;
	@:optional var alphaBlendDst:BlendMode;
	@:optional var alphaBlendEq:BlendEquation;
	@:optional var modules:Array<ParticleModule>;

	@:optional var modulesData:Array<Dynamic>; // used for json import
	@:optional var random:()->Float;
	@:optional var options:Dynamic;
	@:optional var sortmode:ParticlesSortMode;
	@:optional var sortFunc:(p1:Particle, p2:Particle)->Int;

}

@:enum abstract ParticlesSortMode(UInt) from UInt to UInt {
	
	var NONE              = 0;
	var LIFETIME          = 1;
	var YOUNGEST          = 2;
	var OLDEST            = 3;
	var CUSTOM            = 4;

}