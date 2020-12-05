package commands;

import sys.FileSystem;
import haxe.io.Path;

class Init extends Command {

	public function new() {
		super(
			'init', 
			'initialize a new project: init [-t template]'
		);
	}

	override function execute(args:Array<String>) {

		var templateName = 'empty';
		if(args.length > 0) {
			if(args[0] == '-t' && args[1] != null) {
				templateName = args[1];
			}
		}
		createProject(templateName);

	}

	function createProject(template:String) {
		var templatePath = Path.join([CLI.engineDir, CLI.templatesPath, template]);
		if (!FileSystem.exists(templatePath)) {
			CLI.error('Cant find ${template} template');
		}

		var dir = FileSystem.readDirectory(CLI.userDir);
		if(dir.length > 0) {
			CLI.error('${CLI.userDir} folder is not empty');
		}

		CLI.copyDir(templatePath, CLI.userDir);
		CLI.print('New ${CLI.engineName} project is created in ${CLI.userDir}');
	}

}