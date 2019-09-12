package clay.graphics.animation;


import clay.utils.Mathf;
import clay.events.Events;
import clay.graphics.Sprite;
import clay.resources.Texture;
import clay.utils.Log.*;


@:allow(clay.graphics.AnimationData)
class AnimatedSprite extends Sprite {


	public var active  	    (default, null):Bool;
	public var paused  	    (default, null):Bool;

	public var anim_data	(default, null):Map<String, AnimationData>;
	public var current  	(default, null):AnimationData;
	public var frame  	    (get, set):Int;
	public var speedscale  	(default, set):Float;
	public var reverse:Bool;
	public var events:Events;

	@:noCompletion public var time:Float;
	@:noCompletion public var next_frame_time:Float = 0;


	public function new() {

		super();

		anim_data = new Map();
		time = 0;
		speedscale = 1;
		paused = false;
		active = false;
		reverse = false;
	}

	override function update(dt:Float) {

		super.update(dt);

		if(!active || paused || current == null) {
			return;
		}

		var end = false;
		var f = frame;

		time += dt * speedscale;

		if(time >= next_frame_time) {
			next_frame_time = time + current.frame_time;

			if(!reverse) {
				f += 1;
				if(f >= current.frames_count) {
					end = true;
				}
			} else {
				f -= 1;
				if(f < 0) {
					end = true;
				}
			}

			if(end) {
				if(current._loop != 0) {
					if(current._loop > 0) {
						current._loop--;
					}
					f = 0;
					if(events != null) {
						current.emit_event("loop");
					}
				} else {
					stop();
					if(events != null) {
						current.emit_event("end");
					}
					f = frame;
				}
			}
			frame = f;

		}


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

	public function set_animation(_name:String) {
		
		current = anim_data.get(_name);

		if(current != null) {
			next_frame_time = current.frame_time;
			current.init();
		}

	}

	public inline function get_animation(_name:String):AnimationData {
		
		return anim_data.get(_name);

	}

	public inline function add_animation(_anim:AnimationData) {
		
		anim_data.set(_anim.name, _anim);

	}

	public inline function remove_animation(_name:String) {
		
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

		var adata = get_animation(_anim);
		if(adata == null) {
			log("can`t add event to " + _anim + " Animation");
			return;
		}
		adata.add_event(_frame, _event_name);
		
	}

	public function remove_event(_anim:String, _frame:Int, _event_name:String) {

		var adata = get_animation(_anim);
		if(adata == null) {
			log("can`t remove event to " + _anim + " Animation");
			return;
		}
		adata.remove_event(_frame, _event_name);

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

	var row:Int; // w
	var col:Int; // h


	public function new(_anim:AnimatedSprite, _name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>) {

		set_texture(_tpath);

		super(_anim, _name, _frames);

		row = _row;
		col = _col;

	}

	public function set_texture(_p:String):AnimationData {

		texture = Clay.resources.texture(_p);

		if(texture == null) {
			log("failed to load texture: " + _p);
		}

		return this;
		
	}

	override function init() {

		if(anim != null) {
			anim.texture = texture;
		}

		super.init();

	}

	override function set_all():AnimationData {

		frameset = [];

		for (i in 0...row*col) {
			frameset.push(create_frame(i));
		}

		return this;
		
	}

	override function update_geometry() {

		if(texture == null) {
			log("failed to update geometry, no texture");
			return;
		}

		if(anim != null) {
			var szx = 1 / row;
			var szy = 1 / col;
			var tlx = (frame % row) * szx;
			var tly = Math.floor(frame / col) * szy;

			anim.set_uv(tlx, tly, szx, szy);
		}

	}

}


class AnimationDataTextures extends AnimationData {


	var textures:Array<Texture>;


	public function new(_anim:AnimatedSprite, _name:String, _tpath:Array<String>, ?_frames:Array<Int>) {

		super(_anim, _name, _frames);

		set_textures(_tpath);
		
	}

	public function set_textures(_tpath:Array<String>):AnimationData {

		textures = [];

		var t:Texture;
		for (p in _tpath) {
			t = Clay.resources.texture(p);
			if(t == null) {
				log("failed to load texture: " + p);
				return this;
			}
			textures.push(t);
		}

		return this;
		
	}

	override function set_all():AnimationData {

		frameset = [];

		for (i in 0...textures.length) {
			frameset.push(create_frame(i));
		}

		return this;
		
	}

	@:access(clay.graphics.Mesh)
	override function update_geometry() {
		
		if(anim != null) {
			var t = textures[frame];

			if(t == null) {
				log("failed to update geometry, no texture from frame " + frame);
				return;
			}

			if(anim.texture != t) { 
				anim.geometry.texture = t; // this will not sort geometry in layer 
			}
		}

	}


}


@:allow(clay.graphics.animation.AnimatedSprite)
class AnimationData {


	public var name      		(default, null):String;
	public var anim      		(default, null):AnimatedSprite;

	public var frame	 		(default, set):Int;
	public var current_frame	(default, null):AnimationFrame;

	public var frameset 	 	(default, null):Array<AnimationFrame>;
	public var speed        	(default, null):Float;
	public var frame_time		(default, null):Float;

	public var frames_count 	(get, never):Int;

	@:noCompletion public var _loop:Int;
	@:noCompletion public var _oncomplete:()->Void;

	var _last_frame:Int;


	public function new(_anim:AnimatedSprite, _name:String, ?_frames:Array<Int>) {

		anim = _anim;
		name = _name;
		frameset = [];
		_last_frame = 0;
		_loop = 0;
		speed = 1;
		frame = 0;
		frame_time = 1;

		if(_frames != null) {
			set(_frames);
		}

	}

	public function set(_frames:Array<Int>):AnimationData {

		if(_frames.length > 0) {
			for (f in _frames) {
				frameset.push(create_frame(f));
			}
			_last_frame = _frames[_frames.length-1];
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
			frameset.push(create_frame(i));
		}

		_last_frame = max;

		return this;
		
	}
	
	public function set_all():AnimationData {

		return this;

	}

	public function hold(_f:Int):AnimationData {

		for (i in 0..._f) {
			frameset.push(create_frame(_last_frame));
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

		add_event(_frame, _name);

		return this;
		
	}

	public function oncomplete(_fn:()->Void):AnimationData {

		_oncomplete = _fn;

		return this;
		
	}

	@:noCompletion public function emit_event(_name:String) {

		var ev:AnimationEventData = {
			animation: name,
			frame: frame,
			event: _name
		}
		anim.events.fire(_name, ev);

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

	function emit_frame_events() {

		if(anim.events != null) {
			for (ename in current_frame.events) {
				emit_event(ename);
			}
		}

	}

	function update_geometry() {}

	function set_frame(idx:Int):Int {

		frame = idx;
		current_frame = frameset[frame];

		if(current_frame != null) {
			emit_frame_events();
			update_geometry();
		}

		return frame;

	}

	function add_event(iframe:Int, event:String) {

		for (f in frameset) {
			if(f.image_frame == iframe && f.events.indexOf(event) == -1) {
				f.events.push(event);
			}
		}

	}

	function remove_event(iframe:Int, event:String) {
		
		for (f in frameset) {
			if(f.image_frame == iframe) {
				f.events.remove(event);
			}
		}
		
	}

	inline function create_frame(v:Int):AnimationFrame {

		return new AnimationFrame(v);

	}

	inline function get_frames_count():Int {
		
		return frameset.length;

	}


}


class AnimationFrame {


	public var image_frame(default, null):Int;
	public var events(default, null):Array<String>;


	public function new(_frame:Int) {

		image_frame = _frame;
		events = [];

	}


}


typedef AnimationEventData = {
    animation: String,
    frame: Int,
    event: String,
}

