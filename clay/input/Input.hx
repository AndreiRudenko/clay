package clay.input;


import clay.system.App;
import clay.utils.Log.*;


@:allow(clay.system.InputManager)
class Input {


	public var active(default, null):Bool = false;

	var _app:App;


	function new(app:App) {
		
		_app = app;

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
