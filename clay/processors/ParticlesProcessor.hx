package clay.processors;


import clay.ComponentMapper;
import clay.Processor;
import clay.Family;
// import clay.Wire;

import clay.components.Transform;
import clay.particles.ParticleSystem;

// import clay.render.Renderer;
import clay.utils.Log.*;

// using clay.render.utils.FastMatrix3Extender;


// @:access(clay.render.Renderer)
class ParticlesProcessor extends Processor {


	var ps_family:Family<ParticleSystem>;
	var pst_family:Family<ParticleSystem, Transform>;

	var ps_comps:ComponentMapper<ParticleSystem>;
	var transform_comps:ComponentMapper<Transform>;


	public function new() {

		clay.particles.ParticleSystem.renderer = new clay.particles.render.clay.ClayRenderer();
		clay.particles.utils.ModulesFactory.init();

		super();

	}

	override function onadded() {

		ps_family.listen(ps_added, ps_removed);
		pst_family.listen(pst_added, pst_removed);

	}

	override function onremoved() {
		
		ps_family.unlisten(ps_added, ps_removed);
		pst_family.unlisten(pst_added, pst_removed);

	}

	function ps_added(e:Entity) {

		_debug('ps_added');
		// var cam = ps_comps.get(e);

	}
	
	function ps_removed(e:Entity) {

		_debug('ps_removed');
		// var cam = ps_comps.get(e);

	}

	function pst_added(e:Entity) {

		_debug('pst_added $e');

		var ps = ps_comps.get(e);
		var t = transform_comps.get(e);
		ps.position.copy_from(t.pos);
		t.manual_update = true;

	}
	
	function pst_removed(e:Entity) {

		_debug('pst_removed $e');

		var t = transform_comps.get(e);
		t.manual_update = false;
	}


	override function update(dt:Float) {

		var ps:ParticleSystem = null;
		var t:Transform = null;
		for (e in pst_family) {	
			ps = ps_comps.get(e);
			t = transform_comps.get(e);
			t.pos.set(Clay.input.mouse.x, Clay.input.mouse.y);
			ps.position.copy_from(t.pos);
		}
		
		for (e in ps_family) {	
			ps = ps_comps.get(e);
			ps.update(dt);
		}

	}


}
