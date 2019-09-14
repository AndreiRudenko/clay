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

		var build_command = CLI.command_map.get('build');
		var launch_command = CLI.command_map.get('launch');
		build_command.execute(args);
		launch_command.execute(args);

	}



}