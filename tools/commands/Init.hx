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

		var template_name = 'empty';
		if(args.length > 0) {
			if(args[0] == '-t' && args[1] != null) {
				template_name = args[1];
			}
		}
		create_project(template_name);

	}

	function create_project(template:String) {

		var template_path = Path.join([CLI.engine_dir, CLI.templates_path, template]);
		if (!FileSystem.exists(template_path)) {
			CLI.error('Cant find ${template} template');
		}

		var dir = FileSystem.readDirectory(CLI.user_dir);
		if(dir.length > 0) {
			CLI.error('${CLI.user_dir} folder is not empty');
		}

		copy_dir(template_path, CLI.user_dir);
		CLI.print('New ${CLI.engine_name} project is created in ${CLI.user_dir}');
		
	}

	function copy_dir(src_dir:String, dst_dir:String) {

		if (!FileSystem.exists(dst_dir)) {
			FileSystem.createDirectory(dst_dir);
		}

		for (name in FileSystem.readDirectory(src_dir)) {

			var src_path = Path.join([src_dir, name]);
			var dst_path = Path.join([dst_dir, name]);

			if (FileSystem.isDirectory(src_path)) {
				copy_dir(src_path, dst_path);
			} else {
				sys.io.File.copy(src_path, dst_path);
			}
			
		}

	}


}