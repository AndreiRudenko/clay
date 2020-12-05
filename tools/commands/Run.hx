package commands;

import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class Run extends Command {

	public function new() {
		super(
			'run', 
			'build and run current project: run <target> [--debug]'
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

		var buildCommand = CLI.commandMap.get('build');
		var launchCommand = CLI.commandMap.get('launch');
		buildCommand.execute(args);
		launchCommand.execute(args);
	}

}