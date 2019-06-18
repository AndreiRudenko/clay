package clay.render.renderers;


import kha.graphics4.ConstantLocation;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.arrays.Float32Array;


import clay.graphics.Mesh;
import clay.render.Camera;
import clay.resources.Texture;
import clay.utils.Log.*;
import clay.math.Rectangle;
import clay.math.Matrix;
import clay.math.Vector;


class StaticRenderer extends ObjectRenderer {


	var shader:Shader;
	var projection_loc:ConstantLocation;
	var texture_loc:TextureUnit;
	var g:Graphics;


	override function start() {
		
		shader = null;
		g = renderpath.g;

	}

	public function render(geom:Mesh) {

		if(geom.vertices.length == 0) {
			return;
		}

/*		if(geom.shader != shader) {
			shader = geom.shader;
			projection_loc = shader.getConstantLocation("mvpMatrix");
			texture_loc = shader.getTextureUnit("tex");

			renderpath.set_blendmode(shader);
			g.setPipeline(shader);
		}

		#if !no_debug_console
		renderpath.stats.vertices += geom.vertices.length;
		renderpath.stats.indices += geom.indices.length;
		renderpath.stats.locked++;
		#end

		renderpath.clip(geom.clip_rect);
		renderpath.set_projection(projection_loc);

		renderpath.set_texture(texture_loc, geom.texture);

		g.setVertexBuffer(geom.vertexbuffer);
		g.setIndexBuffer(geom.indexbuffer);

		g.drawIndexedVertices(0, geom.indices.length);

		renderpath.remove_texture(texture_loc);

		#if !no_debug_console
		renderpath.stats.draw_calls++;
		#end*/

	}


}