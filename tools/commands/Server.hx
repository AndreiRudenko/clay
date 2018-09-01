package commands;


import Config;
import haxe.io.Path;


class Server extends Command {


	public function new() {
		super(
			'server', 
			'launch server for html5 build'
		);
	}

	override function execute(args:Array<String>) {

		var config:ConfigData = Config.get();
		var khamake_path = Path.join([CLI.engine_dir, CLI.backend_path, CLI.kha_path, 'Tools/khamake/khamake.js']);
		var port = 8080;

		if(config.html5 != null && config.html5.server_port != null) {
			port = config.html5.server_port;
		}

		js.node.ChildProcess.execSync('start cmd /c node $khamake_path --server --port $port');

	}


}