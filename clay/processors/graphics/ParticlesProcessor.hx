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

		_debug('pst_added $e');

		var ps = ps_family.get_particlesystem(e);

		if(ps.added) {
			log('Error geometry `${ps.name}` already added');
		} else {
			if(ps.layer == null) {
				if(Clay.renderer.layer != null) {
					Clay.renderer.layer._add_unsafe(ps);
				} else {
					log('Error adding particle system `${ps.name}` to Clay.renderer.layer');
				}
			} else {
				ps.layer._add_unsafe(ps);
			}
		}

	}
	
	function ps_removed(e:Entity) {

		_debug('pst_removed $e');
		var ps = ps_family.get_particlesystem(e);
		ps.stop(true);
		ps.drop();

	}

	function pst_added(e:Entity) {

		_debug('pst_added $e');

		var ps = pst_family.get_particlesystem(e);
		var t = pst_family.get_transform(e);
		ps.pos.copy_from(t.pos);

	}
	
	function pst_removed(e:Entity) {

		_debug('pst_removed $e');
		// var ps = pst_family.get_particlesystem(e);
		// var t = pst_family.get_transform(e);
		// ps.transform = new Transform(); // todo clone transform
		// ps.stop(true);

	}

	override function update(dt:Float) {

		var ps:ParticleSystem = null;
		var t:Transform = null;
		for (e in pst_family) {	
			ps = pst_family.get_particlesystem(e);
			t = pst_family.get_transform(e);
			ps.pos.copy_from(t.pos);
		}
		
		for (e in ps_family) {	
			ps = ps_family.get_particlesystem(e);
			ps.update(dt);
		}

	}


}
