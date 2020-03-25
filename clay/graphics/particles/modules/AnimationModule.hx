package clay.graphics.particles.modules;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleModule;
import clay.graphics.particles.core.Components;
import clay.graphics.particles.components.Region;
import clay.graphics.particles.components.Animation;
import clay.math.Vector;
import clay.utils.ArrayTools;
import clay.utils.Log.*;

using clay.graphics.particles.utils.VectorExtender;

class AnimationModule extends ParticleModule {

	public var speed(default, set):Float;
	public var loops(default, set):Int;

	public var rows(get, set):Int;
	public var columns(get, set):Int;

	var _frames:Array<Int>;
	var _framesMax:Int;

	var _rows:Int;
	var _columns:Int;

	var _region:Components<Region>;
	var _animation:Components<Animation>;

	public function new(options:AnimationModuleOptions) {
		super(options);

		_frames = [];
		_framesMax = 1;
		_rows = 1;
		_columns = 1;

		rows = def(options.rows, 1);
		columns = def(options.columns, 1);

		speed = def(options.speed, 1);
		loops = def(options.loops, -1);

		if(options.frames != null) {
			setFrames(options.frames);
		} else {
			setFramesAll();
		}
	}

	override function onAdded() {
		_region = emitter.components.get(Region);
		_animation = emitter.components.get(Animation);
	}

	override function onRemoved() {
		emitter.components.put(_region);
		emitter.components.put(_animation);
		_region = null;
		_animation = null;
	}

	override function onDisabled() {
		particles.forEach(
			function(p) {
				_region.get(p.id).set(0,0,1,1);
			}
		);
	}

	override function onSpawn(p:Particle) {
		if(_frames.length > 0) {
			var a:Animation;
			var startFrame = 0;

			a = _animation.get(p.id);
			a.framePosition = 0;
			a.loops = loops;
			a.frame = startFrame;
			var animFrames = _frames.length - a.frame;
			if(animFrames > 0) {
				a.frameDelta = animFrames / p.lifetime;
				a.active = true;
			} else {
				log('there is no frames to animate particle from startFrame: $startFrame to ${_frames.length}');
				a.frameDelta = 0;
				a.active = false;
			}
			a.nextFrameIdx = a.frame + 1;
			updateParticleRegion(a.frame, _region.get(p.id));
		}
	}

	override function update(dt:Float) {
		if(_frames.length > 0) {
			var a:Animation;
			for (p in particles) {
				a = _animation.get(p.id);
				if(a.active) {
					a.framePosition += a.frameDelta * speed * dt;
					if(a.framePosition >= a.nextFrameIdx) {
						a.frame = a.nextFrameIdx;
						a.nextFrameIdx += 1;
						if(a.nextFrameIdx >= _frames.length) { // endFrame
							if(a.loops != 0) {
								if(a.loops > 0) {
									a.loops--;
								}
								a.frame = 0; // startFrame
								a.nextFrameIdx = a.frame + 1;
							} else {
								a.frame = _frames.length-1; // endFrame
								a.active = false;
							}
						}
						updateParticleRegion(a.frame, _region.get(p.id));
					}
				}
			}
		}
	}

	public function setFrames(frames:Array<Int>) {
		ArrayTools.clear(_frames);

		for (i in frames) {
			_frames.push(i);
		}
	}

	public function setFramesAll() {
		ArrayTools.clear(_frames);

		for (i in 0..._framesMax) {
			_frames.push(i);
		}
	}

	function updateParticleRegion(frame:Int, r:Region) {
		if(frame > _frames.length -1) {
			log('can`t set frame: $frame, max frames: ${_frames.length}');
		} else {
			var frameIdx = _frames[frame];
			var szx = 1 / rows;
			var szy = 1 / columns;
			var tlx = (frameIdx % rows) * szx;
			var tly = Math.floor(frameIdx / (columns+1)) * szy;
			r.set(tlx, tly, szx, szy);
		}
	}

	function set_speed(v:Float):Float {
		speed = v;

		return speed;
	}

	function set_loops(v:Int):Int {
		loops = v;

		return loops;
	}

	inline function get_rows():Int {
		return _rows;
	}

	function set_rows(v:Int):Int {
		_rows = v;
		calcFramesMax();

		return _rows;
	}

	inline function get_columns():Int {
		return _columns;
	}

	function set_columns(v:Int):Int {
		_columns = v;
		calcFramesMax();

		return _columns;
	}

	inline function calcFramesMax() {
		_framesMax = _columns * _rows;
	}


// import/export

	override function fromJson(d:Dynamic) {
		super.fromJson(d);

		speed = d.speed;
		loops = d.loops;
		rows = d.rows;
		columns = d.columns;
		setFrames(d.frames);

		return this;
	}

	override function toJson():Dynamic {
		var d = super.toJson();

		d.speed = speed;
		d.loops = loops;
		d.rows = rows;
		d.columns = columns;
		d.frames = _frames;

		return d;
	}

}

typedef AnimationModuleOptions = {

	>ParticleModuleOptions,
	
	?speed:Float,
	?loops:Int,
	?rows:Int,
	?columns:Int,
	?frames:Array<Int>

}
