package clay;


import clay.render.Renderer;


typedef ClayOptions = {
    ?title:String,
    ?width:Int,
    ?height:Int,
    ?antialiasing:Int,
    ?window_mode:clay.types.WindowMode,
    ?vsync:Bool,
    ?resizable:Bool,
    ?random_seed:Int,
    ?renderer_options:RendererOptions,
};