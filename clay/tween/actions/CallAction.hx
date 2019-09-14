package clay.tween.actions;


import clay.tween.tweens.Tween;


@:access(clay.tween.tweens.Tween)
class CallAction<T> extends TweenAction<T> {


	var callFn:(t:T)->Void;


	public function new(tween:Tween<T>, fn:(t:T)->Void) {

		super(tween, 0);

		callFn = fn;

	}

	override function start(t:Float) {

		callFn(_tween.target);
		complete = true;

	}


}
