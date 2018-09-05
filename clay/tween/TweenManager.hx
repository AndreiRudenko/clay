package clay.tween;

import haxe.ds.ObjectMap;
import clay.tween.TweenSequence;
import clay.tween.tweens.FuncTween;

class TweenManager {


	public var targets(default, null):ObjectMap<Dynamic, Array<TweenNode>>;

	var sequences_tb(default, null):Array<TweenSequence>;
	var sequences_fb(default, null):Array<TweenSequence>;

	var time_fb:Float;
	var check_time:Int;


	public function new() {

		sequences_tb = [];
		sequences_fb = [];

		targets = new ObjectMap();
		time_fb = 0;
		check_time = 0;

	}

	public function tween(target:Dynamic, time_based:Bool = false):TweenAction {

		var s = new TweenSequence(this, time_based);
		add_sequence(s);
		
		return s.add(new TweenNode(s, target)).create_action();
		
	}

	public function update(fn:Dynamic, duration:Float, start:Array<Float> = null, end:Array<Float> = null, time_based:Bool = false):TweenAction {
				
		var s = new TweenSequence(this, time_based);
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

	@:noCompletion public function tick() {

		for (s in sequences_tb) {
			s.step(Clay.time);
		}

	}

	@:noCompletion public function step(dt:Float) {

		time_fb += dt;

		for (s in sequences_fb) {
			s.step(time_fb);
		}

		check_time++;
		if(check_time > 60) {
			check_time = 0;
			var n = sequences_tb.length;
			while(n-- > 0) {
				if(!sequences_tb[n].active) {
					sequences_tb[n].added = false;
					sequences_tb.splice(n, 1);
				}
			}
			n = sequences_fb.length;
			while(n-- > 0) {
				if(!sequences_fb[n].active) {
					sequences_fb[n].added = false;
					sequences_fb.splice(n, 1);
				}
			}
		}

	}

	@:noCompletion public inline function add_sequence(s:TweenSequence) {

		s.added = true;
		if(s.time_based) {
			s.next_time = Clay.time;
			sequences_tb.push(s);
		} else {
			s.next_time = time_fb;
			sequences_fb.push(s);
		}

	}

	// function remove_sequence(_s:TweenSequence) {
		
	// }


}
