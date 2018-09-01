package clay.tween;

import haxe.ds.ObjectMap;
import clay.tween.TweenSequence;
import clay.tween.tweens.FuncTween;

class TweenManager {


	var sequences_tb:Array<TweenSequence>;
	var sequences_fb:Array<TweenSequence>;

	public var sequences(default, null):Array<TweenSequence>;


	var check_time:Int;


	public function new() {

		sequences = [];
		check_time = 0;

	}

	public function tween(target:Dynamic):TweenAction {

		var s = new TweenSequence(this, target);
		add_sequence(s);
		
		return s.create_action();
		
	}

	public function update(fn:Dynamic, duration:Float, start:Array<Float> = null, end:Array<Float> = null):TweenAction {
				
		var s = new TweenSequence(this, null);
		add_sequence(s);
		var a = s.create_action();
		a.tweens.push(new FuncTween(a, fn, duration, start, end));
		
		return a;
		
	}

	@:noCompletion public function tick(time:Float) {

		for (s in sequences) {
			if(s.time_based) {
				s.step(time);
			}
		}

	}

	@:noCompletion public function step(dt:Float) {

		for (s in sequences) {
			if(!s.time_based) {
				s.step(dt);
			}
		}

		check_time++;
		if(check_time > 60) {
			check_time = 0;
			var n = sequences.length;
			while(n-- > 0) {
				if(sequences[n].complete) {
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

	// function remove_sequence(_s:TweenSequence) {
		
	// }


}
