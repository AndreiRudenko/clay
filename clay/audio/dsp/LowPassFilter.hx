package clay.audio.dsp;


import clay.Clay;
import clay.utils.Mathf;


// First Order Digital LowPass Filter from FreeVerb3

class LowPassFilter {


	public var freq(default, set):Float;
	
	var y1:Float;
	var a2:Float;
	var b1:Float;
	var b2:Float;

	var sampleRate:Int;


	public function new(freq:Float, sampleRate:Int) {

		y1 = 0;
		a2 = 0;
		b1 = 0;
		b2 = 0;

		this.sampleRate = sampleRate;
		this.freq = freq;

	}

	public inline function process(input:Float):Float {

		var output = input * b1 + y1;
		y1 = output * a2 + input * b2;
			
		return output;

	}

	function set_freq(v:Float):Float {

		freq = Mathf.clampBottom(v, 0);
		
		a2 = Math.exp(-1 * Math.PI * freq / (sampleRate / 2));

		b1 = 1.0;
		b2 = 0.1;

		var norm = (1 - a2) / (b1 + b2);

		b1 *= norm;
		b2 *= norm;

		return freq;

	}


}


