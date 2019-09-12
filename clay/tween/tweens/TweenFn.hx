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

	public macro function update<T>(self:Expr, duration:ExprOf<Float>, start:ExprOf<Array<Float>> = null, end:ExprOf<Array<Float>> = null, manual_update:Bool = false):ExprOf<TweenFn<T>> {

		return macro {
			
			$self._update(
				clay.tween.tweens.Tween.get_fn(null, $start, $end),
				$duration,
				$start,
				$end
			);

		};

	}

	@:noCompletion 
	public function _update(fn:(t:T, a:Array<Float>)->Void, duration:Float, start:Array<Float> = null, end:Array<Float> = null):TweenFn<T> {

		add_action(new FnAction(this, fn, duration, start, end));

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

		add_action(new TweenAction<T>(this, duration));

		return this;

	}

	public function call(fn:(t:T)->Void):TweenFn<T> {

		add_action(new CallAction(this, fn));

		return this;

	}

	public function label(name:String):TweenFn<T> {

		// add_action(new CallAction(this, fn));

		return this;

	}

	public function onstart(f:()->Void):TweenFn<T> {

		_onstart = f;

		return this;

	}

	public function onstop(f:()->Void):TweenFn<T> {

		_onstop = f;

		return this;

	}

	public function onupdate(f:()->Void):TweenFn<T> {

		_onupdate = f;

		return this;

	}

	public function onrepeat(f:()->Void):TweenFn<T> {

		_onrepeat = f;

		return this;

	}

	public function oncomplete(f:()->Void):TweenFn<T> {

		_oncomplete = f;

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

		_next_tween = tween;

		return this;

	}

	public function ease(easing:EaseFunc):TweenFn<T> {

		_easing = easing;

		return this;

	}


}