package clay.particles.render.clay;


import clay.Entity;
import clay.components.graphics.Geometry;
import clay.components.graphics.QuadGeometry;
import clay.components.graphics.Texture;
import clay.render.Vertex;
import clay.render.Layer;
import clay.particles.ParticleEmitter;
import clay.particles.core.ParticleData;
import clay.particles.core.Particle;
import clay.data.Color;
import clay.math.Vector;


class ClayEmitter extends EmitterRenderer {


	var geom:QuadGeometry;
	var layer:Layer;


	public function new(_renderer:ClayRenderer, _emitter:ParticleEmitter) {

		super(_emitter);

	}

	override function init() {

		layer = Clay.renderer.layers.get(emitter.layer);

		geom = new QuadGeometry({
			size : new Vector(1, 1)
		});

		geom.texture = Clay.resources.texture(emitter.image_path);
		geom.setup_instanced(emitter.cache_size);

		layer.add(geom);

		geom.instances_count = 0;

	}

	override function destroy() {

		layer.remove(geom);

		geom = null;
		layer = null;

	}

	override function onspritecreate(p:Particle):ParticleData {

		return new ParticleData();

	}

	override function onspriteshow(pd:ParticleData) {

		geom.instances_count++;

	}

	override function onspritehide(pd:ParticleData) {

		geom.instances_count--;

	}

	override function onupdate(dt:Float) {

		var i:Int = 0;
		var pd:ParticleData;
		var inst:InstancedGeometry;
		for (p in emitter.particles) {
			pd = emitter.particles_data[p.id];
			inst = geom.instances[i];
			inst.pos.set(pd.x, pd.y);
			inst.scale.set(pd.s, pd.s);
			inst.size.set(pd.w, pd.h);
			inst.rotation = pd.r;

			if(pd.centered) {
				inst.origin.set(pd.w*0.5, pd.h*0.5);
			} else {
				inst.origin.set(pd.ox, pd.oy);
			}

			inst.color.copy_from(pd.color);

			i++;
		}

	}

	override function ontexture(path:String) {

		geom.texture = Clay.resources.texture(emitter.image_path);

	}

	override function ondepth(depth:Float) {

		geom.order = Std.int(depth);

	}

	override function onlayerchanged(v:Int) {

		geom.layer = v;

	}

}
