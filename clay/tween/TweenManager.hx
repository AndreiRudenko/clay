package clay.tween;

import haxe.ds.ObjectMap;

import clay.tween.tweens.Tween;
import clay.tween.tweens.TweenFn;
import clay.tween.tweens.TweenObject;

@:allow(clay.tween.tweens.Tween)
@:access(clay.tween.tweens.Tween)
class TweenManager {

	var _activeTweens:Array<Tween<Dynamic>>;
	var _targets:ObjectMap<Dynamic, Array<Tween<Dynamic>>>;
	var _checkTime:Int;

	public function new() {
		_activeTweens = [];
		_targets = new ObjectMap();
		_checkTime = 0;
	}

	public function object<T>(target:T, manualUpdate:Bool = false):TweenObject<T> {
		return new TweenObject(this, target, manualUpdate);
	}

	public function fun<T>(target:T, manualUpdate:Bool = false):TweenFn<T> {
		return new TweenFn(this, target, manualUpdate);
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
		for (s in _activeTweens) {
			s.step(time);
		}

		_checkTime++;
		if(_checkTime > 60) {
			_checkTime = 0;
			var n = _activeTweens.length;
			while(n-- > 0) {
				if(!_activeTweens[n].active) {
					_activeTweens[n].drop();
					_activeTweens.splice(n, 1);
				}
			}
		}
	}

	function addTargetTween<T>(tween:Tween<T>, target:T) {
		var _targetTweens = _targets.get(target);
		if(_targetTweens == null) {
			_targetTweens = [];
			_targets.set(target, _targetTweens);
		}
		
		_targetTweens.push(tween);
	}

	function removeTargetTween<T>(tween:Tween<T>, target:T) {
		var targetTweens = _targets.get(target);

		if(targetTweens != null) {
			targetTweens.remove(tween);
			if(targetTweens.length == 0) {
				_targets.remove(target);
			}
		}
	}

	function addTween<T>(tween:Tween<T>) {
		_activeTweens.push(tween);
	}

}
