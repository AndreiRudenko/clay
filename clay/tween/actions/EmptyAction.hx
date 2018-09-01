package clay.tween.actions;


class EmptyAction extends TweenAction {


	override function onenter() {

		if(tweens.length == 0) {
			sequence.set_next_action();
		}

	}


}
