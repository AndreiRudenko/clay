package clay.tween;

import clay.tween.TweenSequence;
import clay.tween.tweens.NumTween;
import clay.tween.tweens.FuncTween;
import clay.tween.actions.CallAction;
import clay.tween.actions.EmptyAction;
import clay.tween.Tween;


@:allow(clay.tween.TweenSequence, clay.tween.Tween)
class TweenAction {


	public var complete(default, null):Bool;

	public var sequence(default, null):TweenSequence;
	public var tweens(default, null):Array<Tween>;

	var next:TweenAction;
	var prev:TweenAction;


	public function new(_sequence:TweenSequence) {

		sequence = _sequence;
		tweens = [];
		complete = false;

	}

	public function to(_props:Dynamic, _duration:Float):TweenAction {

		tweens.push(new NumTween(this, _props, _duration));

		return this;

	}

	public function fn(_fn:Dynamic, _duration:Float, _start:Array<Float> = null, _end:Array<Float> = null):TweenAction {

		tweens.push(new FuncTween(this, _fn, _duration, _start, _end));

		return this;
		
	}

	// public function method(_name:Dynamic, duration:Float, start:Array<Dynamic> = null, end:Array<Dynamic> = null):TweenAction {

	// 	var fn = Reflect.field(sequence.target, _name);
	// 	if(fn != null) {
	// 		tweens.push(new FuncTween(this, fn, duration, start, end));
	// 	} else {
	// 		trace('cant find $_name method, be sure to use @:keep for function');
	// 	}

	// 	return this;

	// }

	public function time_based(_v:Bool = true):TweenAction {
		
		sequence.time_based = _v;

		return this;

	}

	public function ease(_ease:EaseFunc):TweenAction {
		
		sequence.easing = _ease;

		return this;

	}

	public function wait(_duration:Float):TweenAction {

		var a = new TweenAction(sequence);
		a.tweens.push(new Tween(this, _duration));

		return sequence.add(a).then();

	}

	public function then():TweenAction {
		
		return sequence.add(new EmptyAction(sequence));

	}

	public function call(_fn:Void->Void):TweenAction {
		
		return sequence.add(new CallAction(sequence, _fn));

	}

	public function onupdate(_fn:Void->Void):TweenAction {

		sequence._onupdate = _fn;

		return this;

	}

	public function onrepeat(_fn:Void->Void):TweenAction {

		sequence._onrepeat = _fn;

		return this;

	}

	public function oncomplete(_fn:Void->Void):TweenAction {

		sequence._oncomplete = _fn;

		return this;

	}

	public function repeat(_times:Int = -1):TweenAction {

		sequence.repeat = _times;
		
		return this;

	}

	public function reflect():TweenAction {

		sequence.reflect = true;

		return this;

	}

	public function step(dt:Float) {

		complete = true;
		for (t in tweens) {
			t.step(dt);
			if(!t.complete) {
				complete = false;
			}
		}

	}

	function init() {}
	function onenter() {}
	function onreset() {}
	function onleave() {}

	function _init() {

		init();

		for (t in tweens) {
			t._init();
		}

	}

	function _enter() {
		
		onenter();

		for (t in tweens) {
			t._enter();
		}

	}

	function _leave() {
		
		for (t in tweens) {
			t.onleave();
		}

		onleave();

	}

	function _reset() {

		onreset();

		for (t in tweens) {
			t._reset();
		}
		
	}
	

}
