package clay.components;


import clay.math.Rectangle;
import clay.utils.Log.*;


@:allow(
	clay.processors.AnimationProcessor,
	clay.components.AnimationData
)
class Animation {


	public var active  	    (default, null):Bool;
	public var paused  	    (default, null):Bool;

	public var anim_data	(default, null):Map<String, AnimationData>;
	public var current  	(default, null):AnimationData;
	// public var reverse:Bool;
	public var frame  	    (get, set):Int;
	public var speedscale  	(default, set):Float;

	var inited:Bool;

	@:noCompletion public var time:Float;
	@:noCompletion public var geometry:QuadGeometry;
    @:noCompletion public var next_frame_time : Float = 0;


	public function new() {

		anim_data = new Map();
		time = 0;
		speedscale = 1;
		paused = false;
		active = false;
		// reverse = false;
		inited = false;

	}

	public function play() {

		active = true;

		if(current != null) {
			current.start();
		}

	}

	public function stop(_complete:Bool = false) {

		active = false;

		if(current != null) {
			current.stop(_complete);
		}

	}

	public inline function restart() {

		stop();
		play();

	}

	public function pause() {

		paused = true;

	}

	public function unpause() {

		paused = false;

	}

	public function set(_name:String) {
		
		current = anim_data.get(_name);

		if(current != null) {
			next_frame_time = current.frame_time;
			if(inited) {
				current.init();
			}
			// reverse = current._reverse;
		}

	}

	public function get(_name:String):AnimationData {
		
		return anim_data.get(_name);

	}

	public function add(_anim:AnimationData) {
		
		anim_data.set(_anim.name, _anim);

	}

	public function remove(_name:String) {
		
		anim_data.remove(_name);

	}

	public function from_grid(_name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>):AnimationDataGrid {

		var a = new AnimationDataGrid(this, _name, _tpath, _row, _col, _frames);
		anim_data.set(_name, a);

		return a;
		
	}

	public function from_textures(_name:String, _tpaths:Array<String>, ?_frames:Array<Int>):AnimationDataTextures {

		var a = new AnimationDataTextures(this, _name, _tpaths, _frames);
		anim_data.set(_name, a);

		return a;
		
	}
	
	@:noCompletion public function init() {

		inited = true;

		if(current != null) {
			current.init();
		}

	}

	function get_frame():Int {
		
		var _frame:Int = 0;

		if(current != null) {
			_frame = current.frame;
		}

		return _frame;

	}

	function set_frame(v:Int):Int {
		
		if(current != null) {
			current.frame = v;
		}

		return v;

	}

	function set_speedscale(v:Float):Float {
		
		return speedscale = v;

	}


}

class AnimationDataGrid extends AnimationData {


	var texture:Texture;
	var rect:Rectangle;

	var row:Int;
	var col:Int;


	public function new(_anim:Animation, _name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>) {

		super(_anim, _name, _frames);

		type = AnimationType.grid;

		row = _row;
		col = _col;

		rect = new Rectangle();

		set_texture(_tpath);

	}

	public function set_texture(_p:String):AnimationData {

		texture = Clay.resources.texture(_p);

		if(texture == null) {
			log('failed to load texture: ${_p}');
		}

		return this;
		
	}

	override function set_all():AnimationData {

		frames = [];

		for (i in 0...row*col) {
			frames.push(i);
		}

		return this;
		
	}

	override function update_geometry() {

		if(texture == null) {
			log('failed to update geometry, no texture');
			return;
		}

		var szx = row / texture.width_actual;
		var szy = col / texture.width_actual;
		var tlx = frame * szx;
		var tly = frame * szy;

		rect.set(tlx, tly, szx, szy);
		anim.geometry.set_tcoord(rect);

	}

}

class AnimationDataTextures extends AnimationData {


	var textures:Array<Texture>;


	public function new(_anim:Animation, _name:String, _tpath:Array<String>, ?_frames:Array<Int>) {

		super(_anim, _name, _frames);

		type = AnimationType.texture;

		set_textures(_tpath);
		
	}

	public function set_textures(_tpath:Array<String>):AnimationData {

		textures = [];

		var t:Texture;
		for (p in _tpath) {
			t = Clay.resources.texture(p);
			if(t == null) {
				log('failed to load texture: ${p}');
				return this;
			}
			textures.push(t);
		}

		return this;
		
	}

	override function set_all():AnimationData {

		frames = [];

		for (i in 0...textures.length) {
			frames.push(i);
		}

		return this;
		
	}

	@:access(clay.components.Geometry)
	override function update_geometry() {
		
		var geom = anim.geometry;
		var t = textures[frame];

		if(t == null) {
			log('failed to update geometry, no texture from frame ${frame}');
			return;
		}

		if(geom._texture != t) { 
			geom._texture = t; // this will not sort geometry in layer 
		}

	}


}

@:allow(clay.components.Animation)
class AnimationData {


	public var name      	(default, null):String;
	public var anim      	(default, null):Animation;

	public var frames 	 	(default, null):Array<Int>;
	public var frame	 	(default, set):Int = 0;
	public var type      	(default, null):AnimationType;
	public var speed        (default, null):Float = 1;
	public var frame_time	(default, null):Float = 1;

	@:noCompletion public var _loop:Int = 0;
	@:noCompletion public var _reverse:Bool = false;
	@:noCompletion public var _oncomplete:Void->Void;

	var events:Map<Int, String>;
	var last_frame:Int = -1;


	public function new(_anim:Animation, _name:String, ?_frames:Array<Int>) {

		anim = _anim;
		name = _name;
		frames = _frames != null ? _frames : [];
		events = new Map();
		type = AnimationType.grid;

	}

	public function set(_frames:Array<Int>):AnimationData {

		if(_frames.length > 0) {
			for (f in _frames) {
				frames.push(f);
			}
			last_frame = _frames[_frames.length-1];
		}

		return this;
		
	}
	
	public function set_range(_from:Int, _to:Int):AnimationData {

		var min:Int = _from;
		var max:Int = _to;

		if(_from > _to) {
			min = _to;
			max = _from;
		}

		for (i in min...max+1) {
			frames.push(i);
		}

		last_frame = max;

		return this;
		
	}
	
	public function set_all():AnimationData {

		return this;

	}

	public function hold(_f:Int):AnimationData {

		if(last_frame >= 0) {
			for (i in 0..._f) {
				frames.push(last_frame);
			}
		}

		return this;
		
	}

	public function set_speed(_v:Float):AnimationData {

		if(_v > 0) {
			speed = _v;
			frame_time = 1 / speed;
		}

		return this;
		
	}

	public function loop(_times:Int = -1):AnimationData {

		_loop = _times;

		return this;
		
	}

	public function reverse(_v:Bool = true):AnimationData {

		_reverse = _v;

		return this;
		
	}

	public function event(_frame:Int, _name:String):AnimationData {

		events.set(_frame, _name);

		return this;
		
	}

	public function oncomplete(_fn:Void->Void):AnimationData {

		_oncomplete = _fn;

		return this;
		
	}

	public function from_json(_opt:Dynamic) {

	}

	public function to_json():Dynamic {

		return null;

	}

	function start() {

	}

	function stop(_complete:Bool) {

		if(_complete) {
			if(_oncomplete != null) {
				_oncomplete();
			}
		} else {

		}

	}

	function init() {

		update_geometry();
		
	}

	function update_geometry() {
		
	}

	function check_event(f:Int) {

		var e = events.get(f);

		if(e != null) {
			// fire event
		}
		
	}

	function set_frame(v:Int):Int {

		if(v < 0) {
			v = 0;
		}

		frame = v;
		update_geometry();

		return frame;

	}


}

@:enum abstract AnimationType(Int) from Int to Int {

	var grid          = 0;
	var texture       = 1;

}
