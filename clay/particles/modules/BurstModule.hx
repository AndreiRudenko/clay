package clay.particles.modules;


import clay.particles.core.Particle;
import clay.particles.core.ParticleModule;
import clay.particles.ParticleEmitter;


class BurstModule extends ParticleModule {


	public var bursts:Array<Burst>;


	public function new(_options:BurstModuleOptions) {

		super(_options);

		_priority = -1000;

		bursts = [];

		if(_options.bursts != null) {
			for (b in _options.bursts) {
				add_burst(b);
			}	
		}

	}

	override function init() {

		for (b in bursts) {
			b.emitter = emitter;
		}
		
	}

	override function update(dt:Float) {

		for (b in bursts) {
			if(b.active) {
				b.update(dt);
			}
		}

	}

	function add_burst(_options:BurstOptions) {
		
		var delay:Float = _options.delay != null ? _options.delay : 0; 
		var delay_max:Float = _options.delay_max != null ? _options.delay_max : 0; 
		var count:Int = _options.count != null ? _options.count : 16; 
		var count_max:Int = _options.count_max != null ? _options.count_max : 0; 
		var cycles:Int = _options.cycles != null ? _options.cycles : -1; 
		var cycles_max:Int = _options.cycles_max != null ? _options.cycles_max : 0; 
		var interval:Float = _options.interval != null ? _options.interval : 1; 
		var interval_max:Float = _options.interval_max != null ? _options.interval_max : 0; 

		var b = new Burst(delay, delay_max, count, count_max, cycles, cycles_max, interval, interval_max);
		bursts.push(b);

	}

	override function from_json(d:Dynamic) {

		super.from_json(d);

		var _brsts:Array<BurstOptions> = d.bursts;
		for (b in _brsts) {
			add_burst(b);
		}

		return this;
	    
	}

	override function to_json():Dynamic {

		var d = super.to_json();

		var _brsts = [];
		for (b in bursts) {
			_brsts.push(
			{
				delay : b.delay,
				delay_max : b.delay_max,
				count : b.count,
				count_max : b.count_max,
				cycles : b.cycles,
				cycles_max : b.cycles_max,
				interval : b.interval,
				interval_max : b.interval_max
			}
			);
		}

		d.bursts = _brsts;

		return d;
	    
	}

}

@:access(clay.particles.ParticleEmitter)
private class Burst {


	public var active(default,null):Bool = true;

	public var emitter:ParticleEmitter;

	public var delay:Float;
	public var delay_max:Float;
	public var count:Int;
	public var count_max:Int;
	public var cycles:Int;
	public var cycles_max:Int;
	public var interval:Float;
	public var interval_max:Float;

	var _delay:Float = 0;
	var _cycles:Int = -1;
	var _interval:Float = 1;
	var _started:Bool = false;


	public function new(_d:Float, _dm:Float, _c:Int, _cm:Int, _cc:Int, _ccm:Int, _i:Float, _im:Float) {

		delay = _d;
		delay_max = _dm;
		count = _c;
		count_max = _cm;
		cycles = _cc;
		cycles_max = _ccm;
		interval = _i;
		interval_max = _im;

		_delay = delay;
		if(delay_max > delay) {
			_delay = emitter.random_float(delay,delay_max);
		}

		_cycles = cycles;
		if(cycles > 0 && cycles_max > cycles) {
			_cycles = emitter.random_int(cycles,cycles_max);
		}

		get_interval();

	}


	function do_burst() {

		var _count:Int = count;

		if(count_max > count) {
			_count = emitter.random_int(count,count_max);
		}

		for (_ in 0..._count) {
			emitter.emit();
		}
		
	}

	function get_interval() {
		
		_interval = interval;
		if(interval_max > interval) {
			_interval = emitter.random_float(interval,interval_max);
		}

	}

	public function update(dt:Float) {

		if(!_started) {
			if(_delay <= 0) {
				_started = true;
				do_burst();
				_interval -= dt;
			}
			_delay -= dt;
			return;
		}


		if(_interval < 0) {
			if(_cycles > 0) {
				do_burst();
				_cycles--;
				get_interval();
			} else if(_cycles < 0){
				do_burst();
				get_interval();
			} else {
				active = false;
			}
		}
		_interval -= dt;

	}


}



typedef BurstModuleOptions = {

	>ParticleModuleOptions,

	@:optional var bursts:Array<BurstOptions>;

}


typedef BurstOptions = {

	>ParticleModuleOptions,

	@:optional var delay:Float;
	@:optional var delay_max:Float;
	@:optional var count:Int;
	@:optional var count_max:Int;
	@:optional var cycles:Int;
	@:optional var cycles_max:Int;
	@:optional var interval:Float;
	@:optional var interval_max:Float;

}
