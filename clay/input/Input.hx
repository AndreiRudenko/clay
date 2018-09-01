package clay.input;


import clay.Engine;
import clay.utils.Log.*;


@:allow(clay.core.Inputs)
class Input {


	public var active(default, null):Bool = false;

	var engine:Engine;


	function new(_engine:Engine) {
		
		engine = _engine;

	}

	public function enable() {

		_debug('enable');
		active = true;

	}

	public function disable() {

		_debug('disable');
		active = false;

	}


}
