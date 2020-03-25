package clay.graphics.animation;

import clay.utils.Mathf;
import clay.events.Events;
import clay.graphics.Sprite;
import clay.resources.Texture;
import clay.utils.Log.*;

@:allow(clay.graphics.AnimationData)
class AnimatedSprite extends Sprite {

	public var playing(default, null):Bool;
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
		playing = false;
		reverse = false;
	}

	override function update(dt:Float) {
		super.update(dt);

		if(!playing || paused || current == null) {
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
		playing = true;

		if(current != null) {
			current.start();
		}
	}

	public function stop(complete:Bool = false) {
		playing = false;

		if(current != null) {
			current.stop(complete);
		}
	}

	public function pause() {
		paused = true;
	}

	public function unpause() {
		paused = false;
	}

	public function setAnimation(name:String) {
		current = animData.get(name);

		if(current != null) {
			nextFrameTime = current.frameTime;
			current.init();
		}
	}

	public inline function getAnimation(name:String):AnimationData {
		return animData.get(name);
	}

	public inline function addAnimation(anim:AnimationData) {
		animData.set(anim.name, anim);
	}

	public inline function removeAnimation(name:String) {
		animData.remove(name);
	}

	public function fromGrid(name:String, texturePath:String, row:Int, col:Int, ?frames:Array<Int>):AnimationDataGrid {
		var a = new AnimationDataGrid(this, name, texturePath, row, col, frames);
		animData.set(name, a);

		return a;
	}

	public function fromTextures(name:String, texturePaths:Array<String>, ?frames:Array<Int>):AnimationDataTextures {
		var a = new AnimationDataTextures(this, name, texturePaths, frames);
		animData.set(name, a);

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

	public function fromJson(data) {} // TODO
	public function toJson() {} // TODO

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

	var _texture:Texture;

	var _row:Int; // w
	var _col:Int; // h

	public function new(animSprite:AnimatedSprite, name:String, texturePath:String, row:Int, col:Int, ?frames:Array<Int>) {
		setTexture(texturePath);

		super(animSprite, name, frames);

		_row = row;
		_col = col;
	}

	public function setTexture(path:String):AnimationData {
		_texture = Clay.resources.texture(path);

		if(_texture == null) {
			log('failed to load texture `$path` for animation');
		}

		return this;
	}

	override function init() {
		if(anim != null) {
			anim.texture = _texture;
		}

		super.init();
	}

	override function setAll():AnimationData {
		frameset = [];

		for (i in 0..._row*_col) {
			frameset.push(createFrame(i));
		}

		return this;
	}

	override function updateGeometry() {
		if(_texture == null) {
			log('failed to update geometry, no texture');
			return;
		}

		if(anim != null) {
			var szx = 1 / _row;
			var szy = 1 / _col;
			var tlx = (frame % _row) * szx;
			var tly = Math.floor(frame / _col) * szy;

			anim.setUV(tlx, tly, szx, szy);
			_verbose('update sprite uv, frame: $frame, tlx: $tlx, tly: $tly, szx: $szx, szy: $szy');
		}
	}

}

class AnimationDataTextures extends AnimationData {

	var _textures:Array<Texture>;

	public function new(animSprite:AnimatedSprite, name:String, texturesPath:Array<String>, ?frames:Array<Int>) {
		super(animSprite, name, frames);
		setTextures(texturesPath);
	}

	public function setTextures(texturesPath:Array<String>):AnimationData {
		_textures = [];
		var t:Texture;
		for (p in texturesPath) {
			t = Clay.resources.texture(p);
			if(t == null) {
				log('failed to load texture `$p` for animation');
				continue;
			}
			_textures.push(t);
		}

		return this;
	}

	override function setAll():AnimationData {
		frameset = [];
		for (i in 0..._textures.length) {
			frameset.push(createFrame(i));
		}

		return this;
	}

	@:access(clay.graphics.Mesh)
	override function updateGeometry() {
		if(anim != null) {
			var t = _textures[frame];

			if(t == null) {
				log("failed to update geometry, no texture from frame " + frame);
				return;
			}

			if(anim.texture != t) { 
				if(anim.texture != null) {
					anim.texture.unref();
				}
				anim._texture = t; // this will not sort geometry in layer 
				anim.texture.ref();
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

	public function new(animSprite:AnimatedSprite, name:String, ?frames:Array<Int>) {
		anim = animSprite;
		this.name = name;
		frameset = [];
		_lastFrame = 0;
		_loop = 0;
		speed = 1;
		frame = 0;
		frameTime = 1;

		if(frames != null) {
			set(frames);
		}
	}

	public function set(frames:Array<Int>):AnimationData {
		if(frames.length > 0) {
			for (f in frames) {
				frameset.push(createFrame(f));
			}
			_lastFrame = frames[frames.length-1];
		}

		return this;
	}
	
	public function setRange(from:Int, to:Int):AnimationData {
		var min:Int = from;
		var max:Int = to;

		if(from > to) {
			min = to;
			max = from;
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

	public function hold(framesCount:Int):AnimationData {
		for (i in 0...framesCount) {
			frameset.push(createFrame(_lastFrame));
		}

		return this;
	}

	public function setSpeed(v:Float):AnimationData {
		if(v > 0) {
			speed = v;
			frameTime = 1 / speed;
		}

		return this;
	}

	public function loop(times:Int = -1):AnimationData {
		_loop = times;

		return this;
	}

	public function event(frame:Int, name:String):AnimationData {
		addEvent(frame, name);

		return this;
	}

	public function onComplete(fn:()->Void):AnimationData {
		_onComplete = fn;

		return this;
	}

	@:noCompletion public function emitEvent(name:String) {
		var ev:AnimationEventData = {
			animation: name,
			frame: frame,
			event: name
		}
		anim.events.fire(name, ev);
	}

	function start() {
		frame = 0;
	}

	function stop(complete:Bool) {
		if(complete) {
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

	inline function get_framesCount():Int {
		return frameset.length;
	}

}

class AnimationFrame {

	public var imageFrame(default, null):Int;
	public var events(default, null):Array<String>;

	public function new(frame:Int) {
		imageFrame = frame;
		events = [];
	}

}

typedef AnimationEventData = {

    var animation:String;
    var frame:Int;
    var event:String;

}

