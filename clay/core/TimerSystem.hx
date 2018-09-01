package clay.core;


import clay.Timer;

class TimerSystem {


	static var timers_tb:Array<Timer> = []; // time based timers
	static var timers_fb:Array<Timer> = []; // frame based timers
	static var _time:Float = 0;

	@:noCompletion public function new() {}


	@:allow(clay.Timer) 
	static inline function add(_timer:Timer):Timer { // add timer to the end

		if(_timer.frame_based) {
			timers_fb.push(_timer);
		} else {
			timers_tb.push(_timer);
		}

		return _timer;

	}

	@:allow(clay.Timer) 
	static inline function remove(_timer:Timer) {
		
		if(_timer.frame_based) {
			timers_fb.remove(_timer);
		} else {
			timers_tb.remove(_timer);
		}

	}

	public function reset() {

		for (t in timers_fb) {
			t.stop();
		}

		for (t in timers_tb) {
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
	
		/** Cycles through timers_tb and calls update() on each one. */
	@:noCompletion public function process(time:Float) {

		for (t in timers_tb) {
			if (t.active && !t.finished && t.time_limit >= 0){
				t.update(time);
			}
		}

	}

	@:noCompletion public function update(dt:Float) {

		_time += dt;

		for (t in timers_fb) {
			if (t.active && !t.finished && t.time_limit >= 0){
				t.update(_time);
			}
		}

	}

	inline function toString() {

		return 'timers: [${timers_tb.length + timers_fb.length}]';

	}


}





