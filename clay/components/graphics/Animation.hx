package clay.components.graphics;


import clay.math.Rectangle;
import clay.math.Mathf;
import clay.components.event.Events;
import clay.utils.Log.*;


@:allow(
	clay.processors.graphics.AnimationProcessor,
	clay.components.graphics.AnimationData
)
class Animation {


	public var active  	    (default, null):Bool;
	public var paused  	    (default, null):Bool;

	public var anim_data	(default, null):Map<String, AnimationData>;
	public var current  	(default, null):AnimationData;
	public var frame  	    (get, set):Int;
	public var speedscale  	(default, set):Float;
	public var reverse:Bool;

	@:noCompletion public var time:Float;
	@:noCompletion public var geometry:QuadGeometry;
	@:noCompletion public var next_frame_time:Float = 0;

	var inited:Bool;


	public function new() {

		anim_data = new Map();
		time = 0;
		speedscale = 1;
		paused = false;
		active = false;
		reverse = false;
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

	public function add_event(_anim:String, _frame:Int, _event_name:String) {
		
	}

	public function remove_event(_anim:String, _frame:Int, _event_name:String) {
		
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

	var row:Int; // w
	var col:Int; // h


	public function new(_anim:Animation, _name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>) {

		set_texture(_tpath);

		super(_anim, _name, _frames);

		row = _row;
		col = _col;

		rect = new Rectangle();

	}

	public function set_texture(_p:String):AnimationData {

		texture = Clay.resources.texture(_p);

		if(texture == null) {
			log('failed to load texture: ${_p}');
		}

		return this;
		
	}

	override function init() {

		if(anim.geometry != null) {
			anim.geometry.texture = texture;
		}

		super.init();

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

		if(anim.geometry != null) {
			var szx = 1 / row;
			var szy = 1 / col;
			var tlx = (frame % row) * szx;
			var tly = Math.floor(frame / col) * szy;

			rect.set(tlx, tly, szx, szy);
			anim.geometry.set_tcoord(rect);
		}

	}

}


class AnimationDataTextures extends AnimationData {


	var textures:Array<Texture>;


	public function new(_anim:Animation, _name:String, _tpath:Array<String>, ?_frames:Array<Int>) {

		super(_anim, _name, _frames);

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

	@:access(clay.components.graphics.Geometry)
	override function update_geometry() {
		
		var geom = anim.geometry;

		if(geom != null) {
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


}


@:allow(clay.components.graphics.Animation)
class AnimationData {


	public var name      	(default, null):String;
	public var anim      	(default, null):Animation;

	public var frames 	 	(default, null):Array<Int>;
	public var frames_count (get, never):Int;
	public var frame	 	(default, set):Int;
	public var speed        (default, null):Float;
	public var frame_time	(default, null):Float;

	@:noCompletion public var _loop:Int;
	@:noCompletion public var _oncomplete:Void->Void;

	var events:Map<Int, String>;
	var last_frame:Int;


	public function new(_anim:Animation, _name:String, ?_frames:Array<Int>) {

		anim = _anim;
		name = _name;
		frames = _frames != null ? _frames : [];
		events = new Map();
		last_frame = 0;
		_loop = 0;
		speed = 1;
		frame = 0;
		frame_time = 1;

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

		for (i in 0..._f) {
			frames.push(last_frame);
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

	public function event(_frame:Int, _name:String):AnimationData {

		events.set(_frame, _name);

		return this;
		
	}

	public function oncomplete(_fn:Void->Void):AnimationData {

		_oncomplete = _fn;

		return this;
		
	}

	function start() {

		frame = 0;

	}

	function stop(_complete:Bool) {

		if(_complete) {
			frame = frames_count-1;
			if(_oncomplete != null) {
				_oncomplete();
			}
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

		frame = Mathf.clamp_bottomi(v, 0);

		check_event(frame);
		update_geometry();

		return frame;

	}

	inline function get_frames_count():Int {
		
		return frames.length;

	}


}