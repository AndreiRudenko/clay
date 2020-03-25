package clay.system.debug;

import clay.graphics.Text;
import clay.utils.Color;
import clay.math.Vector;
import clay.system.Debug;
import clay.utils.Align;
import clay.render.Layers;

class TraceDebugView extends DebugView {

	var logged:Array<String>;
	var lines:Text;
	var maxLines:Int = 35;

	public function new(_debug:Debug) {
		super(_debug);

		debugName = "Log";

		clay.system.Debug.traceCallbacks.push(onTrace);

		logged = [];

		lines = new Text(Clay.renderer.font);
		lines.fontSize = 14;
		lines.align = Align.LEFT;
		lines.alignVertical = Align.BOTTOM;
		lines.visible = false;
		lines.color = new Color().fromInt(0x888888);
		lines.transform.pos.set(debug.padding.x+20, debug.padding.y+40);
		lines.width = Clay.screen.width-(debug.padding.x*2)-20;
		lines.height = Clay.screen.height-(debug.padding.y*2)-40;
		lines.depth = 999.3;
		Clay.layers.add(lines, Layers.DEBUG_UI);
	}

	// override function onRemoved() {

	// 	lines.destroy();
	// 	lines = null;

	// }

	override function onEnabled() {
		lines.visible = true;
		refreshLines();
	}

	override function onDisabled() {
		lines.visible = false;
	}

	public function addLine(_t:String) {
		if(logged.length >= maxLines) {
			logged.shift();
		}

		logged.push(_t);

		if(!active) {
			return;
		}

		refreshLines();
	}

	function onTrace( v : Dynamic, ?inf : haxe.PosInfos ) {
		addLine( inf.fileName + ":" + inf.lineNumber + " " + v );
	}

	function refreshLines() {
		var _final = new StringBuf();

		for (l in logged) {
			_final.add(l + " \n");
		}

		lines.text = _final.toString();
	}

}
