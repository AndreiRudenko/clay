package commands;

import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
using StringTools;

class Collect extends Command {

	public function new() {
		super(
			'collect', 
			'collect all libraries to project folder: collect [--clear, --verbose]'
		);
	}

	override function execute(args:Array<String>) {
		var config:ConfigData = Config.get();

		var clear = false;
		var verbose = false;

		for (a in args) {
			switch (a) {
				case '--clear': clear = true;
				case '--verbose': verbose = true;
				default:
			}
		}

		var libraries:Array<String> = config.project.libraries;

		for (l in libraries) {
			var process = new sys.io.Process('haxelib', [ 'libpath', '$l']);
			if(process.exitCode() != 0) {
				var message = process.stderr.readAll().toString().trim();
				var pos = haxe.macro.Context.currentPos();
				CLI.error('Cannot execute clay2d collect ${message}');
			} else {
				var srcDir = process.stdout.readAll().toString().trim();
				srcDir = Path.normalize(srcDir);
				var pj = srcDir.split('/');
				var name = pj[pj.length-1];
				var dstDir = Path.join([CLI.userDir, name]);

				if(srcDir == dstDir) {
					CLI.error('can`t copy library from $srcDir to $dstDir');
					process.close();
					continue;
				}

				if (FileSystem.exists(dstDir)) {
					if(clear) {
						CLI.print('delete $dstDir');
						CLI.deleteDir(dstDir, verbose);
					} else {
						CLI.error('directory $dstDir is not empty, skip copy $name library');
						process.close();
						continue;
					}
				}

				CLI.print('copy $srcDir to ${CLI.userDir}');
				CLI.copyDir(srcDir, dstDir, verbose);
			}
			process.close();
		}
	}

}

