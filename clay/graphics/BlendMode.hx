package clay.graphics;


@:enum abstract BlendMode(Int) from Int to Int {

    var NONE = 0;
    var NORMAL = 1;
    var ADD = 2;
    var MULTIPLY = 3;
    var SCREEN = 4;
    var ERASE = 5;
    var MASK = 6;
    var BELOW = 7;

}

