package clay.audio;


import clay.math.Mathf;
import clay.utils.Log.*;
import kha.arrays.Float32Array;
import clay.audio.AudioEffect;


class AudioChannel {


	public var mute: Bool = false;

	public var volume       (default, set): Float;
	public var pan          (default, set): Float;
	public var output       (default, set):AudioChannel;

	public var effects      (default, null):Array<AudioEffect>;

	@:noCompletion public var prev: AudioChannel;
	@:noCompletion public var next: AudioChannel;

	@:noCompletion public var childs: AudioChannelList;

	var l: Float;
	var r: Float;


	function new() {
		
		l = 1;
		r = 1;

		volume = 1;
		pan = 0;

		effects = [];

		childs = new AudioChannelList();

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

	function set_output(v: AudioChannel): AudioChannel {

		if(output != null) {
			output.childs.remove(this);
		}

		output = v;

		if(output != null) {
			output.childs.add(this);
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

private class AudioChannelList {


	public var head (default, null): AudioChannel;
	public var tail (default, null): AudioChannel;
	public var length(default, null): Int = 0;


	public function new(){}

	public function add(s: AudioChannel) {

		if (tail != null) {
			tail.next = s;
			s.prev = tail;
		} else{
			head = s;
		}

		tail = s;
		
		length++;

	}

	public function remove(s: AudioChannel) {

		if (s == head){
			head = head.next;
			
			if (head == null) {
				tail = null;
			}
		} else if (s == tail) {
			tail = tail.prev;
				
			if (tail == null) {
				head = null;
			}
		}

		if (s.prev != null) {
			s.prev.next = s.next;
		}

		if (s.next != null) {
			s.next.prev = s.prev;
		}

		s.next = s.prev = null;

		length--;

	}

	public function clear(): Void {

		var p:AudioChannel = null;
		while (head != null) {
			p = head;
			head = head.next;
			p.prev = null;
			p.next = null;
		}

		tail = null;
		
		length = 0;

	}

}
