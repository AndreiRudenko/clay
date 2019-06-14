package clay;


import clay.utils.Log._debug;
import clay.core.Timers;

class Timer {
	

		/** How much time the timer was set for. */
	public var time_limit	(default, set):Float = 0;
		/** How many loops the timer was set for. 0 means "looping forever". */
	public var loops:Int = 0;
		/** Pauses or checks the pause state of the timer. */
	public var active  	 	(default, set):Bool = false;
		/** Read-only: check to see if the timer is finished. */
	public var finished	 	(default, null):Bool = false;
		/** Use timescale for timer. */
	public var timescaled:Bool = false;
		/** Manual update */
	public var manual_update(default, null):Bool = false;

		/** The amount of milliseconds that have elapsed since the timer was started */
	public var time(default, null):Float = 0;
		/** Read-only: how many loops that have elapsed since the timer was started. */
	public var elapsed_loops(get, never):Int;
		/** Read-only: check how much time is left on the timer. */
	public var time_left(get, never):Float;
		/** Read-only: check how many loops are left on the timer. */
	public var loops_left(get, never):Int;
		/** Read-only: how far along the timer is, on a scale of 0.0 to 1.0. */
	public var progress(get, never):Float;


	var _oncomplete:Void->Void;
	var _onrepeat:Void->Void;
	var _onupdate:Void->Void;

	var _loops_counter:Int = 0;

	@:noCompletion 
	public var _added:Bool = false;


	@:noCompletion public function new(_manual_update:Bool = false) {

		manual_update = _manual_update;

	}

	public function destroy() {

		Clay.timer.remove(this);
		active = false;
		finished = true;
		_oncomplete = null;
		_onrepeat = null;
		_onupdate = null;

	}

	public inline function start(_timelimit:Float, _oncompletefunc:Void->Void = null):Timer {

		return start_from(0, _timelimit, _oncompletefunc);

	}

	public function start_from(_current_time:Float, _timelimit:Float, _oncompletefunc:Void->Void = null):Timer {

		stop(false); // here we remove from timers array

		Clay.timer.add(this);
		
		active = true;
		finished = false;

		if(_oncompletefunc != null){
			_oncomplete = _oncompletefunc;
		}

		time = _current_time;

		time_limit = _timelimit;
		
		loops = 1;
		_loops_counter = 0;

		return this;

	}

	public function reset(_newtime:Float = -1):Timer {

		if (_newtime >= 0) {
			time_limit = _newtime;
		}

		if(!_added) {
			Clay.timer.add(this);
		}

		finished = false;
		time = 0;
		
		// loops = 1;
		_loops_counter = 0;

		return this;

	}

	public function repeat(_times:Int = 0):Timer {

		if (_times < 0) {
			_times *= -1;
		}

		loops = _times;

		return this;

	}

	public function stop(_finish:Bool = true):Void {

		if(!finished) {
			finished = true;
			active = false;
			
			if (_added){
				Clay.timer.remove(this);
			}
			
			if (_finish && _oncomplete != null) {
				_oncomplete();
			}

		}

	}

	public inline function elapsed(_t:Float):Bool {

		return _t > time;

	}


	public function oncomplete(?_oncompletefunc:Void->Void):Timer {

		_oncomplete = _oncompletefunc;

		return this;

	}

	public function onrepeat(?_onrepeatfunc:Void->Void):Timer {

		_onrepeat = _onrepeatfunc;

		return this;

	}

	public function onupdate(?_onupdatefunc:Void->Void):Timer {

		_onupdate = _onupdatefunc;

		return this;

	}
	
	public function update(dt:Float):Void {

		if(active && !finished) {

			if(timescaled) {
				dt *= Clay.timescale;
			}

			time += dt;
			
			if (_onupdate != null) {
				_onupdate();
			}
			
			while (!finished && time > time_limit) {
				_loops_counter++;
				
				if (loops > 0 && (_loops_counter >= loops)) {
					stop();
					break;
				}

				time -= time_limit;

				if (_onrepeat != null) {
					_onrepeat();
				}
				
			}

		}

	}

	function set_time_limit(value:Float):Float {

		time_limit = value > 0 ? value : 0;

		return time_limit;

	}

	inline function set_active(value:Bool):Bool {

		active = value;

		return active;

	}

	inline function get_time_left():Float {

		return time_limit - time;

	}
	
	inline function get_loops_left():Int {

		return loops - _loops_counter;

	}
	
	inline function get_elapsed_loops():Int {

		return _loops_counter;

	}
	
	inline function get_progress():Float {

		return (time_limit > 0) ? (time / time_limit) : 0;

	}

	inline function get_elapsed_time():Float {

		return time;

	}
	
}

