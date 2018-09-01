package clay.render;


import clay.components.Geometry;
import clay.components.Camera;
import kha.graphics4.Graphics;


class Painter {


    var camera:Camera;


    public function new() {}

    public function destroy() {}
    public function prerender() {}
    public function postrender() {}

    public function onenter(l:Layer, g:Graphics, cam:Camera) {
        
        camera = cam;

    }

    public function onleave(l:Layer, g:Graphics) {}
    public function batch(g:Graphics, geom:Geometry) {}
    public function draw(g:Graphics) {}

    
}

@:enum abstract DrawState(UInt) from UInt to UInt {

    var none              = 0;
    var colored           = 1;
    var textured          = 2;

}
