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
	clay.render.Camera
)
class StatsDebugView extends DebugView {


	var renderStatsText:Text;
	var resourceListText:Text;

	var fontSize:Int = 15;
	var hideLayers:Bool = true;
	var cameraStats:StringBuf;
	var _byteLevels : Array<String> = ["bytes", "Kb", "MB", "GB", "TB"];


	public function new(_debug:Debug) {

		super(_debug);

		debugName = "Statistics";
		cameraStats = new StringBuf();
		
		var rect = debug.inspector.viewrect;

		renderStatsText = new Text(Clay.renderer.font);
		renderStatsText.size = fontSize;
		renderStatsText.visible = false;
		renderStatsText.color = new Color().fromInt(0xffa563);
		renderStatsText.transform.pos.set(rect.x, rect.y);
		renderStatsText.width = rect.w;
		renderStatsText.height = 0;
		renderStatsText.layer = debug.layer;
		renderStatsText.clipRect = rect;
		renderStatsText.depth = 999.3;

		resourceListText = new Text(Clay.renderer.font);
		resourceListText.size = fontSize;
		resourceListText.align = TextAlign.RIGHT;
		resourceListText.visible = false;
		resourceListText.color = new Color().fromInt(0xffa563);
		resourceListText.transform.pos.set(rect.x, rect.y);
		resourceListText.width = rect.w;
		resourceListText.height = 0;
		resourceListText.layer = debug.layer;
		resourceListText.clipRect = rect;
		resourceListText.depth = 999.3;

		Clay.renderer.cameras.onCameraCreate.add(cameraAdded);
		Clay.renderer.cameras.onCameraDestroy.add(cameraRemoved);

		for (c in Clay.renderer.cameras) {
			cameraAdded(c);
		}

		Clay.on(RenderEvent.RENDER, onrender);
		Clay.on(KeyEvent.KEY_DOWN, onKeyDown);
		Clay.on(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		// Clay.on(TouchEvent.TOUCH_DOWN, ontouchdown);

	}

	// override function onRemoved() {

	// 	renderStatsText.destroy();
	// 	renderStatsText = null;

	// 	resourceListText.destroy();
	// 	resourceListText = null;

	// 	Clay.renderer.cameras.onCameraCreate.remove(cameraAdded);
	// 	Clay.renderer.cameras.onCameraDestroy.remove(cameraRemoved);

	// }

	override function onEnabled() {

		renderStatsText.visible = true;
		resourceListText.visible = true;
		refresh();

	}

	override function onDisabled() {

		renderStatsText.visible = false;
		resourceListText.visible = false;

	}

	function onKeyDown(e:KeyEvent) {

		if(e.key == Key.THREE) {
			hideLayers = !hideLayers;
			refresh();
		}

	}

	function onMouseWheel(e:MouseEvent) {

		var px = e.x/Clay.screen.width;

		if(px > 0.5) {
			
			var h = resourceListText.textHeight;
			var vh = debug.inspector.size.y - debug.margin;
			var diff = h - vh;

			var newY = resourceListText.transform.pos.y;
			var maxY = debug.padding.y +(debug.margin*1.5);
			var minY = maxY;

			if(diff > 0) {
				minY = (maxY - (diff+(debug.margin*2)));
			}

			newY -= (debug.margin/2) * e.wheel;
			newY = Mathf.clamp(newY, minY, maxY);

			resourceListText.transform.pos.y = newY;

		} else {

			var h = renderStatsText.textHeight;
			var vh = debug.inspector.size.y - debug.margin;
			var diff = h - vh;

			var newY = renderStatsText.transform.pos.y;
			var maxY = debug.padding.y +(debug.margin*1.5);
			var minY = maxY;

			if(diff > 0) {
				minY = (maxY - (diff+(debug.margin*2)));
			}

			newY -= (debug.margin/2) * e.wheel;
			newY = Mathf.clamp(newY, minY, maxY);

			renderStatsText.transform.pos.y = newY;

		}

	}

	function onrender(_) {

		if(active) {
			refresh();
		}

	}

	function cameraAdded(c:Camera) {
		
		c.onpostRender.add(addCameraStats);

	}

	function cameraRemoved(c:Camera) {

		c.onpostRender.remove(addCameraStats);
		
	}

	function addCameraStats(c:Camera) {

		if(active) {
			cameraStats.add(getCameraInfo(c));
		}
		
	}

	function bytesToString( bytes:Int, ?precision:Int=3 ):String {

		var index = bytes == 0 ? 0 : Math.floor(Math.log(bytes) / Math.log(1024));
		var _byteValue = bytes / Math.pow(1024, index);
			_byteValue = clay.utils.Mathf.fixed(_byteValue, precision);

		return _byteValue + " " + _byteLevels[index];

	}

	@:access(kha.Kravur)
	function getResourceStats():String {


		var bytesLists = new StringBuf();
		var textLists = new StringBuf();
		var jsonLists = new StringBuf();
		var textureLists = new StringBuf();
		var fontLists = new StringBuf();
		var rttLists = new StringBuf();
		// var shaderLists = new StringBuf();
		var audioLists = new StringBuf();
		var videoLists = new StringBuf();

		var _totalTxt = 0;
		var _totalBts = 0;
		var _totalTex = 0;
		var _totalRtt = 0;
		var _totalSnd = 0;
		var _totalVid = 0;
		var _totalFnt = 0;
		var _totalAll = 0;

		inline function _res(res:Resource) return "" + res.id + " • " + res.ref + "    \n ";

		
		inline function _fnt(res:FontResource) {
			_totalFnt += res.memoryUse();
			return "(~" + bytesToString(res.memoryUse()) + ") " + res.id + " • " + Lambda.count(res.font.images) + "    \n ";
		}

		inline function _txt(res:TextResource) {
			var _l = if(res.text != null) res.text.length else 0;
			_totalTxt += _l;
			return "(~" + bytesToString(_l) + ") " + res.id + " • " + res.ref + "    \n ";
		}

		inline function _bts(res:BytesResource) {
			var _l = res.blob != null ? res.memoryUse() : 0;
			_totalBts += _l;
			return "(~" + bytesToString(_l) + ") " + res.id + " • " + res.ref + "    \n ";
		}

		inline function _tex(res:Texture) {
			if(res.resourceType == ResourceType.RENDERTEXTURE) {
				_totalRtt += res.memoryUse();
			} else {
				_totalTex += res.memoryUse();
			}
			return "(" + res.widthActual + "x" + res.heightActual + " ~" + bytesToString(res.memoryUse()) + ")    " + res.id + " • " + res.ref + "    \n ";
		}

		inline function _snd(res:AudioResource) return {
			_totalSnd += res.memoryUse();
			return "(" + clay.utils.Mathf.fixed(res.duration, 2) + "s " + res.channels + "ch ~" + bytesToString(res.memoryUse()) + ")    " + res.id + " • " + res.ref + "    \n ";
		}

		inline function _vid(res:VideoResource) {
			_totalVid += res.memoryUse();
			return "(" + res.video.width + "x" + res.video.height + " ~" + bytesToString(res.memoryUse()) + ")    " + res.id + " • " + res.ref + "    \n ";
		}

		for(res in Clay.resources.cache) {
			switch(res.resourceType) {
				case ResourceType.BYTES:            bytesLists.add(_bts(cast res));
				case ResourceType.TEXT:             textLists.add(_txt(cast res));
				case ResourceType.JSON:             jsonLists.add(_res(res));
				case ResourceType.TEXTURE:          textureLists.add(_tex(cast res));
				case ResourceType.RENDERTEXTURE:   rttLists.add(_tex(cast res));
				case ResourceType.FONT:             fontLists.add(_fnt(cast res));
				// case ResourceType.SHADER:           shaderLists.add(_shd(cast res));
				case ResourceType.AUDIO:            audioLists.add(_snd(cast res));
				case ResourceType.VIDEO:            videoLists.add(_vid(cast res));
				default:
			}
		}

		// inline function orblank(v:String) return (v == "") ? "-    \n" : v;
		// inline function orblank(v:StringBuf) return v;
		function orblank(v:StringBuf) {
			if(v.toString() == "") {
				v.add("-    \n");
			}
			return v;
		}

		_totalAll += _totalBts;
		_totalAll += _totalTxt;
		_totalAll += _totalTex;
		_totalAll += _totalRtt;
		_totalAll += _totalSnd;
		_totalAll += _totalFnt;
		_totalAll += _totalVid;

		var lists = new StringBuf();

		// lists.add("Resource list");
		lists.add("Resource list (" + Clay.resources.stats.total + " • ~" + bytesToString(_totalAll) + ") \n \n");

		lists.add("Bytes (" + Clay.resources.stats.bytes + " • ~" + bytesToString(_totalBts) + ")) \n");
			lists.add(orblank(bytesLists));
		lists.add("\nText (" + Clay.resources.stats.texts + " • ~" + bytesToString(_totalTxt) + ") \n");
			lists.add(orblank(textLists));
		lists.add("\nJSON (" + Clay.resources.stats.jsons + ") \n");
			lists.add(orblank(jsonLists));
		lists.add("\nTexture (" + Clay.resources.stats.textures + " • ~" + bytesToString(_totalTex) + ") \n");
			lists.add(orblank(textureLists));
		lists.add("\nRenderTexture (" + Clay.resources.stats.rtt + " • ~" + bytesToString(_totalRtt) + ") \n");
			lists.add(orblank(rttLists));
		lists.add("\nFont (" + Clay.resources.stats.fonts + " • ~" + bytesToString(_totalFnt) + ") \n");
			lists.add(orblank(fontLists));
		// lists.add("\nShader (" + Clay.resources.stats.shaders + ") \n");
			// lists.add(orblank(shaderLists));
		lists.add("\nAudio (" + Clay.resources.stats.audios + " • ~" + bytesToString(_totalSnd) + ") \n");
			lists.add(orblank(audioLists));
		lists.add("\nVideo (" + Clay.resources.stats.videos + " • ~" + bytesToString(_totalVid) + ") \n");
			lists.add(orblank(videoLists));

		return lists.toString();

	}


	function getRenderStats():String {

		var _renderStats = Clay.renderer.stats;

		var sb = new StringBuf();

		sb.add("Renderer Statistics \n \n " +
			"total geometry : " + _renderStats.geometry + " \n " +
			"visible geometry : " + _renderStats.visibleGeometry + " \n " +
			"static geometry : " + _renderStats.locked + " \n " +
			"vertices : " + _renderStats.vertices + " \n " +
			"indices : " + _renderStats.indices + " \n " +
			"draw calls : " + _renderStats.drawCalls + " \n " +
			"layers : " + Clay.renderer.layers.activeCount + " \n " +
			"cameras : " + Clay.renderer.cameras.length + " \n "
		);

		sb.add(cameraStats.toString());

		return sb.toString();

	}

	function getCameraInfo(c:Camera):String {

		var _layers = [];
		for (l in Clay.renderer.layers) {
			if(c._visibleLayersMask.get(l.id)) {
				_layers.push(l);
			}
		}

		var _active:String = c.active ? " " : "/ inactive";

		var _s:String =  "    " + c.name + " ( " + _layers.length + " ) " + _active + " \n ";

		if(!hideLayers && c.active) {
			for (l in _layers) {
				_s += getLayerInfo(l);
			}
		}

		return _s;
		
	}

	inline function getLayerInfo(l:Layer):String {

		return
			"        " + l.name + " | " + l.priority + " \n " +
			"            total geometry : " + l.stats.geometry + " \n " +
			"            visible geometry : " + l.stats.visibleGeometry + " \n " +
			"            static geometry : " + l.stats.locked + " \n " +
			"            vertices : " + l.stats.vertices + " \n " +
			"            indices : " + l.stats.indices + " \n " +
			"            draw calls : " + l.stats.drawCalls + " \n ";

	}

	function refresh() {

		renderStatsText.text = getRenderStats();
		resourceListText.text = getResourceStats();
		cameraStats = new StringBuf();

	}

	// function tabs(_d:Int) {

	// 	var res = "";
	// 	for(i in 0 ... _d) res += "    ";
	// 	return res;

	// }


}
