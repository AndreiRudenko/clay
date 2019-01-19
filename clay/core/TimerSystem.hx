package clay.core;


import clay.Timer;

class TimerSystem {


	static var timers:Array<Timer> = [];

	@:noCompletion public function new() {}


	@:allow(clay.Timer) 
	static inline function add(_timer:Timer) { // add timer to the end

		if(!_timer.manual_update) {
			timers.push(_timer);
			_timer._added = true;
		}

	}

	@:allow(clay.Timer) 
	static inline function remove(_timer:Timer) {
		
		if(!_timer.manual_update) {
			timers.remove(_timer);
			_timer._added = false;
		}

	}

	public function reset() {

		for (t in timers) {
			t.stop();
		}

	}
	
	public function schedule(_timelimit:Float = 1, _oncompletefunc:Void->Void = null):Timer {

		var t:Timer = new Timer();
		t.start(_timelimit, _oncompletefunc);

		return t;

	}

	public function schedule_from(_current_time:Float = 0, _timelimit:Float = 1, _oncompletefunc:Void->Void = null):Timer {

		var t:Timer = new Timer();
		t.start_from(_current_time, _timelimit, _oncompletefunc);

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





