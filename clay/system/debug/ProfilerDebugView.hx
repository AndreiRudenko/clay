package clay.system.debug;


import clay.Clay;
import clay.render.Camera;
import clay.graphics.Text;
import clay.graphics.shapes.Quad;
import clay.graphics.Mesh;
import clay.render.Color;
import clay.math.Vector;
import clay.utils.Mathf;
import clay.system.Debug;
import clay.input.Keyboard;
import clay.input.Key;
import clay.input.Mouse;
import clay.render.Layer;
import clay.render.Vertex;
import clay.system.ResourceManager;
import clay.resources.Resource;
import clay.resources.AudioResource;
import clay.resources.BytesResource;
import clay.resources.FontResource;
import clay.resources.JsonResource;
import clay.resources.TextResource;
import clay.resources.Texture;
import clay.resources.VideoResource;
import clay.utils.Log.*;


@:access(
	clay.render.Renderer, 
	clay.render.Camera
)
class ProfilerDebugView extends DebugView {


	public var lists:Map<String,ProfilerValue>;

	public static var colorClip : Color = new Color().fromInt(0xf55d4c);
	public static var colorHi : Color = new Color().fromInt(0xff9f19);
	public static var colorMid : Color = new Color().fromInt(0xe0ce00);
	public static var colorLow : Color = new Color().fromInt(0x8cc63f);


	public function new(_debug:Debug) {

		super(_debug);

		debugName = "Profiler";
		lists = new Map();

	}

	override function onEnabled() {

		for(_item in lists) {
			if(!_item.hidden) {
				_item.bar.show();
			}
		}

	}

	override function onDisabled() {

		for(_item in lists) {
			_item.bar.hide();
		}

	}

	public function start(_id:String, ?_max:Float) {

		var _item = lists.get(_id);
		var rect = debug.inspector.viewrect;

		if(_item == null) {
			//create it
			_item = new ProfilerValue(_id, new ProfilerBar(_id, _max, new Color().fromInt(0xffa563) ));
			// _item.bar.pos = new Vector(Clay.debug.padding.x*2,(Clay.debug.padding.y*3) + (Lambda.count(lists) * 20) );
			_item.bar.pos = new Vector(rect.x,(rect.y) + (Lambda.count(lists) * 20) );
			lists.set(_id, _item);
		}

		// _item.start = Clay.time;
		_item.start = kha.System.time;

	} //start

	public function end(_id:String) {

		var _item = lists.get(_id);

		if(_item!=null) {
			_item.set();
		} else {
			throw "Debug / profile end called for " + _id + " but no start called";
		}

	} //end

	public function remove(_id:String) {

		var _item = lists.get(_id);

		if(_item!=null) {
			_item.destroy();
			lists.remove(_id);
		}

	} //end

	function refresh() {

	}

}

private class ProfilerValue {

	// public var offsets : Array<ProfilerValue>;
	public var bar : ProfilerBar;
	public var name : String;
	public var start : Float = 0.0;
	public var history : Array<Float>;
	public var avg : Int = 10;
	public var hidden : Bool = false;
	var count : Int = 0;
	var accum : Float = 0;

	public function new(_name:String, _bar:ProfilerBar) {
		name = _name; bar = _bar;
		history = [];
		// offsets = [];
	}

	public function set() {

		// var _t = Clay.time - start;
		var _t = kha.System.time - start;

			//adjust by any offsets
		// for(_offset in offsets) {
		//     _t -= _offset.history[_offset.history.length-1];
		// }

			//push the value into history
		history.push(_t);
			//drop old values
		if(history.length > avg) {
			history.shift();
		}

		count++;
			//reset if maxed average
		if(count == avg) {
			var __t = accum / avg;
			bar.value = __t;
			accum = 0;
			count = 0;
		}

		accum += _t;

		if(bar.visible) {
			bar.text = Std.string(Mathf.fixed(_t*1000,2));
		}

	}

	public function destroy() {

		bar.destroy();

	}

}

private class ProfilerGraph {

	public var graphbgGeometry : Quad;
	public var graphGeometry : Mesh;
	public var name : String;

	var bg : Bool = true;

	public var width : Float = 128;
	public var height : Float = 8;
	public var height2 : Float = 8;
	public var history:Int = 33;
	// public var history:Int = 11;
	public var visible:Bool = false;
	public var color:Color;

	@:isVar public var max (default,set) : Float;
	@:isVar public var ping (default,set) : Float;
	@:isVar public var pos (default,set) : Vector;

	var segment : Float;
	// var world : World;
	var vertices : Array<Vertex>;

	public function new(_name:String, _bg:Bool=true){

		// this.world = world;

		bg = _bg;
		name = _name;
		// color = new Color();
		color = ProfilerDebugView.colorLow;
		max = Mathf.fixed((1/60) * 1000, 2);

	} //new

	public function create() {

		vertices = [];

		segment = (width/history);
		height2 = height*2;

		if(bg) {
			graphbgGeometry = new Quad(width-segment, height2);
			graphbgGeometry.color = new Color().fromInt(0x101010);
			graphbgGeometry.depth = 999.3;
			graphbgGeometry.layer = Clay.debug.layer;
		}

		graphGeometry = new Mesh();
		graphGeometry.depth = 999.3;
		graphGeometry.color = color;
		graphGeometry.layer = Clay.debug.layer;

		for (i in 0...history) {
			var top = new Vertex(new Vector(segment*i, height2), color);
			var bottom = new Vertex(new Vector(segment*i, height2), color);
			vertices.push(top);
			graphGeometry.vertices.push(top);
			graphGeometry.vertices.push(bottom);
		}

		for (i in 0...(history-1)*2) {
			graphGeometry.indices[i * 3 + 0] = i + 0;
			graphGeometry.indices[i * 3 + 1] = i + 1;
			graphGeometry.indices[i * 3 + 2] = i + 2;
		}

		hide();

	}

		//when changing the max we adjust
		//all the values in the history to reflect
	function set_max(_v:Float) {

		var oldmax = max;
		max = _v;

		if(graphGeometry != null) {
			var ratio = 1.0;
			if(oldmax != 0) {
				ratio = oldmax/_v;
			}
			for(v in vertices) {
				//get the value out as 0 - 1
				var vp = 1.0 - (v.pos.y / height2);
				//multiply it by the old max to get the value
				var vv = vp * oldmax;
				//get the new % over new max
				vp = vv / max;
				//and then set the new y pos
				v.pos.y = height2*(1.0-vp);
			}
		}

		return max;
	}

	function set_ping(_v:Float) {

		var _vv = Mathf.fixed(_v,4);
		var _p = _vv/max;


			//shift every vertex left
		for(i in 0 ... history) {
			//copy x from the next one
			var v = vertices[i];
			if(i < (history-1)) {
				var v1 = vertices[i+1];
				if(v1 != null) {
					v.pos.y = Math.floor(v1.pos.y);
					v.color = v1.color;
				}
			}
		}

		if(_p > 1) {
			vertices[history-1].color = ProfilerDebugView.colorClip;
		} else if(_p > 0.66) {
			vertices[history-1].color = ProfilerDebugView.colorHi;
		} else if(_p > 0.33) {
			vertices[history-1].color = ProfilerDebugView.colorMid;
		} else {
			vertices[history-1].color = ProfilerDebugView.colorLow;
		}

		_p = Mathf.clamp(_p, 0.001, 1);

		vertices[history-1].pos.y = Math.floor(((height2)*(1.0-_p)));

		return ping = _v;

	} //setPing

	public function hide() {
		visible = false;
		graphGeometry.visible = false;
		if(graphbgGeometry != null) graphbgGeometry.visible = false;
	}

	public function show() {
		visible = true;
		graphGeometry.visible = true;
		if(graphbgGeometry != null) graphbgGeometry.visible = true;
	}

	function set_pos(_p:Vector) {

		if(graphbgGeometry != null) graphbgGeometry.transform.pos.copyFrom(_p);
		graphGeometry.transform.pos.copyFrom(_p);

		return pos = _p;

	} //setPos

	public function destroy() {

		graphbgGeometry.drop();
		graphGeometry.drop();
		graphbgGeometry = null;
		graphGeometry = null;

	}

}

private class ProfilerBar {

	public var barGeometry : Quad;
	public var bgGeometry : Quad;
	public var graph : ProfilerGraph;

	public var textItem : Text;
	public var name : String;

	public var visible:Bool = false;
	public var height : Float = 8;
	public var max : Float = 16.7;

	@:isVar public var text (default,set) : String;
	@:isVar public var pos (default,set) : Vector;
	@:isVar public var value (default,set) : Float;

	public function new(_name:String, ?_max:Float, _color:Color) {

		name = _name;

		graph = new ProfilerGraph(_name);
		graph.create();
		if(_max != null) max = graph.max = _max;

		textItem = new Text(Clay.renderer.font);
		textItem.size = Std.int(height*1.8);
		textItem.color = _color;
		textItem.layer = Clay.debug.layer;
		textItem.depth = 999.3;

		bgGeometry = new Quad(graph.width-2, graph.height-2);
		bgGeometry.color = new Color().fromInt(0x090909);
		bgGeometry.depth = 999.3;
		bgGeometry.layer = Clay.debug.layer;

		barGeometry = new Quad(graph.width, graph.height);
		barGeometry.color = _color;
		barGeometry.depth = 999.33;
		barGeometry.layer = Clay.debug.layer;
		barGeometry.transform.pos.set(1,1);

		hide();

	} //new

	public function hide() {
		visible = false;
		barGeometry.visible = false;
		bgGeometry.visible = false;
		textItem.visible = false;
		graph.hide();
	}

	public function show() {
		visible = true;
		barGeometry.visible = true;
		bgGeometry.visible = true;
		textItem.visible = true;
		graph.show();
	}

	public function destroy() {

		graph.destroy();
		barGeometry.drop();
		bgGeometry.drop();
		textItem.drop();
		graph = null;
		barGeometry = null;
		bgGeometry = null;
		textItem = null;
		
	}

	function set_value(_v:Float) {

		graph.ping = _v * 1000;

		if(!this.visible) return value = _v;

		var _vv = Mathf.fixed(_v*1000,4);
		var _p = _vv/max;

		if(_p > 1) {
			barGeometry.color = ProfilerDebugView.colorClip;
		} else if(_p > 0.66) {
			barGeometry.color = ProfilerDebugView.colorHi;
		} else if(_p > 0.33) {
			barGeometry.color = ProfilerDebugView.colorMid;
		} else {
			barGeometry.color = ProfilerDebugView.colorLow;
		}

		_p = Mathf.clamp(_p, 0.005, 1);

		var nx = (graph.width-2) * _p;
		barGeometry.size.set(nx, graph.height-2);

		return value = _v;

	} //setValue

	function set_pos(_p:Vector) {
		bgGeometry.transform.pos.copyFrom(_p);
		barGeometry.transform.pos.set(_p.x+1, _p.y+1);
		textItem.transform.pos.set(_p.x+(graph.width*2)+10, _p.y-6);
		graph.pos = _p.clone().addXY(graph.width+2, -graph.height+4);
		return pos = _p;
	}

	function set_text(_t:String) {
		textItem.text = name + " (" + graph.max + "ms) | " + _t + "ms";
		return text = _t;
	}

} //ProfilerBar
