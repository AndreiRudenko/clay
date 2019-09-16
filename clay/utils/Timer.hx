package clay.utils;


// import clay.system.TimerManager;

class Timer {
	

		/** How much time the timer was set for. */
	public var timeLimit(default, set):Float = 0;
		/** How many loops the timer was set for. 0 means "looping forever". */
	public var loops:Int = 0;
		/** Pauses or checks the pause state of the timer. */
	public var active(default, set):Bool = false;
		/** Read-only: check to see if the timer is finished. */
	public var finished(default, null):Bool = false;
		/** Use timescale for timer. */
	public var timescaled:Bool = false;
		/** Manual update */
	public var manualUpdate(default, null):Bool = false;

		/** The amount of milliseconds that have elapsed since the timer was started */
	public var time(default, null):Float = 0;
		/** Read-only: how many loops that have elapsed since the timer was started. */
	public var elapsedLoops(get, never):Int;
		/** Read-only: check how much time is left on the timer. */
	public var timeLeft(get, never):Float;
		/** Read-only: check how many loops are left on the timer. */
	public var loopsLeft(get, never):Int;
		/** Read-only: how far along the timer is, on a scale of 0.0 to 1.0. */
	public var progress(get, never):Float;


	var _onComplete:()->Void;
	var _onRepeat:()->Void;
	var _onUpdate:()->Void;

	var _loopsCounter:Int = 0;

	@:noCompletion 
	public var _added:Bool = false;


	@:noCompletion public function new(manualUpdate:Bool = false) {

		this.manualUpdate = manualUpdate;

	}

	public function destroy() {

		Clay.timer.remove(this);
		active = false;
		finished = true;
		_onComplete = null;
		_onRepeat = null;
		_onUpdate = null;

	}

	public inline function start(timelimit:Float, onComplete:()->Void = null):Timer {

		return startFrom(0, timelimit, onComplete);

	}

	public function startFrom(currentTime:Float, timelimit:Float, onComplete:()->Void = null):Timer {

		stop(false); // here we remove from timers array

		Clay.timer.add(this);
		
		active = true;
		finished = false;

		if(onComplete != null){
			_onComplete = onComplete;
		}

		time = currentTime;

		this.timeLimit = timelimit;
		
		loops = 1;
		_loopsCounter = 0;

		return this;

	}

	public function reset(newtime:Float = -1):Timer {

		if (newtime >= 0) {
			timeLimit = newtime;
		}

		if(!_added) {
			Clay.timer.add(this);
		}

		finished = false;
		time = 0;
		
		// loops = 1;
		_loopsCounter = 0;

		return this;

	}

	public function repeat(times:Int = 0):Timer {

		if (times < 0) {
			times *= -1;
		}

		loops = times;

		return this;

	}

	public function stop(finish:Bool = true):Void {

		if(!finished) {
			finished = true;
			active = false;
			
			if (_added){
				Clay.timer.remove(this);
			}
			
			if (finish && _onComplete != null) {
				_onComplete();
			}

		}

	}

	public inline function elapsed(t:Float):Bool {

		return t > time;

	}


	public function onComplete(?onComplete:()->Void):Timer {

		_onComplete = onComplete;

		return this;

	}

	public function onRepeat(?onRepeat:()->Void):Timer {

		_onRepeat = onRepeat;

		return this;

	}

	public function onUpdate(?onUpdate:()->Void):Timer {

		_onUpdate = onUpdate;

		return this;

	}
	
	public function update(dt:Float):Void {

		if(active && !finished) {

			if(timescaled) {
				dt *= Clay.timescale;
			}

			time += dt;
			
			if (_onUpdate != null) {
				_onUpdate();
			}
			
			while (!finished && time > timeLimit) {
				_loopsCounter++;
				
				if (loops > 0 && (_loopsCounter >= loops)) {
					stop();
					break;
				}

				time -= timeLimit;

				if (_onRepeat != null) {
					_onRepeat();
				}
				
			}

		}

	}

	function set_timeLimit(value:Float):Float {

		timeLimit = value > 0 ? value : 0;

		return timeLimit;

	}

	inline function set_active(value:Bool):Bool {

		active = value;

		return active;

	}

	inline function get_timeLeft():Float {

		return timeLimit - time;

	}
	
	inline function get_loopsLeft():Int {

		return loops - _loopsCounter;

	}
	
	inline function get_elapsedLoops():Int {

		return _loopsCounter;

	}
	
	inline function get_progress():Float {

		return (timeLimit > 0) ? (time / timeLimit) : 0;

	}

	inline function get_elapsedTime():Float {

		return time;

	}
	
}

