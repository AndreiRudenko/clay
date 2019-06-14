package clay.render;



// used for sorting
@:enum abstract GeometryType(UInt) from UInt to UInt {
    
    var mesh              = 0;
    var quad              = 1;
    var quadpack          = 2;
    var particles         = 3;

}