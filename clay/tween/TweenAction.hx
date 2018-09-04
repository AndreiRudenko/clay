package clay.tween;

import clay.tween.TweenNode;
import clay.tween.TweenSequence;
import clay.tween.tweens.NumTween;
import clay.tween.tweens.FuncTween;
import clay.tween.actions.CallAction;
import clay.tween.Tween;


@:allow(
	clay.tween.TweenSequence, 
	clay.tween.Tween, 
	clay.tween.TweenNode, 
	clay.tween.TweenManager
)
class TweenAction {


	public var sequence(get, never):TweenSequence;
	public var node(default, null):TweenNode;
	public var complete(default, null):Bool;

	public var tweens(default, null):Array<Tween>;

	var next:TweenAction;
	var prev:TweenAction;


	public function new(_node:TweenNode) {

		node = _node;
		tweens = [];
		complete = false;

	}

	public function tween(t:Dynamic):TweenAction {

		return sequence.add(new TweenNode(sequence, t)).create_action();

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

	// 	var fn = Reflect.field(node.target, _name);
	// 	if(fn != null) {
	// 		tweens.push(new FuncTween(this, fn, duration, start, end));
	// 	} else {
	// 		trace('cant find $_name method, be sure to use @:keep for function');
	// 	}

	// 	return this;

	// }

	public function ease(_ease:EaseFunc):TweenAction {
		
		node.easing = _ease;

		return this;

	}

	public function wait(_duration:Float):TweenAction {

		var a = new TweenAction(node);
		a.tweens.push(new Tween(this, _duration));

		return node.add(a).then();

	}

	public function then():TweenAction {
		
		return node.add(new TweenAction(node));

	}

	public function call(_fn:Void->Void):TweenAction {
		
		return node.add(new CallAction(node, _fn));

	}

	public function onupdate(_fn:Void->Void):TweenAction {

		node._onupdate = _fn;

		return this;

	}

	public function onrepeat(_fn:Void->Void):TweenAction {

		node._onrepeat = _fn;

		return this;

	}

	public function oncomplete(_fn:Void->Void):TweenAction {

		node._oncomplete = _fn;

		return this;

	}

	public function repeat(_times:Int = -1):TweenAction {

		node._repeat = _times;
		
		return this;

	}

	public function reflect():TweenAction {

		node._reflect = true;

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


	function onstart(t:Float) {}
	function onfinish() {}
	function onreset() {}

	function _start(t:Float) {

		onstart(t);

		if(tweens.length > 0) {
			for (tw in tweens) {
				tw._start(t);
			}
		} else {
			node.next_action();
		}

	}

	function _finish() {

		onfinish();

	}

	function _reset() {

		onreset();

		for (t in tweens) {
			t._reset();
		}
		
	}

	inline function get_sequence():TweenSequence {
		
		return node.sequence;

	}
	

}
