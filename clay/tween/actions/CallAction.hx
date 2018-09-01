package clay.tween.actions;


class CallAction extends EmptyAction {


	var call_fn:Void->Void;


	public function new(_sequence:TweenSequence, _fn:Void->Void) {

		super(_sequence);

		call_fn = _fn;

	}

	override function onenter() {

		call_fn();
		super.onenter();

	}


}
