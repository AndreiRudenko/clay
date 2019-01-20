package processors;


import clay.Family;
import clay.components.graphics.Text;
import components.FPS;


class FPSProcessor extends clay.Processor {


	var fps_family:Family<FPS, Text>;

    var dt_average:Float = 0;
    var dt_average_accum:Float = 0;
    var dt_average_span:Int = 60;
    var dt_average_count:Int = 0;


	override function onrender() {

		dt_average_accum += Clay.engine.frame_delta;
		dt_average_count++;

		if(dt_average_count == dt_average_span - 1) {
			dt_average = dt_average_accum/dt_average_span;
			dt_average_accum = dt_average;
			dt_average_count = 0;
		}

	}

	override function update(dt:Float) {

		var t:Text;
		var fps:FPS;

		for (e in fps_family) {
			t = fps_family.get_text(e);
			fps = fps_family.get_fps(e);
			fps.value = Math.round(1/dt_average);
			t.text = 'FPS:${fps.value}';
		}

	}


}
