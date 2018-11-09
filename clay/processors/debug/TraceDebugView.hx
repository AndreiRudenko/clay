package clay.processors.debug;


import clay.objects.Text;
import clay.data.Color;
import clay.ds.Dll;
import clay.math.Vector;
import clay.core.Debug;
import clay.types.TextAlign;
import clay.utils.Log.*;


class TraceDebugView extends DebugView {


	var logged:Dll<String>;
	var lines:Text;
	var max_lines:Int = 35;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Log';

		clay.core.Debug.trace_callbacks.push(on_trace);

		logged = new Dll(max_lines);

	}

	override function onadded() {

		lines = new Text({
			name : 'debug.log.text',
			world : world,
			depth : 999.3,
			color : new Color().from_int(0x888888),
			pos: new Vector(debug.padding.x+20, debug.padding.y+40),
			width : Clay.screen.width-(debug.padding.x*2)-20,
			height : Clay.screen.height-(debug.padding.y*2)-40,
			wrap : true,
			text : '',
			align_vertical : TextAlign.bottom,
			size : 14,
			layer : debug.layer,
			visible : false
		});

	}

	override function onremoved() {

		lines.destroy();
		lines = null;

	}

	override function onenabled() {

		lines.visible = true;
		refresh_lines();

	}

	override function ondisabled() {

		lines.visible = false;

	}

	public function add_line(_t:String) {

		if(logged.length >= max_lines) {
			logged.rem_first();
		}

		logged.add_last(_t);

		if(!active) {
			return;
		}

		refresh_lines();

	}

	function on_trace( v : Dynamic, ?inf : haxe.PosInfos ) {

		add_line( inf.fileName + ':' + inf.lineNumber + ' ' + v );

	}

	function refresh_lines() {

		var _final = '';

		for (l in logged) {
			_final += l + '\n';
		}

		lines.text = _final;

	}


}
