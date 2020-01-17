package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;
import haxe.ds.Vector;
import clay.utils.Log.*;


class AudioChannel {

	static inline var maxEffects:Int = 8;

	public var mute(get, set):Bool;
	public var volume(get, set):Float;
	public var pan(get, set):Float;
	public var output(get, null):AudioGroup;

	public var effects(get, null):Array<AudioEffect>;
	public var effectsCount(get, null):Int;

	var _mute:Bool;
	var _volume:Float;
	var _pan:Float;
	var _output:AudioGroup;

	var _l:Float;
	var _r:Float;

	var _effectsCount:Int;
	var _maxEffects:Int;
	var _dirtyEffects:Bool;

	var _effects:Vector<AudioEffect>;
	var _effectsInternal:Vector<AudioEffect>;


	public function new(maxEffects:Int = 8) {
		
		_mute = false;
		_volume = 1;
		_pan = 0;

		_l = 0.7071;
		_r = 0.7071;

		_effectsCount = 0;
		_maxEffects = maxEffects;
		_dirtyEffects = true;

		_effects = new Vector(_maxEffects);
		_effectsInternal = new Vector(_maxEffects);

	}

	public function addEffect(effect:AudioEffect) {
		
		clay.system.Audio.mutexLock();

		if(_effectsCount >= _maxEffects) {
			log("cant add effect, max effects: " + _maxEffects);
			return;
		}

		if(effect._parent != null) {
			log("audio effect already in another channel");
			return;
		}

		effect._parent = this;
		_effects[_effectsCount++] = effect;
		_dirtyEffects = true;

		clay.system.Audio.mutexUnlock();

	}

	public function removeEffect(effect:AudioEffect) {

		clay.system.Audio.mutexLock();

		for (i in 0..._effectsCount) {
			if(_effects[i] == effect) { // todo: remove rest from _effectsCount and effect
				_effects[i] = _effects[--_effectsCount];
				break;
			}
		}
		_dirtyEffects = true;

		clay.system.Audio.mutexUnlock();

	}

	public function removeAllEffects() {

		clay.system.Audio.mutexLock();

		_effectsCount = 0;
		_dirtyEffects = true;

		clay.system.Audio.mutexUnlock();

	}

	@:noCompletion public function updateProps() {}
	@:noCompletion public function process(data:Float32Array, samples:Int) {}

	inline function processEffects(data:Float32Array, samples:Int) {

		clay.system.Audio.mutexLock();

		if(_dirtyEffects) {
			var j:Int = 0;
			while (j < _effectsCount) {
				_effectsInternal[j] = _effects[j];
				j++;
			}
			_dirtyEffects = false;
		}
		var count = _effectsCount;

		clay.system.Audio.mutexUnlock();

		var i:Int = 0;
		var e:AudioEffect;
		while (i < count) {
			e = _effectsInternal[i];
			if(!e._mute) {
				e.process(samples, data, Clay.audio._sampleRate);
			}
			i++;
		}
		
	}

	function get_mute():Bool {

		clay.system.Audio.mutexLock();
		var v = _mute;
		clay.system.Audio.mutexUnlock();

		return v;
		
	}

	function set_mute(v:Bool):Bool {

		clay.system.Audio.mutexLock();
		_mute = v;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_volume():Float {

		clay.system.Audio.mutexLock();
		var v = _volume;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_volume(v:Float):Float {

		clay.system.Audio.mutexLock();
		_volume = Mathf.clamp(v, 0, 1);
		v = _volume;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_pan():Float {

		clay.system.Audio.mutexLock();
		var v = _pan;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function set_pan(v:Float):Float {

		clay.system.Audio.mutexLock();

		_pan = Mathf.clamp(v, -1, 1);
		_l = Math.cos((_pan + 1) * Math.PI / 4);
		_r = Math.sin((_pan + 1) * Math.PI / 4);
		v = _pan;

		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_output():AudioGroup {

		clay.system.Audio.mutexLock();
		var v = _output;
		clay.system.Audio.mutexUnlock();

		return v;

	}

	function get_effects():Array<AudioEffect> {

		clay.system.Audio.mutexLock();
		var v = [];
		for (i in 0..._effectsCount) {
			v.push(_effects[i]);
		}
		clay.system.Audio.mutexUnlock();

		return v;
		
	}

	function get_effectsCount():Int {

		clay.system.Audio.mutexLock();
		var v = _effectsCount;
		clay.system.Audio.mutexUnlock();

		return v;
		
	}


}

