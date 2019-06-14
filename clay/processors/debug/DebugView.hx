package clay.processors.debug;



import clay.utils.Log.*;
import clay.core.Debug;


class DebugView extends Processor {


    public var debug_name:String;
    public var index:Int;
    var debug:Debug;


	public function new(_debug:Debug) {

		super();

		debug_name = '';
		debug = _debug;

	}


}
