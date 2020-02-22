package clay.system.debug;


import clay.graphics.Text;
import clay.graphics.shapes.Quad;
import clay.render.Color;
import clay.math.Vector;
import clay.math.VectorCallback;
import clay.utils.Mathf;
import clay.system.Debug;
import clay.input.Keyboard;
import clay.input.Key;
import clay.input.Mouse;
import clay.utils.ArrayTools;
import clay.audio.AudioChannel;
import clay.audio.AudioGroup;
import clay.audio.Sound;
import clay.ds.Pool;
import clay.events.KeyEvent;
import clay.events.AppEvent;
import clay.events.MouseEvent;


class AudioDebugView extends DebugView {


	var itemsList:Text;

	var fontSize:Int = 15;
	var fontHeight:Float = 0;
	var tabWidth:Float = 0;
	var barsY:Float = 0;
	var hideEnts:Bool = true;
	var hideComps:Bool = true;
	var audioStats:AudioStats;
	var bars:Array<ProgressBar>;
	var barsPool:Pool<ProgressBar>;
	var _objIndex:Int = 0;


	public function new(_debug:Debug) {

		super(_debug);

		debugName = "Audio";

		bars = [];
		barsPool = new Pool<ProgressBar>(16, 0, 
			function() {
				return new ProgressBar("", 0, 0, 1, 64, 10, 15);
			}
		);

		var rect = debug.inspector.viewrect;

		itemsList = new Text(Clay.renderer.font);
		itemsList.fontSize = fontSize;
		itemsList.visible = false;
		itemsList.color = new Color().fromInt(0xffa563);
		itemsList.transform.pos.set(rect.x, rect.y);
		itemsList.width = rect.w;
		itemsList.height = 0;
		itemsList.clipRect = rect;
		itemsList.depth = 999.3;
		debug.layer.add(itemsList);

		var kravur = itemsList.font.font._get(fontSize);
		fontHeight = kravur.getHeight();
		tabWidth = kravur.stringWidth("    ");
		barsY = rect.y + fontHeight * 3 - 10;

		audioStats = new AudioStats();

		Clay.on(AppEvent.UPDATE, update);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(MouseEvent.MOUSE_WHEEL, onMouseWheel);

	}

	// override function onRemoved() {

	// 	itemsList.destroy();
	// 	itemsList = null;

	// }

	override function onEnabled() {

		itemsList.visible = true;
		refresh();

	}

	override function onDisabled() {

		itemsList.visible = false;
		clearBars();

	}

	function onKeyDown(e:KeyEvent) {

		if(e.key == Key.THREE) {
			hideEnts = !hideEnts;
			refresh();
		}

		if(e.key == Key.FOUR) {
			hideComps = !hideComps;
			refresh();
		}

	}

	function onMouseWheel(e:MouseEvent) {

		var h = itemsList.textHeight;
		var vh = debug.inspector.size.y - debug.margin;
		var diff = h - vh;

		var newY = itemsList.transform.pos.y;
		var maxY = debug.padding.y +(debug.margin*1.5);
		var minY = maxY;

		if(diff > 0) {
			minY = (maxY - (diff+(debug.margin*2)));
		}

		newY -= (debug.margin/2) * e.wheel;
		newY = Mathf.clamp(newY, minY, maxY);

		itemsList.transform.pos.y = newY;

	}

	function update(dt:Float) {

		if(active) {
			refresh();
		}

	}

	function clearBars() {
		
		if(bars.length > 0) {
			for (b in bars) {
				if(barsPool.size < barsPool.sizeLimit) {
					barsPool.put(b);
					b.visible = false;
				} else {
					b.destroy();
				}
			}
			ArrayTools.clear(bars);	
		}

	}

	inline function getList() : String {

		clearBars();

		audioStats.reset();
		audioStats.get(Clay.audio);

		_objIndex = 0;
		var _result = new StringBuf();
		// var _result = "";
			_result.add("Output ( " + audioStats.groups + " / " + audioStats.sounds + " / " + audioStats.effects + " ) Volume: " + Mathf.fixed(Clay.audio.gain, 4) + " \n \n ");

			audioStats.reset();
			audioStats.get(Clay.audio, false);
			_result.add("Master ( " + audioStats.groups + " / " + audioStats.sounds + " / " + audioStats.effects + " ) \n ");

			listEffects(_result, Clay.audio);

			var channels = Clay.audio.channels;
			var channelsCount = Clay.audio.channelsCount;

			for (i in 0...channelsCount) {
				listChannel(_result, channels[i]);
			}
			for (i in 0...channelsCount) {
				listGroup(_result, channels[i]);
			}

		return _result.toString();

	}

	inline function listGroup(_list:StringBuf, c:AudioChannel, _depth:Int = 1) {

		if(Std.is(c, AudioGroup)) {
			var g:AudioGroup = cast c;
			var channels = g.channels;
			_objIndex++;
			audioStats.reset();
			audioStats.get(g, false);

			_list.add(tabs(_depth) + "Group ( " + (audioStats.groups-1) + " / " + audioStats.sounds + " / " + audioStats.effects + " ) \n ");
			listEffects(_list, c, _depth+1);
			for (i in 0...g.channelsCount) {
				listChannel(_list, channels[i], _depth+1);
			} 			
			for (i in 0...g.channelsCount) {
				listGroup(_list, channels[i], _depth+1);
			} 
		}

	}

	inline function listChannel(_list:StringBuf, c:AudioChannel, _depth:Int = 1) {

		if(Std.is(c, Sound)) {
			var s:Sound = cast c;
			_objIndex++;
			var lp = s.loop ? "* loop" : "";

			var bar = barsPool.get();
			bar.visible = true;
			bar.text = s.resource.id + " " + Mathf.fixed(s.time, 2) + " / " + Mathf.fixed(s.duration, 2) + " " + lp;
			bar.max = s.duration;
			bar.value = s.time;
			bar.pos.set(_depth * tabWidth + debug.inspector.viewrect.x, _objIndex * fontHeight + barsY);

			bars.push(bar);

			// _list += tabs(_depth) + '> " + s.resource.id} " + Mathf.fixed(s.time, 2)} / " + Mathf.fixed(s.duration, 2)} " + lp}\n';
			_list.add(" \n ");
			listEffects(_list, c, _depth+1);
		}

	}


	inline function listEffects(_list:StringBuf, c:AudioChannel, _depth:Int = 1) {

		for (i in 0...c.effectsCount) {
			_objIndex++;
			// _list.add(tabs(_depth) + "fx: " + Type.getClassName(Type.getClass(c.effects[i])) + " \n ");
			_list.add(tabs(_depth) + "fx: " + Type.getClassName(Type.getClass(c.effects[i])) + " \n ");
		}

	}


	function refresh() {

		itemsList.text = getList();

	}

	function tabs(_d:Int) {

		var res = new StringBuf();
		for(i in 0 ... _d) res.add("    ");
		return res.toString();

	}


}

private class ProgressBar {


	public var barGeometry:Quad;
	public var bgGeometry:Quad;

	public var textItem:Text;
	public var name:String;

	public var visible (default, set):Bool;
	public var height:Float;
	public var width:Float;
	public var max:Float;

	public var pos   (default, null):VectorCallback;
	public var text  (get, set):String;
	public var value (default, set):Float;


	public function new(name:String, x:Float, y:Float, max:Float = 1, width:Float = 64, height:Float = 8, fontSize:Int = 8, color:Color = null) {

		this.name = name;
		this.max = max;
		this.width = width;
		this.height = height;

		textItem = new Text(Clay.renderer.font);
		textItem.fontSize = fontSize;
		textItem.color = new Color().fromInt(0xffa563);
		textItem.depth = 999.3;
		Clay.debug.layer.add(textItem);

		bgGeometry = new Quad(width, height);
		bgGeometry.color = new Color().fromInt(0x090909);
		bgGeometry.depth = 999.3;
		Clay.debug.layer.add(bgGeometry);

		barGeometry = new Quad(width-2, height-2);
		barGeometry.color = new Color().fromInt(0xffa563);
		barGeometry.depth = 999.33;
		Clay.debug.layer.add(barGeometry);

		pos = new VectorCallback();
		pos.listen(posChanged);
		pos.set(x, y);

		visible = false;

	}

	public function destroy() {

		visible = false;

		barGeometry.drop();
		bgGeometry.drop();
		textItem.drop();

		barGeometry = null;
		bgGeometry = null;
		textItem = null;

	}

	function posChanged(v) {

		bgGeometry.transform.pos.copyFrom(pos);
		barGeometry.transform.pos.set(pos.x+1, pos.y+1);
		textItem.transform.pos.set(pos.x+width+10, pos.y - height/2);

	}

	function set_value(v:Float) {

		var p = v/max;

		p = Mathf.clamp(p, 0.005, 1);

		var nx = p*(width-2)+1;
		barGeometry.size.set(nx, height-2);

		return value = v;

	}

	function set_visible(v:Bool) {

		visible = v;
		barGeometry.visible = v;
		bgGeometry.visible = v;
		textItem.visible = v;

		return v;

	}

	inline function get_text() {

		return textItem.text;

	}

	inline function set_text(_t:String) {

		return textItem.text = _t;

	}


} 


private class AudioStats {

	public var groups:Int = 0;
	public var sounds:Int = 0;
	public var effects:Int = 0;

	public function new() {}

	public function get(c:AudioChannel, cc:Bool = true) {

		effects += c.effectsCount;

		if(Std.is(c, AudioGroup)) {
			groups++;
			if(cc) {
				var g:AudioGroup = cast c;
				var channels = g.channels;
				for (i in 0...g.channelsCount) {
					get(channels[i]);
				}
			}
		} else {
			sounds++;
		}

	}

	public inline function reset() {

		groups = 0;
		sounds = 0;
		effects = 0;

	}

}
