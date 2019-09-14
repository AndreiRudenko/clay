package clay.system;


import clay.utils.Timer;


class TimerManager {


	var timers:Array<Timer>;


	@:noCompletion public function new() {

		timers = [];

	}


	@:allow(clay.utils.Timer) 
	inline function add(_timer:Timer) {

		if(!_timer.manualUpdate) {
			timers.push(_timer);
			_timer._added = true;
		}

	}

	@:allow(clay.utils.Timer) 
	inline function remove(_timer:Timer) {
		
		if(!_timer.manualUpdate) {
			timers.remove(_timer);
			_timer._added = false;
		}

	}

	public function reset() {

		for (t in timers) {
			t.stop();
		}

	}
	
	public function schedule(_timelimit:Float = 1, _onCompletefunc:()->Void = null):Timer {

		var t:Timer = new Timer();
		t.start(_timelimit, _onCompletefunc);

		return t;

	}

	public function scheduleFrom(_currentTime:Float = 0, _timelimit:Float = 1, _onCompletefunc:()->Void = null):Timer {

		var t:Timer = new Timer();
		t.startFrom(_currentTime, _timelimit, _onCompletefunc);

		return t;

	}

	@:noCompletion public function destroy(){

		reset();

	}
	
	@:noCompletion public function update(dt:Float) {

		for (t in timers) {
			t.update(dt);
		}

	}

	inline function toString() {

		return 'timers: ${timers.length}';

	}


}





