package commands;

import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class Clear extends Command {

	var filesRemoved:Int = 0;
	var dirsRemoved:Int = 0;

	public function new() {
		super(
			'clear', 
			'remove project build files: clear <target>'
		);
	}

	override function execute(args:Array<String>) {
		if(args.length == 0) {
			CLI.error('Target not defined');
		}

		var target = args[0];
		if(target != 'all' && CLI.targets.indexOf(target) == -1) {
			CLI.error('Unknown target, use: [all,${CLI.targets.join(",")}]');
		}

		var config:ConfigData = Config.get();
		var toRemove:Array<String> = [];
		var projectTitle:String = config.project.title;

		if(target == 'all') {
			toRemove.push(Path.join([CLI.userDir, 'build']));
		} else {
			toRemove.push(Path.join([CLI.userDir, 'build/$target']));
			toRemove.push(Path.join([CLI.userDir, 'build/$target-resources']));
			toRemove.push(Path.join([CLI.userDir, 'build/$target-build']));
			toRemove.push(Path.join([CLI.userDir, 'build/$projectTitle-$target-intellij']));
			toRemove.push(Path.join([CLI.userDir, 'build/$projectTitle-$target.hxproj']));
			toRemove.push(Path.join([CLI.userDir, 'build/$projectTitle-$target.hxml']));
			toRemove.push(Path.join([CLI.userDir, 'build/project-$target.hxml']));
			toRemove.push(Path.join([CLI.userDir, 'build/temp']));
			toRemove.push(Path.join([CLI.userDir, 'build/khafile.js']));
			toRemove.push(Path.join([CLI.userDir, 'build/korefile.js']));
			toRemove.push(Path.join([CLI.userDir, 'build/icon.png']));
		}

		dirsRemoved = 0;
		filesRemoved = 0;

		for (s in toRemove) {
			if (FileSystem.exists(s)) {
				if(FileSystem.isDirectory(s)) {
					CLI.deleteDir(s);
					FileSystem.deleteDirectory(s);
					dirsRemoved++;
				} else {
					FileSystem.deleteFile(s);
					filesRemoved++;
				}
			}
		}
		
		// TODO: removed count is wrong
		CLI.print('Done: $dirsRemoved directories with $filesRemoved files was removed');
	}

}