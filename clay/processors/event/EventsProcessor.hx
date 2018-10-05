package clay.processors.event;


import clay.components.event.Events;
import clay.Processor;
import clay.Family;



class EventsProcessor extends Processor {


	var e_family:Family<Events>;


	override function update(dt:Float) {

		var ev:Events = null;
		for (e in e_family) {
			ev = e_family.get_events(e);
			ev.process();
		}

	}


}
