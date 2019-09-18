package clay.tween.tweens;


import haxe.macro.Expr;
import haxe.macro.Context;

import clay.tween.tweens.Tween;
import clay.tween.actions.TweenAction;
import clay.tween.actions.NumAction;
import clay.tween.actions.MultiNumAction;
import clay.tween.actions.CallAction;
import clay.tween.actions.FnAction;


@:access(clay.tween.actions.TweenAction)
class TweenFn<T> extends Tween<T> implements ITween {


	public function start(time:Float = 0):TweenFn<T> {

		begin(time);

		return this;

	}

	public macro function update<T>(self:Expr, duration:ExprOf<Float>, start:ExprOf<Array<Float>> = null, end:ExprOf<Array<Float>> = null, manualUpdate:Bool = false):ExprOf<TweenFn<T>> {

		return macro {
			
			$self._update(
				clay.tween.tweens.Tween.getFn(null, $start, $end),
				$duration,
				$start,
				$end
			);

		};

	}

	@:noCompletion 
	public function _update(fn:(t:T, a:Array<Float>)->Void, duration:Float, start:Array<Float> = null, end:Array<Float> = null):TweenFn<T> {

		addAction(new FnAction(this, fn, duration, start, end));

		return this;

	}

	public macro function set(self:Expr, values:Array<Expr>):ExprOf<TweenFn<T>> {

		return macro {

			$self.call(
				function(t){
					t($a{values});
				}
			);

		};

	}

	public function wait(duration:Float):TweenFn<T> {

		addAction(new TweenAction<T>(this, duration));

		return this;

	}

	public function call(fn:(t:T)->Void):TweenFn<T> {

		addAction(new CallAction(this, fn));

		return this;

	}

	public function label(name:String):TweenFn<T> {

		// addAction(new CallAction(this, fn));

		return this;

	}

	public function onStart(f:()->Void):TweenFn<T> {

		_onStart = f;

		return this;

	}

	public function onStop(f:()->Void):TweenFn<T> {

		_onStop = f;

		return this;

	}

	public function onPause(f:Void->Void):TweenFn<T> {

		_onPause = f;

		return this;

	}

	public function onResume(f:Void->Void):TweenFn<T> {

		_onResume = f;

		return this;

	}

	public function onUpdate(f:()->Void):TweenFn<T> {

		_onUpdate = f;

		return this;

	}

	public function onRepeat(f:()->Void):TweenFn<T> {

		_onRepeat = f;

		return this;

	}

	public function onComplete(f:()->Void):TweenFn<T> {

		_onComplete = f;

		return this;

	}

	public function repeat(times:Int = -1):TweenFn<T> {

		_repeat = times;
		
		return this;

	}

	public function reflect():TweenFn<T> {

		_reflect = true;
		
		return this;

	}

	public function then(tween:Tween<Dynamic>):TweenFn<T> {

		_nextTween = tween;

		return this;

	}

	public function ease(easing:EaseFunc):TweenFn<T> {

		_easing = easing;

		return this;

	}


}