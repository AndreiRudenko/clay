package clay.utils;


class Timer {

	public static var globalManager:TimerManager;

	public var timeLimit(default, set):Float;
	public var loops:Int;
	public var active:Bool;
	public var finished(default, null):Bool;
	public var timescaled:Bool = false;
	public var manualUpdate(default, set):Bool;

	public var time(default, null):Float;
	public var elapsedLoops(get, never):Int;
	public var timeLeft(get, never):Float;
	public var loopsLeft(get, never):Int;
	public var progress(get, never):Float;

	public var manager(default, set):TimerManager;

	var _onComplete:()->Void;
	var _onRepeat:()->Void;
	var _onUpdate:()->Void;

	var _loopsCounter:Int = 0;
	var _added:Bool = false;

	@:noCompletion public function new(?manager:TimerManager) {
		timeLimit = 0;
		loops = 0;
		active = false;
		finished = false;
		time = 0;
		manualUpdate = false;
		this.manager = manager != null ? manager : globalManager;
	}

	public function destroy() {
		removeFromManager();
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
		if(!_added) {
			addToManager();
		}
		
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
			addToManager();
		}

		finished = false;
		time = 0;
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
			active = false;
			finished = true;
			
			if (_added){
				removeFromManager();
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
	
	public function update(elapsed:Float):Void {
		if(active && !finished) {
			if(timescaled && manager != null) {
				elapsed *= manager.timescale;
			}

			time += elapsed;
			
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

	function set_manualUpdate(v:Bool):Bool {
		manualUpdate = v;
		if(active) {
			if(manualUpdate) {
				removeFromManager();
			} else {
				addToManager();
			}
		}
		return v;
	}

	function set_timeLimit(value:Float):Float {
		timeLimit = value > 0 ? value : 0;
		return timeLimit;
	}

	function set_manager(v:TimerManager):TimerManager {
		if(_added) {
			removeFromManager();
			manager = v;
			addToManager();
		} else {
			manager = v;
		}
		return v;
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
	
	inline function addToManager() {
		if(!manualUpdate && manager != null) {
			manager.add(this);
			_added = true;
		}
	}

	inline function removeFromManager() {
		if(!manualUpdate && manager != null) {
			manager.remove(this);
			_added = false;
		}
	}

}

class TimerManager {

	public var timescale(default, set):Float;
	var _timers:Array<Timer>;

	@:noCompletion public function new() {
		timescale = 1;
		_timers = [];
	}

	public function reset() {
		for (t in _timers) {
			t.stop();
		}
	}
	
	public function schedule(timelimit:Float = 1, onCompletefunc:()->Void = null):Timer {
		var t:Timer = new Timer();
		t.start(timelimit, onCompletefunc);

		return t;
	}

	public function scheduleFrom(currentTime:Float = 0, timelimit:Float = 1, onCompletefunc:()->Void = null):Timer {
		var t:Timer = new Timer();
		t.startFrom(currentTime, timelimit, onCompletefunc);

		return t;
	}

	@:noCompletion public function destroy(){
		reset();
	}
	
	@:noCompletion public function update(elapsed:Float) {
		for (t in _timers) {
			t.update(elapsed);
		}
	}

	@:allow(clay.utils.Timer) 
	inline function add(timer:Timer) {
		_timers.push(timer);
	}

	@:allow(clay.utils.Timer) 
	inline function remove(timer:Timer) {
		_timers.remove(timer);
	}

	inline function toString() {
		return 'timers: ${_timers.length}';
	}

	function set_timescale(v:Float):Float {
		return timescale = v < 0 ? 0 : timescale;
	}

}
