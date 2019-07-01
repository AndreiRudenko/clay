package clay.audio;


import clay.utils.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;
import haxe.ds.Vector;


class AudioChannel {

	static inline var max_effects:Int = 8;

	public var mute: Bool = false;

	public var volume       (default, set): Float;
	public var pan          (default, set): Float;
	public var output       (default, set):AudioGroup;

	public var effects      (default, null):Vector<AudioEffect>;

	var _internal_effects:Vector<AudioEffect>;
	var _effects_count:Int;

	var l: Float;
	var r: Float;


	function new() {
		
		l = 1;
		r = 1;

		volume = 1;
		pan = 0;
		_effects_count = 0;

		effects = new Vector(max_effects);
		_internal_effects = new Vector(max_effects);

	}

	public function add_effect(effect:AudioEffect) {
		
		if(effect.parent != null) {
			throw('audio effect already in another channel');
		}

		effect.parent = this;

		#if cpp
		clay.system.Audio.mutex.acquire();
		#end

		effects[_effects_count++] = effect;

		#if cpp
		clay.system.Audio.mutex.release();
		#end

	}

	public function remove_effect(effect:AudioEffect) {
		
		if(effect.parent == this) {
			effect.parent = null;

			#if cpp
			clay.system.Audio.mutex.acquire();
			#end

			for (i in 0..._effects_count) {
				if(effects[i] == effect) { // todo: remove rest from _effects_count and effect
					effects[i] = effects[--_effects_count];
					break;
				}
			}

			#if cpp
			clay.system.Audio.mutex.release();
			#end

		} else {
			trace('cant remove effect from channel');
		}

	}

	public function remove_all_effect() {
		
		#if cpp
		clay.system.Audio.mutex.acquire();
		#end

		for (i in 0..._effects_count) {
			effects[i] = null;
			_internal_effects[i] = null;
		}

		#if cpp
		clay.system.Audio.mutex.release();
		#end

		_effects_count = 0;

	}

	@:noCompletion public function process(data: Float32Array, samples: Int) {}


	inline function process_effects(data: Float32Array, samples: Int) {

		#if cpp
		clay.system.Audio.mutex.acquire();
		#end

		for (i in 0..._effects_count) {
			_internal_effects[i] = effects[i];
		}

		#if cpp
		clay.system.Audio.mutex.release();
		#end

		var e:AudioEffect;
		for (i in 0..._effects_count) {
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

