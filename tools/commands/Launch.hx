package commands;


import Yaml;
import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;


class Launch extends Command {


	public function new() {

		super(
			'launch', 
			'launch project: launch <target>'
		);

	}

	override function execute(args:Array<String>) {

		if(args.length == 0) {
			CLI.error('Target not defined');
		}

		var target = args[0];
		if(CLI.targets.indexOf(target) == -1) {
			CLI.error('Unknown target, use: [${CLI.targets.join(",")}]');
		}

		launch_project(target);

	}

	function launch_project(target:String) {

		var config:ConfigData = Config.get();

		switch (target) {
			case 'html5' : {
				var port = 8080;
				if(config.html5 != null && config.html5.server_port != null) {
					port = config.html5.server_port;
				}
				var url = 'http://localhost:$port/';
				switch (Sys.systemName()) {
					case "Linux", "BSD": js.node.ChildProcess.execSync('xdg-open $url');
					case "Mac": js.node.ChildProcess.execSync('open $url');
					case "Windows": js.node.ChildProcess.execSync('start $url');
					default:
				}
			}
			case 'windows' : {
				var path = Path.join([CLI.user_dir, 'build/windows/${config.project.title}.exe']);
				if(!FileSystem.exists(path)) {
					CLI.error('Can`t find app at: $path');
				}
				js.node.ChildProcess.execSync('start cmd /c $path'); // todo: remove cmd ?
			}
			case 'windows-hl' : {
				var path = Path.join([CLI.user_dir, 'build/windows-hl/${config.project.title}.exe']);
				if(!FileSystem.exists(path)) {
					CLI.error('Can`t find app at: $path');
				}
				js.node.ChildProcess.execSync('start cmd /c $path'); // todo: remove cmd ?
			}
			case 'android-native-hl' : {
				var path = Path.join([CLI.user_dir, 'build/android-native-hl-build/${config.project.title}/app/build/outputs/apk/debug/app-debug.apk']);
				if(!FileSystem.exists(path)) {
					CLI.error('Can`t find app at: $path');
				}
				var pkg = untyped __js__('config.android.package');
				// js.node.ChildProcess.execSync('start cmd /c adb uninstall $pkg');
				js.node.ChildProcess.execSync('start cmd /c adb install -r $path');
				js.node.ChildProcess.execSync('start cmd /c adb shell am start -n $pkg/tech.kode.kore.KoreActivity');
				js.node.ChildProcess.execSync('start cmd /c adb logcat -s kore DEBUG AndroidRuntime');
			}
			case 'linux': {
				var path = Path.join([CLI.user_dir, 'build/linux/${config.project.title}']);
				if(!FileSystem.exists(path)) {
					CLI.error('Can`t find app at: $path');
				}
				js.node.ChildProcess.execSync('xdg-open $path');
			}
			case 'osx' : {
				var path = Path.join([CLI.user_dir, 'build/osx/${config.project.title}']);
				if(!FileSystem.exists(path)) {
					CLI.error('Can`t find app at: $path');
				}
				js.node.ChildProcess.execSync('open $path');
			}
		}

	}


}