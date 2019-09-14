package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.ParticleEmitter;


class BurstModule extends ParticleModule {


	public var bursts:Array<Burst>;


	public function new(_options:BurstModuleOptions) {

		super(_options);

		_priority = -1000;

		bursts = [];

		if(_options.bursts != null) {
			for (b in _options.bursts) {
				addBurst(b);
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

	function addBurst(_options:BurstOptions) {
		
		var delay:Float = _options.delay != null ? _options.delay : 0; 
		var delayMax:Float = _options.delayMax != null ? _options.delayMax : 0; 
		var count:Int = _options.count != null ? _options.count : 16; 
		var countMax:Int = _options.countMax != null ? _options.countMax : 0; 
		var cycles:Int = _options.cycles != null ? _options.cycles : -1; 
		var cyclesMax:Int = _options.cyclesMax != null ? _options.cyclesMax : 0; 
		var interval:Float = _options.interval != null ? _options.interval : 1; 
		var intervalMax:Float = _options.intervalMax != null ? _options.intervalMax : 0; 

		var b = new Burst(delay, delayMax, count, countMax, cycles, cyclesMax, interval, intervalMax);
		bursts.push(b);

	}

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		var _brsts:Array<BurstOptions> = d.bursts;
		for (b in _brsts) {
			addBurst(b);
		}

		return this;
	    
	}

	override function toJson():Dynamic {

		var d = super.toJson();

		var _brsts = [];
		for (b in bursts) {
			_brsts.push(
			{
				delay : b.delay,
				delayMax : b.delayMax,
				count : b.count,
				countMax : b.countMax,
				cycles : b.cycles,
				cyclesMax : b.cyclesMax,
				interval : b.interval,
				intervalMax : b.intervalMax
			}
			);
		}

		d.bursts = _brsts;

		return d;
	    
	}

}

@:access(clay.graphics.particles.ParticleEmitter)
private class Burst {


	public var active(default,null):Bool = true;

	public var emitter:ParticleEmitter;

	public var delay:Float;
	public var delayMax:Float;
	public var count:Int;
	public var countMax:Int;
	public var cycles:Int;
	public var cyclesMax:Int;
	public var interval:Float;
	public var intervalMax:Float;

	var _delay:Float = 0;
	var _cycles:Int = -1;
	var _interval:Float = 1;
	var _started:Bool = false;


	public function new(_d:Float, _dm:Float, _c:Int, _cm:Int, _cc:Int, _ccm:Int, _i:Float, _im:Float) {

		delay = _d;
		delayMax = _dm;
		count = _c;
		countMax = _cm;
		cycles = _cc;
		cyclesMax = _ccm;
		interval = _i;
		intervalMax = _im;

		_delay = delay;
		if(delayMax > delay) {
			_delay = emitter.randomFloat(delay,delayMax);
		}

		_cycles = cycles;
		if(cycles > 0 && cyclesMax > cycles) {
			_cycles = emitter.randomInt(cycles,cyclesMax);
		}

		getInterval();

	}


	function doBurst() {

		var _count:Int = count;

		if(countMax > count) {
			_count = emitter.randomInt(count,countMax);
		}

		for (_ in 0..._count) {
			emitter.emit();
		}
		
	}

	function getInterval() {
		
		_interval = interval;
		if(intervalMax > interval) {
			_interval = emitter.randomFloat(interval,intervalMax);
		}

	}

	public function update(dt:Float) {

		if(!_started) {
			if(_delay <= 0) {
				_started = true;
				doBurst();
				_interval -= dt;
			}
			_delay -= dt;
			return;
		}


		if(_interval < 0) {
			if(_cycles > 0) {
				doBurst();
				_cycles--;
				getInterval();
			} else if(_cycles < 0){
				doBurst();
				getInterval();
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
	@:optional var delayMax:Float;
	@:optional var count:Int;
	@:optional var countMax:Int;
	@:optional var cycles:Int;
	@:optional var cyclesMax:Int;
	@:optional var interval:Float;
	@:optional var intervalMax:Float;

}
