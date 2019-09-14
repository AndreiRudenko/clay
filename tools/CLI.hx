package;


import haxe.io.Path;
import sys.FileSystem;

class CLI {


	public static var engine_name:String = 'clay2d';
	public static var templates_path:String = 'templates';
	public static var backend_path:String = 'backend';
	public static var kha_path:String = 'Kha';
	public static var khamake_path:String;

	public static var command_map:Map<String, Command>;
	public static var user_dir:String;
	public static var engine_dir:String;

	public static var targets:Array<String> = ['html5', 'windows', 'windows-hl', 'osx', 'linux', 'android-native', 'android-native-hl', 'ios', 'uwp'];


	static function main() {

		var args = Sys.args();

		user_dir = args.pop();
		engine_dir = FileSystem.absolutePath(Path.directory(neko.vm.Module.local().name));
		khamake_path = Path.join([engine_dir, backend_path, kha_path, 'make']);

		init();

		if(args.length == 0) {
			for (c in command_map) {
				print('${c.name}\t ${c.usage}');
			}
			return;
		}
		process_args(args);

	}

	public static inline function print(msg:String) {

		Sys.println(msg);
		
	}

	public static inline function error(msg:String) {

		Sys.println("error: " + msg);
		
	}

	public static inline function execute(cmd:String, args:Array<String>):Int {

		var cwd = Sys.getCwd();
		Sys.setCwd(user_dir);

		var ret = Sys.command(cmd, args);

		Sys.setCwd(cwd);

		return ret;
	    
	}

	static function process_args(args:Array<String>) {

		var cname = args.shift();
		run_command(cname, args);

	}

	static function run_command(cname:String, args:Array<String>) {

		var cmd = command_map.get(cname);
		if(cmd == null) {
			print('Unknown command');
			return;
		}
		cmd.execute(args);
		
	}

	static function init() {

		command_map = new Map();

		command_map.set('init', new commands.Init());
		command_map.set('help', new commands.Help());
		command_map.set('build', new commands.Build());
		command_map.set('run', new commands.Run());
		command_map.set('launch', new commands.Launch());
		command_map.set('server', new commands.Server());
		command_map.set('clear', new commands.Clear());
		
	}
	

}
