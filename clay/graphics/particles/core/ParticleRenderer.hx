package clay.graphics.particles.core;


import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;

import clay.graphics.particles.core.Particle;
import clay.graphics.particles.core.ParticleVector;
import clay.graphics.particles.ParticleEmitter;
import clay.graphics.particles.ParticleSystem;

import clay.graphics.particles.core.Particle;
import clay.render.Camera;
import clay.render.RenderPath;
import clay.render.types.BlendMode;
import clay.render.types.BlendEquation;
import clay.resources.Texture;
import clay.utils.ArrayTools;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.math.Vector;
import clay.utils.Mathf;


class ParticleRenderer extends ObjectRenderer {


        /** if the module is in a emitter, this is not null */
	@:noCompletion public var emitter:ParticleEmitter;
        /** reference to emitter particles */
	var particles:ParticleVector;

	var region_scaled:Rectangle;


	public function new() {

		super(Clay.renderer.renderpath);

	}

	public function render(r:RenderPath, c:Camera) {

		// r.g

	}
	
	function set_blendmode(sh:Shader) {

		if(blend_src != BlendMode.Undefined && blend_dst != BlendMode.Undefined) {
			sh.blendSource = blend_src;
			sh.alphaBlendDestination = blend_dst;
			sh.alphaBlendSource = blend_src;
			sh.blendDestination = blend_dst;
			sh.blendOperation = blend_eq;
		} else if(renderpath.layer.blend_src != BlendMode.Undefined && renderpath.layer.blend_dst != BlendMode.Undefined) {
			var layer = renderpath.layer;
			sh.blendSource = layer.blend_src;
			sh.alphaBlendDestination = layer.blend_dst;
			sh.alphaBlendSource = layer.blend_src;
			sh.blendDestination = layer.blend_dst;
			sh.blendOperation = layer.blend_eq;
		} else { // set default blend modes
			sh.reset_blendmodes();
		}

	}

	inline function set_region(region:Rectangle, texture:Texture) {
		
		if(region == null || texture == null) {
			region_scaled.set(0, 0, 1, 1);
		} else {
			region_scaled.set(
				region_scaled.x = region.x / texture.width_actual,
				region_scaled.y = region.y / texture.height_actual,
				region_scaled.w = region.w / texture.width_actual,
				region_scaled.h = region.h / texture.height_actual
			);
		}

	}


}
