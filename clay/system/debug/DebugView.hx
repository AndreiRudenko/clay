package clay.system.debug;



import clay.utils.Log.*;
import clay.system.Debug;


class DebugView {


    public var active (get, set):Bool;
    public var debugName:String;
    public var index:Int;
    var debug:Debug;
    var _active:Bool;


	public function new(debug:Debug) {

		debugName = '';
		this.debug = debug;
		_active = false;

	}

	function set_active(v:Bool):Bool {

		_active = v;

		if(_active) {
			onEnabled();
		} else {
			onDisabled();
		}

		return v;
		
	}

	inline function get_active():Bool {

		return _active;
		
	}

	function onEnabled() {}
	function onDisabled() {}

}
