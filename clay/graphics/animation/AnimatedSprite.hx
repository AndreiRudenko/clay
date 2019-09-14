package clay.graphics.animation;


import clay.utils.Mathf;
import clay.events.Events;
import clay.graphics.Sprite;
import clay.resources.Texture;
import clay.utils.Log.*;


@:allow(clay.graphics.AnimationData)
class AnimatedSprite extends Sprite {


	public var active(default, null):Bool;
	public var paused(default, null):Bool;

	public var animData(default, null):Map<String, AnimationData>;
	public var current(default, null):AnimationData;
	public var frame(get, set):Int;
	public var speedScale(default, set):Float;
	public var reverse:Bool;
	public var events:Events;

	@:noCompletion public var time:Float;
	@:noCompletion public var nextFrameTime:Float = 0;


	public function new() {

		super();

		animData = new Map();
		time = 0;
		speedScale = 1;
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

		time += dt * speedScale;

		if(time >= nextFrameTime) {
			nextFrameTime = time + current.frameTime;

			if(!reverse) {
				f += 1;
				if(f >= current.framesCount) {
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
						current.emitEvent("loop");
					}
				} else {
					stop();
					if(events != null) {
						current.emitEvent("end");
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

	public function setAnimation(_name:String) {
		
		current = animData.get(_name);

		if(current != null) {
			nextFrameTime = current.frameTime;
			current.init();
		}

	}

	public inline function getAnimation(_name:String):AnimationData {
		
		return animData.get(_name);

	}

	public inline function addAnimation(_anim:AnimationData) {
		
		animData.set(_anim.name, _anim);

	}

	public inline function removeAnimation(_name:String) {
		
		animData.remove(_name);

	}

	public function fromGrid(_name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>):AnimationDataGrid {

		var a = new AnimationDataGrid(this, _name, _tpath, _row, _col, _frames);
		animData.set(_name, a);

		return a;

	}

	public function fromTextures(_name:String, _tpaths:Array<String>, ?_frames:Array<Int>):AnimationDataTextures {

		var a = new AnimationDataTextures(this, _name, _tpaths, _frames);
		animData.set(_name, a);

		return a;

	}

	public function addEvent(_anim:String, _frame:Int, _eventName:String) {

		var adata = getAnimation(_anim);
		if(adata == null) {
			log("can`t add event to " + _anim + " Animation");
			return;
		}
		adata.addEvent(_frame, _eventName);
		
	}

	public function removeEvent(_anim:String, _frame:Int, _eventName:String) {

		var adata = getAnimation(_anim);
		if(adata == null) {
			log("can`t remove event to " + _anim + " Animation");
			return;
		}
		adata.removeEvent(_frame, _eventName);

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

	function set_speedScale(v:Float):Float {
		
		return speedScale = v;

	}


}


class AnimationDataGrid extends AnimationData {


	var texture:Texture;

	var row:Int; // w
	var col:Int; // h


	public function new(_anim:AnimatedSprite, _name:String, _tpath:String, _row:Int, _col:Int, ?_frames:Array<Int>) {

		setTexture(_tpath);

		super(_anim, _name, _frames);

		row = _row;
		col = _col;

	}

	public function setTexture(_p:String):AnimationData {

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

	override function setAll():AnimationData {

		frameset = [];

		for (i in 0...row*col) {
			frameset.push(createFrame(i));
		}

		return this;
		
	}

	override function updateGeometry() {

		if(texture == null) {
			log("failed to update geometry, no texture");
			return;
		}

		if(anim != null) {
			var szx = 1 / row;
			var szy = 1 / col;
			var tlx = (frame % row) * szx;
			var tly = Math.floor(frame / col) * szy;

			anim.setUv(tlx, tly, szx, szy);
		}

	}

}


class AnimationDataTextures extends AnimationData {


	var textures:Array<Texture>;


	public function new(_anim:AnimatedSprite, _name:String, _tpath:Array<String>, ?_frames:Array<Int>) {

		super(_anim, _name, _frames);

		setTextures(_tpath);
		
	}

	public function setTextures(_tpath:Array<String>):AnimationData {

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

	override function setAll():AnimationData {

		frameset = [];

		for (i in 0...textures.length) {
			frameset.push(createFrame(i));
		}

		return this;
		
	}

	@:access(clay.graphics.Mesh)
	override function updateGeometry() {
		
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


	public var name(default, null):String;
	public var anim(default, null):AnimatedSprite;

	public var frame(default, set):Int;
	public var currentFrame(default, null):AnimationFrame;

	public var frameset(default, null):Array<AnimationFrame>;
	public var speed(default, null):Float;
	public var frameTime(default, null):Float;

	public var framesCount(get, never):Int;

	@:noCompletion public var _loop:Int;
	@:noCompletion public var _onComplete:()->Void;

	var _lastFrame:Int;


	public function new(_anim:AnimatedSprite, _name:String, ?_frames:Array<Int>) {

		anim = _anim;
		name = _name;
		frameset = [];
		_lastFrame = 0;
		_loop = 0;
		speed = 1;
		frame = 0;
		frameTime = 1;

		if(_frames != null) {
			set(_frames);
		}

	}

	public function set(_frames:Array<Int>):AnimationData {

		if(_frames.length > 0) {
			for (f in _frames) {
				frameset.push(createFrame(f));
			}
			_lastFrame = _frames[_frames.length-1];
		}

		return this;
		
	}
	
	public function setRange(_from:Int, _to:Int):AnimationData {

		var min:Int = _from;
		var max:Int = _to;

		if(_from > _to) {
			min = _to;
			max = _from;
		}

		for (i in min...max+1) {
			frameset.push(createFrame(i));
		}

		_lastFrame = max;

		return this;
		
	}
	
	public function setAll():AnimationData {

		return this;

	}

	public function hold(_f:Int):AnimationData {

		for (i in 0..._f) {
			frameset.push(createFrame(_lastFrame));
		}

		return this;
		
	}

	public function setSpeed(_v:Float):AnimationData {

		if(_v > 0) {
			speed = _v;
			frameTime = 1 / speed;
		}

		return this;
		
	}

	public function loop(_times:Int = -1):AnimationData {

		_loop = _times;

		return this;
		
	}

	public function event(_frame:Int, _name:String):AnimationData {

		addEvent(_frame, _name);

		return this;
		
	}

	public function onComplete(_fn:()->Void):AnimationData {

		_onComplete = _fn;

		return this;
		
	}

	@:noCompletion public function emitEvent(_name:String) {

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
			frame = framesCount-1;
			if(_onComplete != null) {
				_onComplete();
			}
		}

	}

	function init() {

		updateGeometry();

	}

	function emitFrameEvents() {

		if(anim.events != null) {
			for (ename in currentFrame.events) {
				emitEvent(ename);
			}
		}

	}

	function updateGeometry() {}

	function set_frame(idx:Int):Int {

		frame = idx;
		currentFrame = frameset[frame];

		if(currentFrame != null) {
			emitFrameEvents();
			updateGeometry();
		}

		return frame;

	}

	function addEvent(iframe:Int, event:String) {

		for (f in frameset) {
			if(f.imageFrame == iframe && f.events.indexOf(event) == -1) {
				f.events.push(event);
			}
		}

	}

	function removeEvent(iframe:Int, event:String) {
		
		for (f in frameset) {
			if(f.imageFrame == iframe) {
				f.events.remove(event);
			}
		}
		
	}

	inline function createFrame(v:Int):AnimationFrame {

		return new AnimationFrame(v);

	}

	inline function getFramesCount():Int {
		
		return frameset.length;

	}


}


class AnimationFrame {


	public var imageFrame(default, null):Int;
	public var events(default, null):Array<String>;


	public function new(_frame:Int) {

		imageFrame = _frame;
		events = [];

	}


}


typedef AnimationEventData = {
    animation: String,
    frame: Int,
    event: String,
}

