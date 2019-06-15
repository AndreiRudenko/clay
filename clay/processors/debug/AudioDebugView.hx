package clay.processors.debug;


import clay.objects.Text;
import clay.data.Color;
import clay.ds.Dll;
import clay.math.Vector;
import clay.math.VectorCallback;
import clay.math.Mathf;
import clay.core.Debug;
import clay.types.TextAlign;
import clay.objects.Sprite;
import clay.objects.Text;
import clay.input.Keyboard;
import clay.input.Key;
import clay.input.Mouse;
import clay.utils.Log.*;
import clay.utils.ArrayTools;
import clay.audio.AudioChannel;
import clay.audio.AudioGroup;
import clay.Sound;
import clay.ds.Pool;
import clay.events.*;


@:access(
	clay.Family, 
	clay.core.ecs.Families, 
	clay.core.ecs.Entities, 
	clay.core.ecs.Components, 
	clay.FamilyData
)
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

	}

	override function onadded() {

		var rect = debug.inspector.viewrect;

		items_list = new Text({
			name : 'debug.entities.list',
			world : world,
			depth : 999.3,
			color : new Color().from_int(0xffa563),
			pos: new Vector(rect.x, rect.y),
			width : rect.w,
			height : 0,
			clip_rect : rect,
			wrap : true,
			text : '',
			size : font_size,
			layer : debug.layer,
			visible : false
		});

		var kravur = items_list.font.font._get(font_size);
		font_height = kravur.getHeight();
		tab_width = kravur.stringWidth('    ');
		bars_y = rect.y + font_height * 3 - 10;

		audio_stats = new AudioStats();

	}

	override function onremoved() {

		items_list.destroy();
		items_list = null;

	}

	override function onenabled() {

		items_list.visible = true;
		refresh();

	}

	override function ondisabled() {

		items_list.visible = false;
		clear_bars();

	}

	override function onkeydown(e:KeyEvent) {

		if(e.key == Key.three) {
			hide_ents = !hide_ents;
			refresh();
		}

		if(e.key == Key.four) {
			hide_comps = !hide_comps;
			refresh();
		}

	}

	override function onmousewheel(e:MouseEvent) {

		var h = items_list.text_height;
		var vh = debug.inspector.size.y - debug.margin;
		var diff = h - vh;

		var new_y = items_list.pos.y;
		var max_y = debug.padding.y +(debug.margin*1.5);
		var min_y = max_y;

		if(diff > 0) {
			min_y = (max_y - (diff+(debug.margin*2)));
		}

		new_y -= (debug.margin/2) * e.wheel;
		new_y = Mathf.clamp(new_y, min_y, max_y);

		items_list.pos.y = new_y;

	}

	override function update(dt:Float) {

		refresh();

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
			_result += 'Output ( ${audio_stats.groups} / ${audio_stats.sounds} / ${audio_stats.effects} ) Volume: ${clay.math.Mathf.fixed(Clay.audio.gain, 4)}\n\n';

			audio_stats.reset();
			audio_stats.get(Clay.audio, false);
			_result += 'Master ( ${audio_stats.groups} / ${audio_stats.sounds} / ${audio_stats.effects} )\n';

			_result = list_effects(_result, Clay.audio);
			for (c in Clay.audio.childs) {
				_result = list_channel(_result, c);
			}
			for (c in Clay.audio.childs) {
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
			bar.text = '${s.resource.id} ${clay.math.Mathf.fixed(s.time, 2)} / ${clay.math.Mathf.fixed(s.duration, 2)} ${lp}';
			bar.max = s.duration;
			bar.value = s.time;
			bar.pos.set(_depth * tab_width + debug.inspector.viewrect.x, _obj_index * font_height + bars_y);

			bars.push(bar);

			// _list += tabs(_depth) + '> ${s.resource.id} ${clay.math.Mathf.fixed(s.time, 2)} / ${clay.math.Mathf.fixed(s.duration, 2)} ${lp}\n';
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


	public var bar_geometry:Sprite;
	public var bg_geometry:Sprite;

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
			name : 'progressbar.text.' + name,
			world : Clay.debug.world,
			pos : new Vector(),
			color : new Color().from_int(0xffa563),
			size : font_size,
			depth : 999.3,
			text : '',
			layer : Clay.debug.layer
		});

		bg_geometry = new Sprite({
			color : new Color().from_int(0x090909),
			world: Clay.debug.world,
			depth : 999.3,
			layer: Clay.debug.layer,
			size: new Vector(width, height),
			pos: new Vector()
		});

		bar_geometry = new Sprite({
			color : new Color().from_int(0xffa563),
			// color : color,
			world: Clay.debug.world,
			depth : 999.33,
			layer: Clay.debug.layer,
			size: new Vector(width-2, height-2),
			pos: new Vector()
		});

		pos = new VectorCallback();
		pos.listen(pos_changed);
		pos.set(x, y);

		visible = false;

	}

	public function destroy() {

		visible = false;

		bar_geometry.destroy();
		bg_geometry.destroy();
		text_item.destroy();

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
		text_item.pos.set(pos.x+width+10, pos.y - height/2);

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
				for (child in g.childs) {
					get(child);
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
