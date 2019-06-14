package clay.tween;


import haxe.ds.ObjectMap;

import clay.tween.tweens.Tween;
import clay.tween.tweens.TweenFn;
import clay.tween.tweens.TweenObject;


@:allow(clay.tween.tweens.Tween)
@:access(clay.tween.tweens.Tween)
class TweenManager {


	var _active_tweens:Array<Tween<Dynamic>>;
	var _targets:ObjectMap<Dynamic, Array<Tween<Dynamic>>>;
	var _check_time:Int;


	public function new() {

		_active_tweens = [];
		_targets = new ObjectMap();
		_check_time = 0;

	}

	public function object<T>(target:T, manual_update:Bool = false):TweenObject<T> {

		return new TweenObject(this, target, manual_update);
		
	}

	public function fun<T>(target:T, manual_update:Bool = false):TweenFn<T> {

		return new TweenFn(this, target, manual_update);

	}

	public function stop(target:Dynamic) {
		
		var tweens = _targets.get(target);

		if(tweens != null) {
			for (t in tweens) {
				t.stop();
			}
		}

	}

	public function step(time:Float) {

		for (s in _active_tweens) {
			s.step(time);
		}

		_check_time++;
		if(_check_time > 60) {
			_check_time = 0;
			var n = _active_tweens.length;
			while(n-- > 0) {
				if(!_active_tweens[n].active) {
					_active_tweens[n].drop();
					_active_tweens.splice(n, 1);
				}
			}
		}

	}

	function add_target_tween<T>(tween:Tween<T>, target:T) {

		var _target_tweens = _targets.get(target);
		if(_target_tweens == null) {
			_target_tweens = [];
			_targets.set(target, _target_tweens);
		}
		
		_target_tweens.push(tween);

	}

	function remove_target_tween<T>(tween:Tween<T>, target:T) {

		var target_tweens = _targets.get(target);

		if(target_tweens != null) {
			target_tweens.remove(tween);
			if(target_tweens.length == 0) {
				_targets.remove(target);
			}
		}

	}

	function add_tween<T>(tween:Tween<T>) {

		_active_tweens.push(tween);

	}


}
