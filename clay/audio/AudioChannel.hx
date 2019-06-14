package clay.audio;


import clay.math.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;
import clay.utils.ArrayTools;


class AudioChannel {


	public var mute: Bool = false;

	public var volume       (default, set): Float;
	public var pan          (default, set): Float;
	public var output       (default, set):AudioGroup;

	public var effects      (default, null):Array<AudioEffect>;

	var l: Float;
	var r: Float;


	function new() {
		
		l = 1;
		r = 1;

		volume = 1;
		pan = 0;

		effects = [];

	}

	public function add_effect(effect:AudioEffect) {
		
		if(effect.parent != null) {
			throw('audio effect already in another channel');
		}

		effect.parent = this;
		effects.push(effect);

	}

	public function remove_effect(effect:AudioEffect) {
		
		if(effect.parent == this) {
			effect.parent = null;
			effects.remove(effect);
		} else {
			trace('cant remove effect from channel');
		}

	}

	public function remove_all_effect() {
		
		for (e in effects) {
			e.parent = null;
		}

		ArrayTools.clear(effects);

	}

	@:noCompletion public function process(data: Float32Array, samples: Int) {}


	inline function process_effects(data: Float32Array, samples: Int) {

		for (e in effects) {
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
			output.childs.remove(this);
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

