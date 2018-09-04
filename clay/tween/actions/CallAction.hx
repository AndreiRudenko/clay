package clay.tween.actions;


class CallAction extends TweenAction {


	var call_fn:Void->Void;


	public function new(_node:TweenNode, _fn:Void->Void) {

		super(_node);

		call_fn = _fn;

	}

	override function onstart(t:Float) {

		call_fn();

	}


}
