package clay.particles.render.clay;


import clay.Entity;
import clay.components.graphics.Geometry;
import clay.components.graphics.QuadGeometry;
import clay.resources.Texture;
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

		layer = emitter.system.layer;

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
	
	override function onparticleshow(p:Particle) {

		geom.instances_count++;

	}

	override function onparticlehide(p:Particle) {

		geom.instances_count--;

	}

	override function update(dt:Float) {

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

		geom.depth = depth;

	}

	override function onlayer(l:Layer) {

		l.add(geom);

	}

}
