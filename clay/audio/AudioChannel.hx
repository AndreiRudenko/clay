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

	public var mute:Bool = false;

	public var volume(default, set):Float;
	public var pan(default, set):Float;
	public var output(default, set):AudioGroup;

	public var effects(default, null):Vector<AudioEffect>;
	public var effectsCount(default, null):Int;

	var _internalEffects:Vector<AudioEffect>;
	var _maxEffects:Int;

	var l:Float;
	var r:Float;


	public function new(maxEffects:Int = 8) {
		
		l = 1;
		r = 1;

		volume = 1;
		pan = 0;
		effectsCount = 0;
		_maxEffects = maxEffects;

		effects = new Vector(_maxEffects);
		_internalEffects = new Vector(_maxEffects);

	}

	public function addEffect(effect:AudioEffect) {
		
		if(effectsCount >= _maxEffects) {
			log("cant add effect, max effects: " + _maxEffects);
			return;
		}

		if(effect.parent != null) {
			log("audio effect already in another channel");
			return;
		}

		effect.parent = this;

		clay.system.Audio.mutexLock();

		effects[effectsCount++] = effect;

		clay.system.Audio.mutexUnlock();

	}

	public function removeEffect(effect:AudioEffect) {
		
		if(effect.parent == this) {
			effect.parent = null;

			clay.system.Audio.mutexLock();

			for (i in 0...effectsCount) {
				if(effects[i] == effect) { // todo: remove rest from effectsCount and effect
					effects[i] = effects[--effectsCount];
					break;
				}
			}

			clay.system.Audio.mutexUnlock();

		} else {
			log("cant remove effect from channel");
		}

	}

	public function removeAllEffects() {
		
		clay.system.Audio.mutexLock();

		for (i in 0...effectsCount) {
			effects[i] = null;
			_internalEffects[i] = null;
		}

		clay.system.Audio.mutexUnlock();

		effectsCount = 0;

	}

	@:noCompletion public function process(data:Float32Array, samples:Int) {}


	inline function processEffects(data:Float32Array, samples:Int) {

		clay.system.Audio.mutexLock();

		for (i in 0...effectsCount) {
			_internalEffects[i] = effects[i];
		}

		clay.system.Audio.mutexUnlock();

		var e:AudioEffect;
		for (i in 0...effectsCount) {
			e = _internalEffects[i];
			if(!e.mute) {
				e.process(samples, data, Clay.audio.sampleRate);
			}
		}
		
	}

	function set_volume(v:Float):Float {

		volume = Mathf.clamp(v, 0, 1);

		return volume;

	}

	function set_output(v:AudioGroup):AudioGroup {

		if(output != null) {
			output.remove(this);
		}

		output = v;

		if(output != null) {
			output.add(this);
		}

		return output;

	}

	function set_pan(v:Float):Float {

		pan = Mathf.clamp(v, -1, 1);
		var angle = pan * (Math.PI/4);

		l = Math.sqrt(2) / 2 * (Math.cos(angle) - Math.sin(angle));
		r = Math.sqrt(2) / 2 * (Math.cos(angle) + Math.sin(angle));

		return pan;

	}

}

