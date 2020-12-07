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
		var port = 8080;

		if(config.html5 != null && config.html5.serverPort != null) {
			port = config.html5.serverPort;
		}

		CLI.execute('start', ['cmd', "/c", '${CLI.khamakePath}', '--server', '--port', '$port']);
	}

}