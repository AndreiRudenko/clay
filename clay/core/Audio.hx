package clay.core;

// import kha.Sound;
// import kha.audio2.Audio;
import kha.audio2.Buffer;
import kha.arrays.Float32Array;
import clay.resources.AudioResource;
import clay.audio.AudioEffect;
import clay.audio.AudioChannel;
import clay.audio.AudioGroup;
import clay.math.Mathf;
import clay.utils.Log.*;


class Audio extends AudioGroup {


	public var sample_rate(default, null): Int = 44100;

	var data: Float32Array;

    @:allow(clay.Engine)
	function new() {

		super();

		kha.audio2.Audio.audioCallback = mix;
		data = new Float32Array(512);

	}

	public function play(res:AudioResource):Sound {

		var sound = new Sound(res);
		sound.play();
		
		return sound;
		
	}

	public function stream(res:AudioResource):Sound {

		var sound = new Sound(res);
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

		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, Mathf.clamp(data[i], -1.0, 1.0) * volume);
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}

	}


}
