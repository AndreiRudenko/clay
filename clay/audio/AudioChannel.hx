package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;
import haxe.ds.Vector;
import clay.utils.Log.*;


class AudioChannel {

	static inline var max_effects:Int = 8;

	public var mute:Bool = false;

	public var volume         (default, set):Float;
	public var pan            (default, set):Float;
	public var output         (default, set):AudioGroup;

	public var effects        (default, null):Vector<AudioEffect>;
	public var effects_count  (default, null):Int;

	var _internal_effects:Vector<AudioEffect>;
	var _max_effects:Int;

	var l: Float;
	var r: Float;


	public function new(max_effects:Int = 8) {
		
		l = 1;
		r = 1;

		volume = 1;
		pan = 0;
		effects_count = 0;
		_max_effects = max_effects;

		effects = new Vector(_max_effects);
		_internal_effects = new Vector(_max_effects);

	}

	public function add_effect(effect:AudioEffect) {
		
		if(effects_count >= _max_effects) {
			log("cant add effect, max effects: " + _max_effects);
			return;
		}

		if(effect.parent != null) {
			log("audio effect already in another channel");
			return;
		}

		effect.parent = this;

		clay.system.Audio.mutex_lock();

		effects[effects_count++] = effect;

		clay.system.Audio.mutex_unlock();

	}

	public function remove_effect(effect:AudioEffect) {
		
		if(effect.parent == this) {
			effect.parent = null;

			clay.system.Audio.mutex_lock();

			for (i in 0...effects_count) {
				if(effects[i] == effect) { // todo: remove rest from effects_count and effect
					effects[i] = effects[--effects_count];
					break;
				}
			}

			clay.system.Audio.mutex_unlock();

		} else {
			log("cant remove effect from channel");
		}

	}

	public function remove_all_effect() {
		
		clay.system.Audio.mutex_lock();

		for (i in 0...effects_count) {
			effects[i] = null;
			_internal_effects[i] = null;
		}

		clay.system.Audio.mutex_unlock();

		effects_count = 0;

	}

	@:noCompletion public function process(data: Float32Array, samples: Int) {}


	inline function process_effects(data: Float32Array, samples: Int) {

		clay.system.Audio.mutex_lock();

		for (i in 0...effects_count) {
			_internal_effects[i] = effects[i];
		}

		clay.system.Audio.mutex_unlock();

		var e:AudioEffect;
		for (i in 0...effects_count) {
			e = _internal_effects[i];
			if(!e.mute) {
				e.process(samples, data, Clay.audio.sample_rate);
			}
		}
		
	}

	function set_volume(v: Float): Float {

		volume = Mathf.clamp(v, 0, 1);

		return volume;

	}

	function set_output(v: AudioGroup): AudioGroup {

		if(output != null) {
			output.remove(this);
		}

		output = v;

		if(output != null) {
			output.add(this);
		}

		return output;

	}

	function set_pan(v: Float): Float {

		pan = Mathf.clamp(v, -1, 1);
		var angle = pan * (Math.PI/4);

		l = Math.sqrt(2) / 2 * (Math.cos(angle) - Math.sin(angle));
		r = Math.sqrt(2) / 2 * (Math.cos(angle) + Math.sin(angle));

		return pan;

	}

}

