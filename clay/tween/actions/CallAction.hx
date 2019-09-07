package clay.tween.actions;


import clay.tween.tweens.Tween;


@:access(clay.tween.tweens.Tween)
class CallAction<T> extends TweenAction<T> {


	var call_fn:T->Void;


	public function new(tween:Tween<T>, fn:T->Void) {

		super(tween, 0);

		call_fn = fn;

	}

	override function start(t:Float) {

		call_fn(_tween.target);
		complete = true;

	}


}
