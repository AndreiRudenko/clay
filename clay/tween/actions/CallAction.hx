package clay.tween.actions;


import clay.tween.tweens.Tween;


@:access(clay.tween.tweens.Tween)
class CallAction<T> extends TweenAction<T> {


	var _callFn:(t:T)->Void;


	public function new(tween:Tween<T>, fn:(t:T)->Void) {

		super(tween, 0);

		_callFn = fn;

	}

	override function start(t:Float) {

		_callFn(_tween.target);
		complete = true;

	}


}
