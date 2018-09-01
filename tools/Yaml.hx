package ;

@:jsRequire('js-yaml')
extern class Yaml {

	static function safeLoad(string:String, ?options:Dynamic):Dynamic;
	static function load(string:String, ?options:Dynamic):Dynamic;

	static function safeDump(object:Dynamic, ?options:Dynamic):Void;
	static function dump(object:Dynamic, ?options:Dynamic):Void;

}
