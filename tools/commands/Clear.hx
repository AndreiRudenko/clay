package commands;


import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;


class Clear extends Command {

	var files_removed:Int = 0;
	var dirs_removed:Int = 0;

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
		var to_remove:Array<String> = [];
		var project_title:String = config.project.title;

		if(target == 'all') {
			to_remove.push(Path.join([CLI.user_dir, 'build']));
		} else {
			to_remove.push(Path.join([CLI.user_dir, 'build/$target']));
			to_remove.push(Path.join([CLI.user_dir, 'build/$target-resources']));
			to_remove.push(Path.join([CLI.user_dir, 'build/$target-build']));
			to_remove.push(Path.join([CLI.user_dir, 'build/$project_title-$target-intellij']));
			to_remove.push(Path.join([CLI.user_dir, 'build/$project_title-$target.hxproj']));
			to_remove.push(Path.join([CLI.user_dir, 'build/$project_title-$target.hxml']));
			to_remove.push(Path.join([CLI.user_dir, 'build/project-$target.hxml']));
			to_remove.push(Path.join([CLI.user_dir, 'build/temp']));
			to_remove.push(Path.join([CLI.user_dir, 'build/khafile.js']));
			to_remove.push(Path.join([CLI.user_dir, 'build/korefile.js']));
			to_remove.push(Path.join([CLI.user_dir, 'build/icon.png']));
		}

		dirs_removed = 0;
		files_removed = 0;

		for (s in to_remove) {
			if (FileSystem.exists(s)) {
				if(FileSystem.isDirectory(s)) {
					delete_dir(s);
					FileSystem.deleteDirectory(s);
					dirs_removed++;
				} else {
					FileSystem.deleteFile(s);
					files_removed++;
				}
			}
		}

		CLI.print('Done: $dirs_removed directories with $files_removed files was removed');

	}

	function delete_dir(path:String) {

		if (FileSystem.exists(path) && FileSystem.isDirectory(path)) {
			var entries = FileSystem.readDirectory(path);
			for (entry in entries) {
				if (FileSystem.isDirectory(path + '/' + entry)) {
					delete_dir(path + '/' + entry);
					FileSystem.deleteDirectory(path + '/' + entry);
					dirs_removed++;
				} else {
					FileSystem.deleteFile(path + '/' + entry);
					files_removed++;
				}
			}
		}

	}

}