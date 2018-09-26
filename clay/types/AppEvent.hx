package clay.types;

@:keep
@:enum abstract AppEvent(Int) from Int to Int {

    var unknown                     = 0;

    var ready                       = 1;
    var init                        = 2;
    var reset                       = 3;

    var tickstart                   = 4;
    var tickend                     = 5;
    var update                      = 6;
    var destroy                     = 7;

    var prerender                   = 8;
    var render                      = 9;
    var postrender                  = 10;

    var keydown                     = 11;
    var keyup                       = 12;

    var inputdown                   = 13;
    var inputup                     = 14;

    var mousedown                   = 15;
    var mouseup                     = 16;
    var mousemove                   = 17;
    var mousewheel                  = 18;

    var touchdown                   = 19;
    var touchup                     = 20;
    var touchmove                   = 21;

    var pendown                     = 22;
    var penup                       = 23;
    var penmove                     = 24;

    var gamepadaxis                 = 25;
    var gamepaddown                 = 26;
    var gamepadup                   = 27;
    var gamepadadd                  = 28;
    var gamepadremove               = 29;

    var window                      = 30;
    var windowmoved                 = 31;
    var windowresized               = 32;
    var windowsized                 = 33;
    var windowminimized             = 34;
    var windowrestored              = 35;

    var timescale                   = 36;

    var last                        = 37;

}
