package clay.system.debug;



import clay.utils.Log.*;
import clay.system.Debug;


class DebugView {


    public var active (get, set):Bool;
    public var debug_name:String;
    public var index:Int;
    var debug:Debug;
    var _active:Bool;


	public function new(debug:Debug) {

		debug_name = '';
		this.debug = debug;
		_active = false;

	}

	function set_active(v:Bool):Bool {

		_active = v;

		if(_active) {
			onenabled();
		} else {
			ondisabled();
		}

		return v;
		
	}

	inline function get_active():Bool {

		return _active;
		
	}

	function onenabled() {}
	function ondisabled() {}

}
