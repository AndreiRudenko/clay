package clay.render;


import clay.math.Vector;
import clay.data.Color;


class Vertex {


    public var pos:Vector;
    public var tcoord:Vector;
    public var color:Color;


    public function new(_pos:Vector, _color:Color = null, _tcoord:Vector = null) {
        
        pos = _pos;
        color = _color == null ? new Color() : _color;
        tcoord = _tcoord == null ? new Vector() : _tcoord;

    }
    

}