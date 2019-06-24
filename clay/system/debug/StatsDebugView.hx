package clay.system.debug;


import clay.Clay;
import clay.render.Camera;
import clay.graphics.Text;
import clay.render.Color;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.system.Debug;
// import clay.input.Keyboard;
import clay.input.Key;
// import clay.input.Mouse;
import clay.render.Layer;
import clay.system.ResourceManager;
import clay.resources.Resource;
import clay.resources.AudioResource;
import clay.resources.BytesResource;
import clay.resources.FontResource;
import clay.resources.JsonResource;
import clay.resources.TextResource;
import clay.resources.Texture;
import clay.resources.VideoResource;
// import clay.utils.Log.*;
import clay.events.RenderEvent;
import clay.events.TouchEvent;
import clay.events.MouseEvent;
import clay.events.KeyEvent;


@:access(
	clay.render.Renderer, 
	clay.render.RenderPath, 
	clay.render.Camera
)
class StatsDebugView extends DebugView {


	var render_stats_text:Text;
	var resource_list_text:Text;

	var font_size:Int = 15;
	var hide_layers:Bool = true;
	var camera_stats:String = '';
	var _byte_levels : Array<String> = ['bytes', 'Kb', 'MB', 'GB', 'TB'];


	public function new(_debug:Debug) {

		super(_debug);

		debug_name = 'Statistics';
		
		var rect = debug.inspector.viewrect;

		render_stats_text = new Text({
			// name: 'debug.render.stats',
			// font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			text: '',
			size: font_size
		});

		render_stats_text.visible = false;
		render_stats_text.wrap = true;
		render_stats_text.color = new Color().from_int(0xffa563);
		render_stats_text.transform.pos.set(rect.x, rect.y);
		render_stats_text.width = rect.w;
		render_stats_text.height = 0;
		render_stats_text.layer = debug.layer;
		render_stats_text.clip_rect = rect;
		render_stats_text.depth = 999.3;

		resource_list_text = new Text({
			// name: 'debug.resource.stats',
			// font: Clay.resources.font('assets/Montserrat-Bold.ttf'),
			text: '',
			size: font_size,
			align : TextAlign.right
		});

		resource_list_text.visible = false;
		resource_list_text.wrap = true;
		resource_list_text.color = new Color().from_int(0xffa563);
		resource_list_text.transform.pos.set(rect.x, rect.y);
		resource_list_text.width = rect.w;
		resource_list_text.height = 0;
		resource_list_text.layer = debug.layer;
		resource_list_text.clip_rect = rect;
		resource_list_text.depth = 999.3;

		Clay.renderer.cameras.oncameracreate.add(camera_added);
		Clay.renderer.cameras.oncameradestroy.add(camera_removed);

		for (c in Clay.renderer.cameras) {
			camera_added(c);
		}

		Clay.on(RenderEvent.RENDER, onrender);
		Clay.on(KeyEvent.KEY_DOWN, onkeydown);
		Clay.on(MouseEvent.MOUSE_WHEEL, onmousewheel);
		// Clay.on(TouchEvent.TOUCH_DOWN, ontouchdown);

	}

	// override function onremoved() {

	// 	render_stats_text.destroy();
	// 	render_stats_text = null;

	// 	resource_list_text.destroy();
	// 	resource_list_text = null;

	// 	Clay.renderer.cameras.oncameracreate.remove(camera_added);
	// 	Clay.renderer.cameras.oncameradestroy.remove(camera_removed);

	// }

	override function onenabled() {

		render_stats_text.visible = true;
		resource_list_text.visible = true;
		refresh();

	}

	override function ondisabled() {

		render_stats_text.visible = false;
		resource_list_text.visible = false;

	}

	function onkeydown(e:KeyEvent) {

		if(e.key == Key.three) {
			hide_layers = !hide_layers;
			refresh();
		}

	}

	function onmousewheel(e:MouseEvent) {

		var px = e.x/Clay.screen.width;

		if(px > 0.5) {
			
			var h = resource_list_text.text_height;
			var vh = debug.inspector.size.y - debug.margin;
			var diff = h - vh;

			var new_y = resource_list_text.transform.pos.y;
			var max_y = debug.padding.y +(debug.margin*1.5);
			var min_y = max_y;

			if(diff > 0) {
				min_y = (max_y - (diff+(debug.margin*2)));
			}

			new_y -= (debug.margin/2) * e.wheel;
			new_y = Mathf.clamp(new_y, min_y, max_y);

			resource_list_text.transform.pos.y = new_y;

		} else {

			var h = render_stats_text.text_height;
			var vh = debug.inspector.size.y - debug.margin;
			var diff = h - vh;

			var new_y = render_stats_text.transform.pos.y;
			var max_y = debug.padding.y +(debug.margin*1.5);
			var min_y = max_y;

			if(diff > 0) {
				min_y = (max_y - (diff+(debug.margin*2)));
			}

			new_y -= (debug.margin/2) * e.wheel;
			new_y = Mathf.clamp(new_y, min_y, max_y);

			render_stats_text.transform.pos.y = new_y;

		}

	}

	function onrender(_) {

		if(active) {
			refresh();
		}

	}

	function camera_added(c:Camera) {
		
		c.onpostrender.add(add_camera_stats);

	}

	function camera_removed(c:Camera) {

		c.onpostrender.remove(add_camera_stats);
		
	}

	function add_camera_stats(c:Camera) {

		if(active) {
			camera_stats += get_camera_info(c);
		}
		
	}

	function bytes_to_string( bytes:Int, ?precision:Int=3 ) : String {

		var index = bytes == 0 ? 0 : Math.floor(Math.log(bytes) / Math.log(1024));
		var _byte_value = bytes / Math.pow(1024, index);
			_byte_value = clay.utils.Mathf.fixed(_byte_value, precision);

		return _byte_value + ' ' + _byte_levels[index];

	}

	@:access(kha.Kravur)
	function get_recource_stats():String {


		var bytes_lists = '';
		var text_lists = '';
		var json_lists = '';
		var texture_lists = '';
		var font_lists = '';
		var rtt_lists = '';
		// var shader_lists = '';
		var audio_lists = '';
		var video_lists = '';

		var _total_txt = 0;
		var _total_bts = 0;
		var _total_tex = 0;
		var _total_rtt = 0;
		var _total_snd = 0;
		var _total_vid = 0;
		var _total_fnt = 0;
		var _total_all = 0;

		inline function _res(res:Resource) return '${res.id} • ${res.ref}\t\n';

		
		inline function _fnt(res:FontResource) {
			_total_fnt += res.memory_use();
			return '(~${bytes_to_string(res.memory_use())}) ${res.id} • ${Lambda.count(res.font.images)}\t\n';
		}

		inline function _txt(res:TextResource) {
			var _l = if(res.text != null) res.text.length else 0;
			_total_txt += _l;
			return '(~${bytes_to_string(_l)}) ${res.id} • ${res.ref}\t\n';
		}

		inline function _bts(res:BytesResource) {
			var _l = res.blob != null ? res.memory_use() : 0;
			_total_bts += _l;
			return '(~${bytes_to_string(_l)}) ${res.id} • ${res.ref}\t\n';
		}

		inline function _tex(res:Texture) {
			if(res.resource_type == ResourceType.render_texture) {
				_total_rtt += res.memory_use();
			} else {
				_total_tex += res.memory_use();
			}
			return '(${res.width_actual}x${res.height_actual} ~${bytes_to_string(res.memory_use())})    ${res.id} • ${res.ref}\t\n';
		}

		inline function _snd(res:AudioResource) return {
			_total_snd += res.memory_use();
			return '(${clay.utils.Mathf.fixed(res.duration, 2)}s ${res.channels}ch ~${bytes_to_string(res.memory_use())})    ${res.id} • ${res.ref}\t\n';
		}

		inline function _vid(res:VideoResource) {
			_total_vid += res.memory_use();
			return '(${res.video.width}x${res.video.height} ~${bytes_to_string(res.memory_use())})    ${res.id} • ${res.ref}\t\n';
		}

		for(res in Clay.resources.cache) {
			switch(res.resource_type) {
				case ResourceType.bytes:            bytes_lists += _bts(cast res);
				case ResourceType.text:             text_lists += _txt(cast res);
				case ResourceType.json:             json_lists += _res(res);
				case ResourceType.texture:          texture_lists += _tex(cast res);
				case ResourceType.render_texture:   rtt_lists += _tex(cast res);
				case ResourceType.font:             font_lists += _fnt(cast res);
				// case ResourceType.shader:           shader_lists += _shd(cast res);
				case ResourceType.audio:            audio_lists += _snd(cast res);
				case ResourceType.video:            video_lists += _vid(cast res);
				default:
			}
		}

		inline function orblank(v:String) return (v == '') ? '-\t\n' : v;

		_total_all += _total_bts;
		_total_all += _total_txt;
		_total_all += _total_tex;
		_total_all += _total_rtt;
		_total_all += _total_snd;
		_total_all += _total_fnt;
		_total_all += _total_vid;

		var lists = 'Resource list (${Clay.resources.stats.total} • ~${bytes_to_string(_total_all)})\n\n';

			lists += 'Bytes (${Clay.resources.stats.bytes} • ~${bytes_to_string(_total_bts)}))\n';
				lists += orblank(bytes_lists);
			lists += '\nText (${Clay.resources.stats.texts} • ~${bytes_to_string(_total_txt)})\n';
				lists += orblank(text_lists);
			lists += '\nJSON (${Clay.resources.stats.jsons})\n';
				lists += orblank(json_lists);
			lists += '\nTexture (${Clay.resources.stats.textures} • ~${bytes_to_string(_total_tex)})\n';
				lists += orblank(texture_lists);
			lists += '\nRenderTexture (${Clay.resources.stats.rtt} • ~${bytes_to_string(_total_rtt)})\n';
				lists += orblank(rtt_lists);
			lists += '\nFont (${Clay.resources.stats.fonts} • ~${bytes_to_string(_total_fnt)})\n';
				lists += orblank(font_lists);
			// lists += '\nShader (${Clay.resources.stats.shaders})\n';
				// lists += orblank(shader_lists);
			lists += '\nAudio (${Clay.resources.stats.audios} • ~${bytes_to_string(_total_snd)})\n';
				lists += orblank(audio_lists);
			lists += '\nVideo (${Clay.resources.stats.videos} • ~${bytes_to_string(_total_vid)})\n';
				lists += orblank(video_lists);


		return lists;

	}


	function get_render_stats():String {

		var _render_stats = Clay.renderer.stats;

		return
			'Renderer Statistics\n\n' +
			'total geometry : ' + _render_stats.geometry + '\n' +
			'visible geometry : ' + _render_stats.visible_geometry + '\n' +
			'static geometry : ' + _render_stats.locked + '\n' +
			'vertices : ' + _render_stats.vertices + '\n' +
			'indices : ' + _render_stats.indices + '\n' +
			'draw calls : ' + _render_stats.draw_calls + '\n' +
			'layers : ' + Clay.renderer.layers.active_count + '\n' +
			'cameras : ' + Clay.renderer.cameras.length + '\n' +
			camera_stats;

	}

	inline function get_camera_info(c:Camera) {


		var _layers = [];
		for (l in Clay.renderer.layers) {
			if(c._visible_layers_mask.get(l.id)) {
				_layers.push(l);
			}
		}

		var _active = c.active ? '' : '/ inactive';

		var _s =  '    ${c.name} ( ${_layers.length} ) ${_active}\n';

		if(!hide_layers && c.active) {
			for (l in _layers) {
				_s += get_layer_info(l);
			}
		}

		return _s;
		
	}

	inline function get_layer_info(l:Layer) {

		return
			'        ${l.name} | ${l.priority}\n' +
			'            total geometry : ' + l.stats.geometry + '\n' +
			'            visible geometry : ' + l.stats.visible_geometry + '\n' +
			'            static geometry : ' + l.stats.locked + '\n' +
			'            vertices : ' + l.stats.vertices + '\n' +
			'            indices : ' + l.stats.indices + '\n' +
			'            draw calls : ' + l.stats.draw_calls + '\n';

	}

	function refresh() {

		render_stats_text.text = get_render_stats();
		resource_list_text.text = get_recource_stats();
		camera_stats = '';

	}

	function tabs(_d:Int) {

		var res = '';
		for(i in 0 ... _d) res += '    ';
		return res;

	}


}
