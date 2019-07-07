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


	var items_list:Text;

	var font_size:Int = 15;
	var font_height:Float = 0;
	var tab_width:Float = 0;
	var bars_y:Float = 0;
	var hide_ents:Bool = true;
	var hide_comps:Bool = true;
	var audio_stats:AudioStats;
	var bars:Array<ProgressBar>;
	var bars_pool:Pool<ProgressBar>;
	var _obj_index:Int = 0;


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Audio';

		bars = [];
		bars_pool = new Pool<ProgressBar>(16, 0, 
			function() {
				return new ProgressBar('', 0, 0, 1, 64, 10, 15);
			}
		);

		var rect = debug.inspector.viewrect;

		items_list = new Text({
			// name: 'debug.audio.stats',
			// font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			text: '',
			size: font_size
		});

		items_list.visible = false;
		items_list.wrap = true;
		items_list.color = new Color().from_int(0xffa563);
		items_list.transform.pos.set(rect.x, rect.y);
		items_list.width = rect.w;
		items_list.height = 0;
		items_list.layer = debug.layer;
		items_list.clip_rect = rect;
		items_list.depth = 999.3;

		var kravur = items_list.font.font._get(font_size);
		font_height = kravur.getHeight();
		tab_width = kravur.stringWidth('    ');
		bars_y = rect.y + font_height * 3 - 10;

		audio_stats = new AudioStats();

		Clay.on(AppEvent.UPDATE, update);
		Clay.on(KeyEvent.KEY_DOWN, onkeydown);
		Clay.on(MouseEvent.MOUSE_WHEEL, onmousewheel);

	}

	// override function onremoved() {

	// 	items_list.destroy();
	// 	items_list = null;

	// }

	override function onenabled() {

		items_list.visible = true;
		refresh();

	}

	override function ondisabled() {

		items_list.visible = false;
		clear_bars();

	}

	function onkeydown(e:KeyEvent) {

		if(e.key == Key.three) {
			hide_ents = !hide_ents;
			refresh();
		}

		if(e.key == Key.four) {
			hide_comps = !hide_comps;
			refresh();
		}

	}

	function onmousewheel(e:MouseEvent) {

		var h = items_list.text_height;
		var vh = debug.inspector.size.y - debug.margin;
		var diff = h - vh;

		var new_y = items_list.transform.pos.y;
		var max_y = debug.padding.y +(debug.margin*1.5);
		var min_y = max_y;

		if(diff > 0) {
			min_y = (max_y - (diff+(debug.margin*2)));
		}

		new_y -= (debug.margin/2) * e.wheel;
		new_y = Mathf.clamp(new_y, min_y, max_y);

		items_list.transform.pos.y = new_y;

	}

	function update(dt:Float) {

		if(active) {
			refresh();
		}

	}

	function clear_bars() {
		
		if(bars.length > 0) {
			for (b in bars) {
				if(bars_pool.size < bars_pool.size_limit) {
					bars_pool.put(b);
					b.visible = false;
				} else {
					b.destroy();
				}
			}
			ArrayTools.clear(bars);	
		}

	}

	inline function get_list() : String {

		clear_bars();

		audio_stats.reset();
		audio_stats.get(Clay.audio);

		_obj_index = 0;
		var _result = '';
			_result += 'Output ( ${audio_stats.groups} / ${audio_stats.sounds} / ${audio_stats.effects} ) Volume: ${Mathf.fixed(Clay.audio.gain, 4)}\n\n';

			audio_stats.reset();
			audio_stats.get(Clay.audio, false);
			_result += 'Master ( ${audio_stats.groups} / ${audio_stats.sounds} / ${audio_stats.effects} )\n';

			_result = list_effects(_result, Clay.audio);
			for (c in Clay.audio.channels) {
				_result = list_channel(_result, c);
			}
			for (c in Clay.audio.channels) {
				_result = list_group(_result, c);
			}

		return _result;

	}

	inline function list_group(_list:String, c:AudioChannel, _depth:Int = 1) : String {

		if(Std.is(c, AudioGroup)) {
			var g:AudioGroup = cast c;
			_obj_index++;
			audio_stats.reset();
			audio_stats.get(g, false);

			_list += tabs(_depth) + 'Group ( ${audio_stats.groups-1} / ${audio_stats.sounds} / ${audio_stats.effects} )\n';
			_list = list_effects(_list, c, _depth+1);
			for (child in g.childs) {
				_list = list_channel(_list, child, _depth+1);
			} 			
			for (child in g.childs) {
				_list = list_group(_list, child, _depth+1);
			} 
		}

		return _list;

	}


	inline function list_channel(_list:String, c:AudioChannel, _depth:Int = 1) : String {


		if(Std.is(c, Sound)) {
			var s:Sound = cast c;
			_obj_index++;
			var lp = s.loop ? '* loop' : '';

			var bar = bars_pool.get();
			bar.visible = true;
			bar.text = '${s.resource.id} ${Mathf.fixed(s.time, 2)} / ${Mathf.fixed(s.duration, 2)} ${lp}';
			bar.max = s.duration;
			bar.value = s.time;
			bar.pos.set(_depth * tab_width + debug.inspector.viewrect.x, _obj_index * font_height + bars_y);

			bars.push(bar);

			// _list += tabs(_depth) + '> ${s.resource.id} ${Mathf.fixed(s.time, 2)} / ${Mathf.fixed(s.duration, 2)} ${lp}\n';
			_list += '\n';
			_list = list_effects(_list, c, _depth+1);
		}

		return _list;

	}


	inline function list_effects(_list:String, c:AudioChannel, _depth:Int = 1) : String {

		for (e in c.effects) {
			_obj_index++;
			_list += tabs(_depth) + 'fx: ${Type.getClassName(Type.getClass(e))}\n';
			
		}

		return _list;

	}


	function refresh() {

		items_list.text = get_list();

	}

	function tabs(_d:Int) {

		var res = '';
		for(i in 0 ... _d) res += '    ';
		return res;

	}


}

private class ProgressBar {


	public var bar_geometry:Quad;
	public var bg_geometry:Quad;

	public var text_item:Text;
	public var name:String;

	public var visible (default, set):Bool;
	public var height:Float;
	public var width:Float;
	public var max:Float;

	public var pos   (default, null):VectorCallback;
	public var text  (get, set):String;
	public var value (default, set):Float;


	public function new(name:String, x:Float, y:Float, max:Float = 1, width:Float = 64, height:Float = 8, font_size:Int = 8, color:Color = null) {

		this.name = name;
		this.max = max;
		this.width = width;
		this.height = height;

		text_item = new Text({
			// name: 'progressbar.text.',
			// font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			text: '',
			size: font_size,
			// align : TextAlign.right
		});

		text_item.color = new Color().from_int(0xffa563);
		text_item.layer = Clay.debug.layer;
		text_item.depth = 999.3;

		bg_geometry = new Quad(width, height);
		bg_geometry.color = new Color().from_int(0x090909);
		bg_geometry.depth = 999.3;
		bg_geometry.layer = Clay.debug.layer;

		bar_geometry = new Quad(width-2, height-2);
		bar_geometry.color = new Color().from_int(0xffa563);
		bar_geometry.depth = 999.33;
		bar_geometry.layer = Clay.debug.layer;

		pos = new VectorCallback();
		pos.listen(pos_changed);
		pos.set(x, y);

		visible = false;

	}

	public function destroy() {

		visible = false;

		bar_geometry.drop();
		bg_geometry.drop();
		text_item.drop();

		bar_geometry = null;
		bg_geometry = null;
		text_item = null;

	}

	function set_value(v:Float) {

		var p = v/max;

		p = Mathf.clamp(p, 0.005, 1);

		var nx = p*(width-2)+1;
		bar_geometry.size.set(nx, height-2);

		return value = v;

	}

	function pos_changed(v) {

		bg_geometry.transform.pos.copy_from(pos);
		bar_geometry.transform.pos.set(pos.x+1, pos.y+1);
		text_item.transform.pos.set(pos.x+width+10, pos.y - height/2);

	}

	function set_visible(v:Bool) {

		visible = v;
		bar_geometry.visible = v;
		bg_geometry.visible = v;
		text_item.visible = v;

		return v;

	}

	inline function get_text() {

		return text_item.text;

	}

	inline function set_text(_t:String) {

		return text_item.text = _t;

	}


} 


private class AudioStats {

	public var groups:Int = 0;
	public var sounds:Int = 0;
	public var effects:Int = 0;

	public function new() {}

	public function get(c:AudioChannel, cc:Bool = true) {

		for (e in c.effects) {
			effects++;
		}

		if(Std.is(c, AudioGroup)) {
			groups++;
			if(cc) {
				var g:AudioGroup = cast c;
				for (channel in g.channels) {
					get(channel);
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
