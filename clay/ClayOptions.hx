package clay;


import clay.render.Renderer;


typedef ClayOptions = {
    ?title:String,
    ?width:Int,
    ?height:Int,
    ?antialiasing:Int,
    ?vsync:Bool,
    ?random_seed:Int,
    ?renderer:RendererOptions,
    ?window:WindowOptions,

};

typedef WindowOptions = {
    ?name:String,
    ?x:Int,
    ?y:Int,
    ?resizable:Bool,
    ?minimizable:Bool,
    ?maximizable:Bool,
    ?borderless:Bool,
    ?ontop:Bool,
    ?mode:clay.types.WindowMode,
};