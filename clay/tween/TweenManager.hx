package clay.tween;

import haxe.ds.ObjectMap;
import clay.tween.TweenSequence;
import clay.tween.tweens.FuncTween;

class TweenManager {

	/*
	
		sequence: node -> node -> node
		node: action -> action -> action
		action: [ tween, tween, tween ] // to(...), fn(...)

	 */


	public var targets(default, null):ObjectMap<Dynamic, Array<TweenNode>>;

	var sequences(default, null):Array<TweenSequence>;
	var check_time:Int;


	public function new() {

		sequences = [];

		targets = new ObjectMap();
		check_time = 0;

	}

	public function tween(target:Dynamic, manual_update:Bool = false):TweenAction {

		var s = new TweenSequence(this, manual_update);

		add_sequence(s);
		
		return s.add(new TweenNode(s, target)).create_action();
		
	}

	public function update(fn:Dynamic, duration:Float, start:Array<Float> = null, end:Array<Float> = null, manual_update:Bool = false):TweenAction {
				
		var s = new TweenSequence(this, manual_update);

		add_sequence(s);

		var n = s.add(new TweenNode(s, null));
		var a = n.create_action();
		a.tweens.push(new FuncTween(a, fn, duration, start, end));
		
		return a;
		
	}

	public function stop(target:Dynamic, _complete:Bool = false) {
		
		var nodes = targets.get(target);

		if(nodes != null) {
			for (n in nodes) {
				n.sequence.stop(_complete);
			}
		}

	}

	@:noCompletion public function step(dt:Float) {

		for (s in sequences) {
			if(!s.manual_update) { // todo: optimise?
				s.step(dt);
			}
		}

		check_time++;
		if(check_time > 60) {
			check_time = 0;
			var n = sequences.length;
			while(n-- > 0) {
				if(!sequences[n].active) {
					sequences[n].added = false;
					sequences.splice(n, 1);
				}
			}
		}

	}

	@:noCompletion public inline function add_sequence(s:TweenSequence) {

		s.added = true;
		sequences.push(s);

	}


}
