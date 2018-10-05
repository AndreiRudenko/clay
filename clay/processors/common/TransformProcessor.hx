package clay.processors.common;


import clay.components.common.Transform;
import clay.components.misc.Parent;
import clay.Processor;
import clay.Family;
import clay.Wire;



class TransformProcessor extends Processor {


	var tr_family:Family<Transform>;
	var trp_family:Family<Transform, Parent>;


	override function onadded() {

		trp_family.listen(trp_added, trp_removed);

	}

	override function onremoved() {
		
		trp_family.unlisten(trp_added, trp_removed);

	}

	override function update(dt:Float) {

		var t:Transform = null;
		for (e in tr_family) {
			t = tr_family.get_transform(e);
			t.update();
		}

	}

	function trp_added(e:Entity) {

		var p = trp_family.get_parent(e);
		var t = trp_family.get_transform(e);
		var t2 = trp_family.get_transform(p.entity);
		if(t2 != null) {
			t.parent = t2;
		}

	}
	
	function trp_removed(e:Entity) {

		var t = trp_family.get_transform(e);
		t.parent = null;

	}


}
