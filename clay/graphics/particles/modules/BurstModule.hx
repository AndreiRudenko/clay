package clay.graphics.particles.modules;


import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.ParticleEmitter;


class BurstModule extends ParticleModule {


	public var bursts:Array<Burst>;

	public var onBurstCallback:(pe:ParticleEmitter)->Void;


	public function new(options:BurstModuleOptions) {

		super(options);

		_priority = -1000;

		bursts = [];

		if(options.bursts != null) {
			for (b in options.bursts) {
				addBurst(b);
			}	
		}

		onBurstCallback = options.onBurst;

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

	public function addBurst(options:BurstOptions):Burst {
		
		var delay:Float = options.delay != null ? options.delay : 0; 
		var delayMax:Float = options.delayMax != null ? options.delayMax : 0; 
		var count:Int = options.count != null ? options.count : 16; 
		var countMax:Int = options.countMax != null ? options.countMax : 0; 
		var cycles:Int = options.cycles != null ? options.cycles : -1; 
		var cyclesMax:Int = options.cyclesMax != null ? options.cyclesMax : 0; 
		var interval:Float = options.interval != null ? options.interval : 1; 
		var intervalMax:Float = options.intervalMax != null ? options.intervalMax : 0; 

		var b = new Burst(this, delay, delayMax, count, countMax, cycles, cyclesMax, interval, intervalMax);
		bursts.push(b);

		return b;

	}

	public function removeBurst(b:Burst):Bool {
		
		return bursts.remove(b);

	}

	override function fromJson(d:Dynamic) {

		super.fromJson(d);

		var brsts:Array<BurstOptions> = d.bursts;
		for (b in brsts) {
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
	public var module:BurstModule;

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


	public function new(module:BurstModule, _d:Float, _dm:Float, _c:Int, _cm:Int, _cc:Int, _ccm:Int, _i:Float, _im:Float) {

		this.module = module;
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

		if(module.onBurstCallback != null) {
			module.onBurstCallback(emitter);
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
	@:optional var onBurst:(pe:ParticleEmitter)->Void;

}


typedef BurstOptions = {

	@:optional var delay:Float;
	@:optional var delayMax:Float;
	@:optional var count:Int;
	@:optional var countMax:Int;
	@:optional var cycles:Int;
	@:optional var cyclesMax:Int;
	@:optional var interval:Float;
	@:optional var intervalMax:Float;

}
