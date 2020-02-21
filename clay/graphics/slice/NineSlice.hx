package clay.graphics.slice;


import clay.math.Vector;
import clay.render.Vertex;
import clay.resources.Texture;
import clay.graphics.Mesh;


/*  
    0---1---2---3
    |   |   |   |
    4---5---6---7
    |   |   |   |
    8---9---10--11
    |   |   |   |
    12--13--14--15
*/

class NineSlice extends Mesh {


    public var width(get, set):Float;
    public var height(get, set):Float;

    public var top(get, set):Float;
    public var bottom(get, set):Float;
    public var left(get, set):Float;
    public var right(get, set):Float;

    public var drawCender(default, set):Bool;

    var _width:Float;
    var _height:Float;

    var _top:Float;
    var _bottom:Float;
    var _left:Float;
    var _right:Float;


    public function new(top:Float, left:Float, right:Float, bottom:Float) {

        var vertices = [];
        for (i in 0...16) {
            vertices.push(new Vertex(new Vector(), color));
        }

        super(vertices);

        _top = top;
        _bottom = bottom;
        _left = left;
        _right = right;

        _width = 128;
        _height = 128;

        drawCender = true;

        updateWidth();
        updateHeight();

    }

    override function set_texture(v:Texture):Texture {

        super.set_texture(v);

        updateWidth();
        updateHeight();

        return v;
        
    }

    function updateWidth() {

        if(texture == null) {
            return;
        }
        
        var tw = texture.widthActual;
        
        vertices[0].pos.x = vertices[4].pos.x = vertices[8].pos.x = vertices[12].pos.x = 0; 
        vertices[1].pos.x = vertices[5].pos.x = vertices[9].pos.x = vertices[13].pos.x = _left; 
        vertices[2].pos.x = vertices[6].pos.x = vertices[10].pos.x = vertices[14].pos.x = _width - _right; 
        vertices[3].pos.x = vertices[7].pos.x = vertices[11].pos.x = vertices[15].pos.x = _width;

        vertices[0].tcoord.x = vertices[4].tcoord.x = vertices[8].tcoord.x = vertices[12].tcoord.x = 0; 
        vertices[1].tcoord.x = vertices[5].tcoord.x = vertices[9].tcoord.x = vertices[13].tcoord.x = _left / tw; 
        vertices[2].tcoord.x = vertices[6].tcoord.x = vertices[10].tcoord.x = vertices[14].tcoord.x = 1 - _right / tw; 
        vertices[3].tcoord.x = vertices[7].tcoord.x = vertices[11].tcoord.x = vertices[15].tcoord.x = 1;

    }

    function updateHeight() {
        
        if(texture == null) {
            return;
        }

        var th = texture.heightActual;

        vertices[0].pos.y = vertices[1].pos.y = vertices[2].pos.y = vertices[3].pos.y = 0; 
        vertices[4].pos.y = vertices[5].pos.y = vertices[6].pos.y = vertices[7].pos.y = _top; 
        vertices[8].pos.y = vertices[9].pos.y = vertices[10].pos.y = vertices[11].pos.y = _height - _bottom; 
        vertices[12].pos.y = vertices[13].pos.y = vertices[14].pos.y = vertices[15].pos.y = _height; 

        vertices[0].tcoord.y = vertices[1].tcoord.y = vertices[2].tcoord.y = vertices[3].tcoord.y = 0; 
        vertices[4].tcoord.y = vertices[5].tcoord.y = vertices[6].tcoord.y = vertices[7].tcoord.y = _top / th; 
        vertices[8].tcoord.y = vertices[9].tcoord.y = vertices[10].tcoord.y = vertices[11].tcoord.y = 1 - _bottom / th; 
        vertices[12].tcoord.y = vertices[13].tcoord.y = vertices[14].tcoord.y = vertices[15].tcoord.y = 1; 

    }

    function updateIndices() {

        if(drawCender) {
            indices = [
                0,  1,  5,  5,  4,  0,  // 0
                1,  2,  6,  6,  5,  1,  // 1
                2,  3,  7,  7,  6,  2,  // 2
                4,  5,  9,  9,  8,  4,  // 3
                5,  6,  10, 10, 9,  5,  // 4
                6,  7,  11, 11, 10, 6,  // 5
                8,  9,  13, 13, 12, 8,  // 6
                9,  10, 14, 14, 13, 9,  // 7
                10, 11, 15, 15, 14, 10, // 8
            ];
        } else {
            indices = [
                0,  1,  5,  5,  4,  0,  // 0
                1,  2,  6,  6,  5,  1,  // 1
                2,  3,  7,  7,  6,  2,  // 2
                4,  5,  9,  9,  8,  4,  // 3
                // 5,  6,  10, 10, 9,  5,  // 4
                6,  7,  11, 11, 10, 6,  // 5
                8,  9,  13, 13, 12, 8,  // 6
                9,  10, 14, 14, 13, 9,  // 7
                10, 11, 15, 15, 14, 10, // 8
            ];

        }
    }

    function set_drawCender(v:Bool):Bool {
        
        drawCender = v;
        updateIndices();

        return drawCender;

    }

    inline function get_width():Float {
        
        return _width;

    }

    function set_width(v:Float):Float {
        
        if(_width != v) {
            _width = v;
            updateWidth();
        }

        return _width;

    }
    inline function get_height():Float {
        
        return _height;

    }
    
    function set_height(v:Float):Float {
        
        if(_height != v) {
            _height = v;
            updateHeight();
        }

        return _height;

    }

    inline function get_top():Float {
        
        return _top;

    }

    function set_top(v:Float):Float {
        
        _top = v;
        updateHeight();

        return _top;

    }

    inline function get_bottom():Float {
        
        return _bottom;

    }

    function set_bottom(v:Float):Float {
        
        _bottom = v;
        updateHeight();

        return _bottom;

    }

    inline function get_left():Float {
        
        return _left;

    }

    function set_left(v:Float):Float {
        
        _left = v;
        updateWidth();

        return _left;

    }

    inline function get_right():Float {
        
        return _right;

    }

    function set_right(v:Float):Float {
        
        _right = v;
        updateWidth();

        return _right;

    }


}
