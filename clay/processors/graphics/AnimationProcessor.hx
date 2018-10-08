package clay.processors.graphics;


import clay.Processor;
import clay.Family;

import clay.components.event.Events;
import clay.components.graphics.Geometry;
import clay.components.graphics.QuadGeometry;
import clay.components.graphics.Animation;

import clay.utils.Log.*;


class AnimationProcessor extends Processor {


	var aq_family:Family<Animation, QuadGeometry>;
	var ae_family:Family<Animation, Events>;


	override function onadded() {

		aq_family.listen(a_added, a_removed);
		ae_family.listen(ae_added, ae_removed);

	}

	override function onremoved() {
		
		aq_family.unlisten(a_added, a_removed);
		ae_family.unlisten(ae_added, ae_removed);

	}

	function a_added(e:Entity) {

		var a = aq_family.get_animation(e);
		a.geometry = aq_family.get_quadGeometry(e);
		a.init();

	}
	
	function a_removed(e:Entity) {

		var a = aq_family.get_animation(e);
		a.stop();
		a.geometry = null;

	}

	function ae_added(e:Entity) {

		var a = ae_family.get_animation(e);
		var ev = ae_family.get_events(e);
		a.events = ev;

	}
	
	function ae_removed(e:Entity) {

		var a = ae_family.get_animation(e);
		a.events = null;

	}

	override function update(dt:Float) {

		var a:Animation = null;
		var q:QuadGeometry = null;
		for (e in aq_family) {	
			
			a = aq_family.get_animation(e);
			q = aq_family.get_quadGeometry(e);

			if(!a.active || a.paused || a.current == null) {
				continue;
			}

			var end = false;
			var _frame = a.frame;

			a.time += dt * a.speedscale;

			if(a.time >= a.next_frame_time) {
				a.next_frame_time = a.time + a.current.frame_time;

				if(!a.reverse) {
					_frame += 1;
					if(_frame >= a.current.frames_count) {
						end = true;
					}
				} else {
					_frame -= 1;
					if(_frame < 0) {
						end = true;
					}
				}

				if(end) {
					if(a.current._loop != 0) {
						if(a.current._loop > 0) {
							a.current._loop--;
						}
						_frame = 0;
						if(a.events != null) {
							a.current.emit_event('loop');
						}
					} else {
						a.stop();
						if(a.events != null) {
							a.current.emit_event('end');
						}
						_frame = a.frame;
					}
				}
				a.frame = _frame;

			}

		}

	}


}
