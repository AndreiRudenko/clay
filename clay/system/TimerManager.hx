package clay.system;


import clay.utils.Timer;


class TimerManager {


	var _timers:Array<Timer>;


	@:noCompletion public function new() {

		_timers = [];

	}


	@:allow(clay.utils.Timer) 
	inline function add(timer:Timer) {

		if(!timer.manualUpdate) {
			_timers.push(timer);
			timer._added = true;
		}

	}

	@:allow(clay.utils.Timer) 
	inline function remove(timer:Timer) {
		
		if(!timer.manualUpdate) {
			_timers.remove(timer);
			timer._added = false;
		}

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
	
	@:noCompletion public function update(dt:Float) {

		for (t in _timers) {
			t.update(dt);
		}

	}

	inline function toString() {

		return 'timers: ${_timers.length}';

	}


}





