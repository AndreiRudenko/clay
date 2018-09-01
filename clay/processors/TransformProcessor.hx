package clay.processors;


import clay.components.Transform;
import clay.components.Parent;
import clay.ComponentMapper;
import clay.Processor;
import clay.Family;
import clay.Wire;



class TransformProcessor extends Processor {


	var tr_family:Family<Transform>;
	var trp_family:Family<Transform, Parent>;

	var transform_comps:ComponentMapper<Transform>;
	var parent_comps:ComponentMapper<Parent>;

	override function onadded() {

		trp_family.listen(trp_added, trp_removed);

	}

	override function onremoved() {
		
		trp_family.unlisten(trp_added, trp_removed);

	}

	override function update(dt:Float) {

		var t:Transform = null;
		for (e in tr_family) {
			t = transform_comps.get(e);
			t.update();
		}

	}

	function trp_added(e:Entity) {

		var p = parent_comps.get(e);
		var t = transform_comps.get(e);
		var t2 = transform_comps.get(p.entity);
		if(t2 != null) {
			t.parent = t2;
		}

	}
	
	function trp_removed(e:Entity) {

		var t = transform_comps.get(e);
		t.parent = null;

	}


}
