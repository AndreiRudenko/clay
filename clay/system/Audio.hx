package clay.system;

#if cpp
import cpp.vm.Mutex;
#end

// import kha.Sound;
// import kha.audio2.Audio;
import kha.audio2.Buffer;
import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.audio.AudioEffect;
import clay.audio.AudioChannel;
import clay.audio.AudioGroup;
import clay.audio.Sound;
import clay.utils.Mathf;
import clay.utils.Log.*;


class Audio extends AudioGroup {

	#if cpp
	public static var mutex:Mutex = new Mutex();
	#end

	public var sample_rate(default, null): Int = 44100;
	public var gain: Float;

	var data: Float32Array;

    @:allow(clay.system.App)
	function new() {

		super();
		
		kha.audio2.Audio.audioCallback = mix;
		data = new Float32Array(512);
		gain = 0;

	}

	public function play(res:AudioResource, output:AudioGroup = null):Sound {

		var sound = new Sound(res, output);
		sound.play();
		
		return sound;
		
	}

	public function stream(res:AudioResource, output:AudioGroup = null):Sound {

		var sound = new Sound(res, output);
		sound.stream = true;
		sound.play();

		return sound;
		
	}

	function mix(samples: Int, buffer: Buffer) {
		
		sample_rate = buffer.samplesPerSecond;

		if (data.length < samples) {
			data = new Float32Array(samples);
		}

		for (i in 0...samples) {
			data[i] = 0;
		}

		process(data, samples);

		gain = 0;
		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, Mathf.clamp(data[i], -1.0, 1.0) * volume);
			if(gain < data[i]) {
				gain = data[i];
			}
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}

	}


}
