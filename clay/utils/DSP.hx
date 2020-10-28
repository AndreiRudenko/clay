package clay.utils;

class DSP {

	static public inline function toSamples(ms:Float, sampleRate:Int):Int {
		return Math.floor(ms * 0.001 * sampleRate);
	}

	static public inline function toMs(samples:Int, sampleRate:Int):Float {
		return samples * 1000 / sampleRate;
	}

	static public inline function toMono(left:Float, right:Float):Float {
		return (left + right) / 2;
	}

}