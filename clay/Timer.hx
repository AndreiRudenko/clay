package clay;


import clay.utils.Log._debug;
import clay.core.TimerSystem;

class Timer {
	

		/** How much time the timer was set for. */
	public var time_limit:Float = 0;
		/** How many loops the timer was set for. 0 means "looping forever". */
	public var loops:Int = 0;
		/** Pauses or checks the pause state of the timer. */
	public var active(default, set):Bool = false;
		/** Time based or frame based timer. */
	public var time_based(default, null):Bool = true;
		/** Check to see if the timer is finished. */
	public var finished:Bool = false;
		/** time offset, reset on every repeat */
	public var time_offset:Float = 0;

		/** Read-only: The amount of milliseconds that have elapsed since the timer was started */
	public var elapsed_time(get, never):Float;
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

	var _paused_elapsed_time:Float = 0;
	var _start_time:Float = 0;
	var _loops_counter:Int = 0;
	var _inarray:Bool = false;


	@:noCompletion public function new() {}

	public function destroy() {

		TimerSystem.remove(this);
		active = false;
		finished = true;
		_inarray = false;
		_oncomplete = null;
		_onrepeat = null;
		_onupdate = null;

	}

	public function start(_timelimit:Float = 1, _oncompletefunc:Void->Void = null, _time_based:Bool = true):Timer {

		stop(false); // here we remove from timers array

		time_based = _time_based;
		TimerSystem.add(this);
		_inarray = true;
		
		active = true;
		finished = false;

		if(_oncompletefunc != null){
			_oncomplete = _oncompletefunc;
		}

		time_offset = 0;

		_start_time = Clay.time;

		time_limit = Math.abs(_timelimit);
		
		loops = 1;
		_loops_counter = 0;

		return this;

	}

	public function start_from(_current_time:Float = 0, _timelimit:Float = 1, _oncompletefunc:Void->Void = null, _time_based:Bool = true):Timer {

		stop(false);
		
		time_based = _time_based;
		TimerSystem.add(this);
		_inarray = true;
		
		active = true;
		finished = false;

		if(_oncompletefunc != null){
			_oncomplete = _oncompletefunc;
		}

		time_offset = _current_time;

		_start_time = Clay.time;

		time_limit = Math.abs(_timelimit);
		
		loops = 1;
		_loops_counter = 0;

		return this;

	}

	public function reset(_newtime:Float = -1):Timer {

		if (_newtime >= 0) {
			time_limit = _newtime;
		}

		// if not active
		_paused_elapsed_time = 0;

		finished = false;
		time_offset = 0;
		_start_time = Clay.time;
		
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
			
			if (_inarray){
				TimerSystem.remove(this);
				_inarray = false;
			}
			
			if (_finish && _oncomplete != null) {
				_oncomplete();
			}

		}

	}

	inline public function elapsed(_t:Float):Bool {

		return _start_time + _t < Clay.time;

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
	
	@:allow(clay.core.TimerSystem) 
	inline function update(time:Float):Void {

		if(active) {
			
			if (_onupdate != null) {
				_onupdate();
			}
			
			while (!finished && ( _start_time + time_limit < time + time_offset ) ) {
				_loops_counter++;
				
				if (loops > 0 && (_loops_counter >= loops)) {
					stop();
					break;
				}

				time_offset = 0;

				_start_time += time_limit;

				if (_onrepeat != null) {
					_onrepeat();
				}
				
			}

		}

	}

	inline function set_active(value:Bool):Bool {

		active = value;

		if(active) {
			if(_paused_elapsed_time != 0) {
				_start_time = Clay.time - _paused_elapsed_time;
				_paused_elapsed_time = 0;
			} else {
				_start_time = Clay.time;
			}
		} else {
			_paused_elapsed_time = elapsed_time;
		}

		return active;

	}

	inline function get_time_left():Float {

		return (_start_time + time_limit) - (Clay.time + time_offset);

	}
	
	inline function get_loops_left():Int {

		return loops - _loops_counter;

	}
	
	inline function get_elapsed_loops():Int {

		return _loops_counter;

	}
	
	inline function get_progress():Float {

		return (time_limit > 0) ? ((elapsed_time + time_offset) / time_limit) : 0;

	}

	inline function get_elapsed_time():Float {

		return Clay.time - _start_time;

	}
	
}

