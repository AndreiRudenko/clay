package clay.render;


import clay.math.Vector;
import clay.data.Color;


class Vertex {


    public var pos:Vector;
    public var tcoord:Vector;
    public var color:Color;


    public function new(?_pos:Vector, ?_color:Color, ?_tcoord:Vector) {
        
        pos = _pos == null ? new Vector() : _pos;
        color = _color == null ? new Color() : _color;
        tcoord = _tcoord == null ? new Vector() : _tcoord;

    }
    

}