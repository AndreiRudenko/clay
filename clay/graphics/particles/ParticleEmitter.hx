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


	public var inited      (default, null):Bool = false;
		/** if the emitter is active, it will update */
	public var active:Bool;
		/** if the emitter is enabled, it's spawn and update modules */
	public var enabled      (default, null):Bool = false;
		/** emitter name */
	public var name:String;
		/** offset from system position */
	public var pos          (default, null):Vector;

		/** emitter particles */
	public var particles 	(default, null):ParticleVector;
		/** particles components */
	public var components	(default, null):ComponentManager;
		/** emitter modules */
	public var modules   	(default, null):Map<String, ParticleModule>;
		/** active emitter modules */
	public var active_modules   	(default, null):Array<ParticleModule>;
		/** reference to system */
	public var system    	(default, null):ParticleSystem;

		/** number of particles per emit */
	public var count:Int; // todo: if cache_size < count
		/** number of particles per emit max */
	public var count_max:Int;

		/** lifetime for particles */
	public var lifetime:Float;
		/** max lifetime for particles, if > 0, 
			particle lifetime is random between lifetime and lifetime_max */
	public var lifetime_max:Float;

		/** emitter rate, particles per sec */
	public var rate    	(default, set):Float;
		/** emitter rate, max particles per sec */
	public var rate_max	(default, set):Float;

		/** emitter duration */
	public var duration    	(default, set):Float;
		/** emitter duration max*/
	public var duration_max	(default, set):Float;
		/** preprocess particles in seconds */
	public var preprocess(default, null):Float;
		/** emitter cache size */
	public var cache_size   (default, null):Int;
		/** emitter cache wrap */
	public var cache_wrap:Bool;

		/** emitter random function */
	public var random:()->Float;

		/** blending src */
	public var blend_src:BlendMode;
		/** blending dest */
	public var blend_dst:BlendMode;
		/** blending equation */
	public var blend_eq:BlendEquation;
		/** alpha blending src */
	public var alpha_blend_src:BlendMode;
		/** alpha blending dest */
	public var alpha_blend_dst:BlendMode;
		/** alpha blending equation */
	public var alpha_blend_eq:BlendEquation;

		/** emitter particles sort mode */
	public var sortmode:ParticlesSortMode;
		/** custom particles sort function */
	public var sort_func:(p1:Particle, p2:Particle)->Int;

		/** emitter index in particle system */
	public var index(default, null):Int = 0;

	@:noCompletion public var options:ParticleEmitterOptions;

	var _time:Float;
	var _frame_time:Float;
	var _inv_rate:Float;
	var _inv_rate_max:Float;
	var _duration:Float;
	var _preprocess:Float;
	var _need_reset:Bool = true;


	public function new(_options:ParticleEmitterOptions) {

		options = _options;

		name = options.name != null ? options.name : 'emitter.${Math.random()}';

		modules = new Map();
		active_modules = [];

		_time = 0;
		_frame_time = 0;
		_preprocess = 0;

		cache_size = options.cache_size != null ? options.cache_size : 128;
		if(cache_size <= 0) {
			cache_size = 1;
		}

		components = new ComponentManager(cache_size);
		particles = new ParticleVector(components, cache_size);

		pos = options.pos != null ? options.pos : new Vector();
		
		active = options.active != null ? options.active : true;
		enabled = options.enabled != null ? options.enabled : false;

		duration = options.duration != null ? options.duration : -1;
		duration_max = options.duration_max != null ? options.duration_max : -1;
		preprocess = options.preprocess != null ? options.preprocess : 0;

		count = options.count != null ? options.count : 1;
		count_max = options.count_max != null ? options.count_max : 0;

		lifetime = options.lifetime != null ? options.lifetime : 1;
		lifetime_max = options.lifetime_max != null ? options.lifetime_max : 0;

		rate = options.rate != null ? options.rate : 10;
		rate_max = options.rate_max != null ? options.rate_max : 0;

		random = options.random != null ? options.random : Math.random;

		// if(options.texture != null) {
		// 	texture = options.texture;
		// } else if(options.image_path != null) {
		// 	image_path = options.image_path;
		// }

		// region = options.region;
		sort_func = options.sort_func;
		
		cache_wrap = options.cache_wrap != null ? options.cache_wrap : false;
		sortmode = options.sortmode != null ? options.sortmode : ParticlesSortMode.none;
		
		blend_src = options.blend_src != null ? options.blend_src : BlendMode.BlendOne;
		blend_dst = options.blend_dst != null ? options.blend_dst : BlendMode.InverseSourceAlpha;
		blend_eq = options.blend_eq != null ? options.blend_eq : BlendEquation.Add;

		alpha_blend_src = options.alpha_blend_src != null ? options.alpha_blend_src : BlendMode.BlendOne;
		alpha_blend_dst = options.alpha_blend_dst != null ? options.alpha_blend_dst : BlendMode.InverseSourceAlpha;
		alpha_blend_eq = options.alpha_blend_eq != null ? options.alpha_blend_eq : BlendEquation.Add;

		if(options.modules != null) {
			for (m in options.modules) {
				add_module(m);
			}
		}
		
		// create modules from data
		if(options.modules_data != null) {
			var _classname:String;
			for (md in options.modules_data) {
				_classname = md.name;
				var m = ModulesFactory.create(_classname, md);
				if(m != null) {
					add_module(m.from_json(md));
				}
			}
		}

	}

	public function destroy() {
		
		for (m in modules) {
			m.ondestroy();
		}

		components.clear();

		name = null;
		particles = null;
		components = null;
		modules = null;
		active_modules = null;
		system = null;

	}

	public function reset() {

		for (m in modules) {
			m.onreset();
		}

	}

	public function add_module(_module:ParticleModule):ParticleEmitter {

		var cname:String = Type.getClassName(Type.getClass(_module));

		if(modules.exists(cname)) {
			throw('particle module: $cname already exists');
		}

		modules.set(cname, _module);
		_module._onadded(this);

		if(_module.enabled) {
			_enable_m(_module);
		}

		if(inited) {
			_module._init();
		}

		return this;

	}

	public function get_module<T:ParticleModule>(_module_class:Class<T>):T {

		return cast modules.get(Type.getClassName(_module_class));
		
	}

	public function remove_module<T:ParticleModule>(_module_class:Class<T>):T {

		var cname:String = Type.getClassName(_module_class);

		var _module:T = cast modules.get(cname);

		if(_module != null) {
			if(_module.enabled) {
				_disable_m(_module);
			}

			modules.remove(cname);
			_module._onremoved();

			if(_need_reset) {
				reset_modules();
			}
		}

		return _module;
		
	}

	public function enable_module(_module_class:Class<Dynamic>) {
		
		var cname:String = Type.getClassName(_module_class);
		var m = modules.get(cname);
		if(m == null) {
			throw('module: $cname doesnt exists');
		}

		if(!m.enabled) {
			_enable_m(m);
		}

	}

	public function disable_module(_module_class:Class<Dynamic>) {
		
		var cname:String = Type.getClassName(_module_class);
		var m = modules.get(cname);
		if(m == null) {
			throw('module: $cname doesnt exists');
		}

		if(m.enabled) {
			_disable_m(m);
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

				_frame_time += dt;

				var ir:Float;

				while(_frame_time > 0) {

					_emit();

					if(rate_max > 0) {
						ir = random_float(_inv_rate, _inv_rate_max);
					} else {
						ir = _inv_rate;
					}

					if(ir == 0) {
						_frame_time = 0;
						break;
					}

					_frame_time -= ir;

				}

				_time += dt;

				if(_duration >= 0 && _time >= _duration) {
					stop();
				}

			}

			for (m in active_modules) {
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

		p.set_blendmode(blend_src, blend_dst, blend_eq, alpha_blend_src, alpha_blend_dst, alpha_blend_eq);

		for (m in active_modules) {
			m.render(p);
		}
		
	}

	public function emit() {

		_emit();

	}
	
	public function start(?_dur:Float) {

		enabled = true;
		_time = 0;
		_frame_time = 0;

		_preprocess = preprocess;

		if(_dur == null) {
			calc_duration();
		} else {
			_duration = _dur;
		}

	}

	public function stop(_kill:Bool = false) {

		enabled = false;
		_time = 0;
		_frame_time = 0;

		if(_kill) {
			unspawn_all();
		}

	}

	public function unspawn_all() {
		
		for (p in particles) {
			for (m in modules) {
				m.onunspawn(p);
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
		_unspawn_particle(p);
		
	}

	public function get_sorted_particles():haxe.ds.Vector<Particle> {
		
		switch (sortmode) {
			case ParticlesSortMode.lifetime: return particles.sort(lifetime_sort);
			case ParticlesSortMode.youngest: return particles.sort(youngest_sort);
			case ParticlesSortMode.oldest: return particles.sort(oldest_sort);
			case ParticlesSortMode.custom: return particles.sort(sort_func);
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

		if(count_max > 0) {
			_count = random_int(count, count_max);
		} else {
			_count = count;
		}

		_count = _count > cache_size ? cache_size : _count;

		for (_ in 0..._count) {
			spawn();
		}

	}

	function reset_modules() { // todo: remove this?

		_need_reset = false;

		for (m in active_modules) {
			m.ondisabled();
		}

		for (m in modules) {
			m._onremoved();
		}

		for (m in modules) {
			m._onadded(this);
		}

		for (m in active_modules) {
			m.onenabled();
		}

		for (m in modules) {
			m._init();
		}
		
		_need_reset = true;

	}

	inline function _enable_m(m:ParticleModule) {
		
		var added:Bool = false;
		var am:ParticleModule = null;
		for (i in 0...active_modules.length) {
			am = active_modules[i];
			if (m.priority <= am.priority) {
				active_modules.insert(i,m);
				added = true;
				break;
			}
		}
		
		if(!added) {
			active_modules.push(m);
		}

		m.onenabled();

	}

	inline function _disable_m(m:ParticleModule) {

		m.ondisabled();
		active_modules.remove(m);
		
	}

	inline function _sort_active() {

		haxe.ds.ArraySort.sort(
			active_modules,
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
			_spawn_particle(particles.ensure());
		} else if(cache_wrap) {
			var p:Particle = particles.wrap();
			_unspawn_particle(p);
			_spawn_particle(p);
		}

	}

	inline function _spawn_particle(p:Particle) {

		for (m in active_modules) {
			if(lifetime_max > 0) {
				p.lifetime = random_float(lifetime, lifetime_max);
			} else {
				p.lifetime = lifetime;
			}
			p.age = 0;
			m.onspawn(p);
		}
		
	}

	inline function _unspawn_particle(p:Particle) {
		
		for (m in active_modules) {
			m.onunspawn(p);
		}

	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function random_1_to_1(){ 

		return random() * 2 - 1; 

	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function random_int(min:Float, ?max:Null<Float>=null):Int {

		return Math.floor(random_float(min, max));

	}

	@:allow(clay.graphics.particles.core.ParticleModule)
	inline function random_float(min:Float, ?max:Null<Float>=null):Float {

		if(max == null) { 
			max = min; 
			min = 0; 
		}

		return random() * ( max - min ) + min;
		
	}

	inline function calc_duration() {

		if(duration >= 0 && duration_max > duration) {
			_duration = random_float(duration, duration_max);
		} else {
			_duration = duration;
		}
		
	}

	function lifetime_sort(a:Particle, b:Particle):Int {

		return a.lifetime < b.lifetime ? -1 : 1;
		
	}

	function youngest_sort(a:Particle, b:Particle):Int {

		return a.age > b.age ? -1 : 1;

	}

	function oldest_sort(a:Particle, b:Particle):Int {

		return a.age < b.age ? -1 : 1;

	}

	function set_rate(value:Float):Float {

		if(value > 0) {
			_inv_rate = 1 / value;
		} else {
			value = 0;
			_inv_rate = 0;
		}

		return rate = value;

	}

	function set_rate_max(value:Float):Float {

		if(value > 0) {
			_inv_rate_max = 1 / value;
		} else {
			value = 0;
			_inv_rate_max = 0;
		}

		return rate_max = value;

	}

	function set_duration(value:Float):Float {

		duration = value;
		
		calc_duration();

		return duration;

	}

	function set_duration_max(value:Float):Float {

		duration_max = value;

		calc_duration();

		return duration_max;

	}

	@:access(clay.graphics.particles.core.ComponentManager)
	@:noCompletion public function to_json():ParticleEmitterOptions {

		var _modules:Array<Dynamic> = [];
		for (m in modules) {
			_modules.push(m.to_json());
		}

		return { 
			name : name, 
			active : active, 
			enabled : enabled, 
			cache_wrap : cache_wrap, 
			cache_size : particles.capacity, 
			count : count, 
			count_max : count_max, 
			lifetime : lifetime, 
			lifetime_max : lifetime_max, 
			rate : rate, 
			rate_max : rate_max, 
			duration : duration, 
			duration_max : duration_max, 
			// image_path : image_path, 
			blend_src : blend_src, 
			blend_dst : blend_dst, 
			modules_data : _modules,
			sortmode : sortmode
		};
		
	}

}

typedef ParticleEmitterOptions = {

	@:optional var name:String;

	@:optional var active:Bool;
	@:optional var enabled:Bool;
	@:optional var pos:Vector;

	@:optional var cache_wrap:Bool;
	@:optional var cache_size:Int;
	@:optional var count:Int;
	@:optional var count_max:Int;
	@:optional var lifetime:Float;
	@:optional var lifetime_max:Float;
	@:optional var rate:Float;
	@:optional var rate_max:Float;
	@:optional var duration:Float;
	@:optional var duration_max:Float;
	@:optional var preprocess:Float;

	// @:optional var image_path:String;
	// @:optional var texture:Texture;
	// @:optional var region:Rectangle;

	@:optional var blend_src:BlendMode;
	@:optional var blend_dst:BlendMode;
	@:optional var blend_eq:BlendEquation;
	@:optional var alpha_blend_src:BlendMode;
	@:optional var alpha_blend_dst:BlendMode;
	@:optional var alpha_blend_eq:BlendEquation;
	@:optional var modules:Array<ParticleModule>;

	@:optional var modules_data:Array<Dynamic>; // used for json import
	@:optional var random:()->Float;
	@:optional var options:Dynamic;
	@:optional var sortmode:ParticlesSortMode;
	@:optional var sort_func:(p1:Particle, p2:Particle)->Int;

}

@:enum abstract ParticlesSortMode(UInt) from UInt to UInt {
	
	var none              = 0;
	var lifetime          = 1;
	var youngest          = 2;
	var oldest            = 3;
	var custom            = 4;

}