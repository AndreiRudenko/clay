package clay.tween.actions;


import clay.tween.tweens.Tween;


@:access(clay.tween.tweens.Tween)
class NumAction<T> extends TweenAction<T> {


	var _get_prop:(t:T)->Float;
	var _set_prop:(t:T, v:Float)->Void;

	var _from:Float;
	var _difference:Float;
	var _to:Float;

	var _reverse:Bool;


	public function new(tween:Tween<T>, get_prop:(t:T)->Float, set_prop:(t:T, v:Float)->Void, value:Float, duration:Float, reverse:Bool) {

		super(tween, duration);

		_tween = tween;

		_get_prop = get_prop;
		_set_prop = set_prop;
		_to = value;
		_reverse = reverse;

	}

	override function init() {

		if(_reverse) {
			_from = _to;
			_to = _get_prop(_tween.target);
		} else {
			_from = _get_prop(_tween.target);
		}

		_difference = _to - _from;

	}

	override function apply(t:Float) {
		
		var v = _from + _difference * t;

		_set_prop(_tween.target, v);

	}

}
