package;


import haxe.io.Path;
import sys.FileSystem;

class CLI {


	public static final engineName:String = 'clay2d';
	public static final templatesPath:String = 'templates';
	public static final backendPath:String = 'backend';
	public static final khaPath:String = 'Kha';
	public static final resourcesPath:String = 'data';

	public static var commandMap:Map<String, Command>;
	public static var userDir:String;
	public static var engineDir:String;
	public static var khamakePath:String;

	public static var targets:Array<String> = ['html5', 'windows', 'windows-hl', 'osx', 'linux', 'android-native', 'android-hl', 'ios', 'uwp'];


	static function main() {

		var args = Sys.args();

		userDir = args.pop();
		engineDir = FileSystem.absolutePath(Path.directory(neko.vm.Module.local().name));
		khamakePath = Path.join([engineDir, backendPath, khaPath, 'make']);

		init();

		if(args.length == 0) {
			for (c in commandMap) {
				print('${c.name}\t ${c.usage}');
			}
			return;
		}
		processArgs(args);

	}

	public static inline function print(msg:String) {

		Sys.println(msg);
		
	}

	public static inline function error(msg:String) {

		Sys.println("error: " + msg);
		Sys.exit(1);
		
	}

	public static inline function execute(cmd:String, args:Array<String>):Int {

		var cwd = Sys.getCwd();
		Sys.setCwd(userDir);

		var ret = Sys.command(cmd, args);

		Sys.setCwd(cwd);

		return ret;
	    
	}

	static function processArgs(args:Array<String>) {

		var cname = args.shift();
		runCommand(cname, args);

	}

	static function runCommand(cname:String, args:Array<String>) {

		var cmd = commandMap.get(cname);
		if(cmd == null) {
			print('Unknown command');
			return;
		}
		cmd.execute(args);
		
	}

	static function init() {

		commandMap = new Map();

		commandMap.set('init', new commands.Init());
		commandMap.set('help', new commands.Help());
		commandMap.set('build', new commands.Build());
		commandMap.set('run', new commands.Run());
		commandMap.set('launch', new commands.Launch());
		commandMap.set('server', new commands.Server());
		commandMap.set('clear', new commands.Clear());
		
	}
	

}
