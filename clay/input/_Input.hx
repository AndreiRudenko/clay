package clay.input;

import clay.App;
import clay.utils.Log;

@:allow(clay.input.InputManager)
class Input {

	public var active(default, null):Bool = false;
	var _app:App;

	function new(app:App) {
		_app = app;
	}

	public function enable() {
		Log.debug('enable');
		active = true;
	}

	public function disable() {
		Log.debug('disable');
		active = false;
	}

}
