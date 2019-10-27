package clay.utils;


class DSP {


	public static inline function toSamples(ms:Float, sampleRate:Int):Int {
	    
		return Math.floor(ms * 0.001 * sampleRate);

	}

	public static inline function toMs(samples:Int, sampleRate:Int):Float {
	    
		return samples * 1000 / sampleRate;

	}
	

}