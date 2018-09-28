package clay.core;


import clay.emitters.Signal;

import clay.input.Keyboard;
import clay.input.Mouse;
import clay.input.Gamepad;
import clay.input.Touch;
import clay.input.Pen;
import clay.input.Bindings;


class EngineSignals {


	public var prerender         	(default, null):Signal<Void->Void>;
	public var render            	(default, null):Signal<Void->Void>;
	public var postrender        	(default, null):Signal<Void->Void>;

	public var tickstart         	(default, null):Signal<Void->Void>;
	public var tickend           	(default, null):Signal<Void->Void>;

	public var update            	(default, null):Signal<Float->Void>;

	public var keydown         	    (default, null):Signal<KeyEvent->Void>;
	public var keyup           	    (default, null):Signal<KeyEvent->Void>;

	public var mousedown       	    (default, null):Signal<MouseEvent->Void>;
	public var mouseup         	    (default, null):Signal<MouseEvent->Void>;
	public var mousemove       	    (default, null):Signal<MouseEvent->Void>;
	public var mousewheel      	    (default, null):Signal<MouseEvent->Void>;

	public var gamepadadd      	    (default, null):Signal<GamepadEvent->Void>;
	public var gamepadremove   	    (default, null):Signal<GamepadEvent->Void>;
	public var gamepaddown     	    (default, null):Signal<GamepadEvent->Void>;
	public var gamepadup       	    (default, null):Signal<GamepadEvent->Void>;
	public var gamepadaxis     	    (default, null):Signal<GamepadEvent->Void>;

	public var touchdown       	    (default, null):Signal<TouchEvent->Void>;
	public var touchup         	    (default, null):Signal<TouchEvent->Void>;
	public var touchmove       	    (default, null):Signal<TouchEvent->Void>;

	public var pendown         	    (default, null):Signal<PenEvent->Void>;
	public var penup           	    (default, null):Signal<PenEvent->Void>;
	public var penmove         	    (default, null):Signal<PenEvent->Void>;

	public var inputdown       	    (default, null):Signal<InputEvent->Void>;
	public var inputup         	    (default, null):Signal<InputEvent->Void>;

	public var timescale         	(default, null):Signal<Float->Void>;

	// public var window         	(default, null):Signal<Void->Void>;
	// public var windowmoved    	(default, null):Signal<Void->Void>;
	// public var windowresized  	(default, null):Signal<Void->Void>;
	// public var windowsized    	(default, null):Signal<Void->Void>;
	// public var windowminimized	(default, null):Signal<Void->Void>;
	// public var windowrestored 	(default, null):Signal<Void->Void>;



	public function new() {

		prerender = new Signal();
		render = new Signal();
		postrender = new Signal();
		tickstart = new Signal();
		tickend = new Signal();
		update = new Signal();
		keydown = new Signal();
		keyup = new Signal();
		mousedown = new Signal();
		mouseup = new Signal();
		mousemove = new Signal();
		mousewheel = new Signal();
		gamepadadd = new Signal();
		gamepadremove = new Signal();
		gamepaddown = new Signal();
		gamepadup = new Signal();
		gamepadaxis = new Signal();
		touchdown = new Signal();
		touchup = new Signal();
		touchmove = new Signal();
		pendown = new Signal();
		penup = new Signal();
		penmove = new Signal();
		inputdown = new Signal();
		inputup = new Signal();
		timescale = new Signal();
		// window = new Signal();
		// windowmoved = new Signal();
		// windowresized = new Signal();
		// windowsized = new Signal();
		// windowminimized = new Signal();
		// windowrestored = new Signal();

	}

	public function destroy() {

		prerender.destroy();
		render.destroy();
		postrender.destroy();
		tickstart.destroy();
		tickend.destroy();
		update.destroy();
		keydown.destroy();
		keyup.destroy();
		mousedown.destroy();
		mouseup.destroy();
		mousemove.destroy();
		mousewheel.destroy();
		gamepadadd.destroy();
		gamepadremove.destroy();
		gamepaddown.destroy();
		gamepadup.destroy();
		gamepadaxis.destroy();
		touchdown.destroy();
		touchup.destroy();
		touchmove.destroy();
		pendown.destroy();
		penup.destroy();
		penmove.destroy();
		inputdown.destroy();
		inputup.destroy();
		timescale.destroy();
		// window.destroy();
		// windowmoved.destroy();
		// windowresized.destroy();
		// windowsized.destroy();
		// windowminimized.destroy();
		// windowrestored.destroy();

	}


}





