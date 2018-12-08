package clay.processors.graphics;


import clay.Processor;
import clay.Family;

import clay.components.common.Transform;
import clay.particles.ParticleSystem;

import clay.utils.Log.*;


class ParticlesProcessor extends Processor {


	var ps_family:Family<ParticleSystem>;
	var pst_family:Family<ParticleSystem, Transform>;


	public function new() {

		clay.particles.ParticleSystem.renderer = new clay.particles.render.clay.ClayRenderer();
		clay.particles.utils.ModulesFactory.init();

		super();

	}

	override function onadded() {

		pst_family.listen(pst_added, pst_removed);

	}

	override function onremoved() {
		
		pst_family.unlisten(pst_added, pst_removed);

	}

	function pst_added(e:Entity) {

		_debug('pst_added $e');

		var ps = pst_family.get_particleSystem(e);
		var t = pst_family.get_transform(e);
		ps.pos.copy_from(t.pos);

	}
	
	function pst_removed(e:Entity) {

		_debug('pst_removed $e');
		var ps = pst_family.get_particleSystem(e);
		ps.stop(true);

	}

	override function update(dt:Float) {

		var ps:ParticleSystem = null;
		var t:Transform = null;
		for (e in pst_family) {	
			ps = pst_family.get_particleSystem(e);
			t = pst_family.get_transform(e);
			ps.pos.copy_from(t.pos);
		}
		
		for (e in ps_family) {	
			ps = ps_family.get_particleSystem(e);
			ps.update(dt);
		}

	}


}
