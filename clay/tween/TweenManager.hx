package clay.tween;

import haxe.ds.ObjectMap;
import clay.tween.TweenSequence;
import clay.tween.tweens.FuncTween;

class TweenManager {


	public var sequences(default, null):Array<TweenSequence>;

	var to_start:Array<TweenSequence>;

	var time_fb:Float;
	var check_time:Int;


	public function new() {

		sequences = [];
		to_start = [];
		time_fb = 0;
		check_time = 0;

	}

	public function tween(target:Dynamic, time_based:Bool = false):TweenAction {

		var s = new TweenSequence(this, time_based);
		s.next_time = time_based ? Clay.time : time_fb;
		add_sequence(s);
		
		return s.add(new TweenNode(s, target)).create_action();
		
	}

	public function update(fn:Dynamic, duration:Float, start:Array<Float> = null, end:Array<Float> = null, time_based:Bool = false):TweenAction {
				
		var s = new TweenSequence(this, time_based);
		s.next_time = time_based ? Clay.time : time_fb;
		add_sequence(s);
		var n = s.add(new TweenNode(s, null));
		var a = n.create_action();
		a.tweens.push(new FuncTween(a, fn, duration, start, end));
		
		return a;
		
	}

	@:noCompletion public function tick() {

		for (s in sequences) {
			if(s.time_based) {
				s.step(Clay.time);
			}
		}

	}

	@:noCompletion public function step(dt:Float) {

		time_fb += dt;

		for (s in sequences) {
			if(!s.time_based) {
				s.step(time_fb);
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
		to_start.push(s);

	}

	// function remove_sequence(_s:TweenSequence) {
		
	// }


}
