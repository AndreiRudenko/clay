package clay.particles;


import clay.particles.core.ComponentManager;
import clay.particles.core.Particle;
import clay.particles.core.ParticleData;
import clay.particles.core.ParticleModule;
import clay.particles.core.ParticleVector;
import clay.particles.ParticleSystem;
import clay.math.Vector;
import clay.render.types.BlendMode;
import clay.particles.utils.ModulesFactory;
import clay.particles.render.EmitterRenderer;


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
		/** emitter cache size */
	public var cache_size   (default, null):Int;
		/** emitter cache wrap */
	public var cache_wrap:Bool;

		/** emitter random function */
	public var random:Void->Float;

		/** emitter particles image path */
	public var image_path(default, set):String;

		/** blending src */
	public var blend_src  (default, set):BlendMode;
		/** blending dest */
	public var blend_dest (default, set):BlendMode;

		/** emitter index in particle system */
	public var index       (default, null):Int = 0;

	@:noCompletion public var particles_data:Array<ParticleData>;
	@:noCompletion public var options:ParticleEmitterOptions;

	@:noCompletion public var renderer:EmitterRenderer;

	var time:Float;
	var frame_time:Float;
	var inv_rate:Float;
	var inv_rate_max:Float;
	var _duration:Float;
	var _need_reset:Bool = true;


	public function new(_options:ParticleEmitterOptions) {

		options = _options;

		name = options.name != null ? options.name : 'emitter.${Math.random()}';

		modules = new Map();
		active_modules = [];

		time = 0;
		frame_time = 0;

		cache_size = options.cache_size != null ? options.cache_size : 128;
		if(cache_size <= 0) {
			cache_size = 1;
		}

		particles = new ParticleVector(cache_size);
		components = new ComponentManager(cache_size);
		particles_data = [];

		pos = options.pos != null ? options.pos : new Vector();
		
		active = options.active != null ? options.active : true;
		enabled = options.enabled != null ? options.enabled : true;

		duration = options.duration != null ? options.duration : -1;
		duration_max = options.duration_max != null ? options.duration_max : -1;

		count = options.count != null ? options.count : 1;
		count_max = options.count_max != null ? options.count_max : 0;

		lifetime = options.lifetime != null ? options.lifetime : 1;
		lifetime_max = options.lifetime_max != null ? options.lifetime_max : 0;

		rate = options.rate != null ? options.rate : 10;
		rate_max = options.rate_max != null ? options.rate_max : 0;

		random = options.random != null ? options.random : Math.random;

		image_path = options.image_path;
		
		cache_wrap = options.cache_wrap != null ? options.cache_wrap : false;

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

		renderer.destroy();
		renderer = null;

		components.clear();

		name = null;
		particles = null;
		particles_data = null;
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
			var p:Particle;
			var pd:ParticleData;
			var i:Int = 0;
			var len:Int = particles.length;
			while(i < len) {
				p = particles.get(i);
				pd = particles_data[p.id];
				pd.lifetime -=dt;
				if(pd.lifetime <= 0) {
					unspawn(p);
					len = particles.length;
				} else {
					i++;
				}
			}

			if(enabled && rate > 0) {

				frame_time += dt;

				var _inv_rate:Float;

				while(frame_time > 0) {

					_emit();

					if(rate_max > 0) {
						_inv_rate = random_float(inv_rate, inv_rate_max);
					} else {
						_inv_rate = inv_rate;
					}

					if(_inv_rate == 0) {
						frame_time = 0;
						break;
					}

					frame_time -= _inv_rate;

				}

				time += dt;

				if(_duration >= 0 && time >= _duration) {
					stop();
				}

			}

			// update modules
			for (m in active_modules) {
				m.update(dt);
			}

			// update particle changes to sprite 
			renderer.update(dt);

		}
		
	}

	public function emit() {

		_emit();

	}
	
	public function start(?_dur:Float) {

		enabled = true;
		time = 0;
		frame_time = 0;

		if(_dur == null) {
			calc_duration();
		} else {
			_duration = _dur;
		}

	}

	public function stop(_kill:Bool = false) {

		enabled = false;
		time = 0;
		frame_time = 0;

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

	@:allow(clay.particles.ParticleSystem)
	function init(_ps:ParticleSystem) {

		system = _ps;

		if(ParticleSystem.renderer == null) {
			throw('you need to specify ParticleSystem renderer');
		}

		renderer = ParticleSystem.renderer.get(this);
		renderer.init();

		for (i in 0...particles.capacity) {
			particles_data.push(new ParticleData());
		}

		inited = true;

		for (m in modules) {
			m._init();
		}

		if(options.blend_src != null) {
			blend_src = options.blend_src;
		}

		if(options.blend_dest != null) {
			blend_dest = options.blend_dest;
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
				particles_data[p.id].lifetime = random_float(lifetime, lifetime_max);
			} else {
				particles_data[p.id].lifetime = lifetime;
			}
			m.onspawn(p);
		}
		
	}

	inline function _unspawn_particle(p:Particle) {
		
		for (m in active_modules) {
			m.onunspawn(p);
		}

	}

	@:allow(clay.particles.core.ParticleModule)
	inline function show_particle(p:Particle) { 

		renderer.onparticleshow(p);

	}

	@:allow(clay.particles.core.ParticleModule)
	inline function hide_particle(p:Particle) { 

		renderer.onparticlehide(p);

	}

	@:allow(clay.particles.core.ParticleModule)
	inline function get_particle_data(p:Particle) { 

		return particles_data[p.id];

	}

	@:allow(clay.particles.core.ParticleModule)
	inline function random_1_to_1(){ 

		return random() * 2 - 1; 

	}

	@:allow(clay.particles.core.ParticleModule)
	inline function random_int(min:Float, ?max:Null<Float>=null):Int {

		return Math.floor(random_float(min, max));

	}

	@:allow(clay.particles.core.ParticleModule)
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

	function set_rate(value:Float):Float {

		if(value > 0) {
			inv_rate = 1 / value;
		} else {
			value = 0;
			inv_rate = 0;
		}

		return rate = value;

	}

	function set_rate_max(value:Float):Float {

		if(value > 0) {
			inv_rate_max = 1 / value;
		} else {
			value = 0;
			inv_rate_max = 0;
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

	function set_image_path(t:String):String {

		image_path = t;

		if(renderer != null) {
			renderer.ontexture(image_path);
		}

		return image_path;

	}
	
	function set_blend_src(val:BlendMode)  {

		if(renderer != null) {
			renderer.onblendsrc(val);
		}

		return blend_src = val;

	}

	function set_blend_dest(val:BlendMode) {

		if(renderer != null) {
			renderer.onblenddest(val);
		}

		return blend_dest = val;

	}

	@:access(clay.particles.core.ComponentManager)
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
			image_path : image_path, 
			blend_src : blend_src, 
			blend_dest : blend_dest, 
			modules_data : _modules
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

	@:optional var image_path:String;

	@:optional var blend_src:BlendMode;
	@:optional var blend_dest:BlendMode;
	@:optional var modules:Array<ParticleModule>;

	@:optional var modules_data:Array<Dynamic>; // used for json import
	@:optional var random:Void -> Float;
	@:optional var options: Dynamic;

}

