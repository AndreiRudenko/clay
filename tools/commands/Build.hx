package commands;


import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;


class Build extends Command {


	var windowsGraphics:Array<String> = ["direct3d9", "direct3d11", "direct3d12", "vulkan", "opengl"];
	var uwpGraphics:Array<String> = ["direct3d11", "direct3d12"];
	var linuxGraphics:Array<String> = ["vulkan", "opengl"];

	var audio:Array<String> = ["wasapi", "directsound"];


	public function new() {

		super(
			'build', 
			'build current project: build <target> [--debug]'
		);

	}

	override function execute(args:Array<String>) {

		if(args.length == 0) {
			CLI.error('Target not defined');
		}

		var config:ConfigData = Config.get();

		config.target = args[0];
		if(config.target != 'all' && CLI.targets.indexOf(config.target) == -1) {
			CLI.error('Unknown target, use: [all,${CLI.targets.join(",")}]');
		}

		config.debug = false;
		config.onlydata = false;
		config.compile = false;
		for (a in args) {
			switch (a) {
				case '--debug' : {
					config.debug = true;
				}
				case '--onlydata' : {
					config.onlydata = true;
				}
				case '--noshaders' : {
					config.noshaders = true;
				}
				case '--compile' : {
					config.compile = true;
				}
			}
		}

		// create build folder
		var buildPath = Path.join([CLI.userDir, 'build']);
		if (!FileSystem.exists(buildPath)) {
			FileSystem.createDirectory(buildPath);
		}
		// create kha file
		var khafile = Config.createKhaFile(config);
        File.saveContent(Path.join([CLI.userDir, 'khafile.js']), khafile);

		// copy icon
		if(config.target != 'html5' && config.app.icon != null && config.app.icon != '') {
			var iconPath = Path.join([CLI.userDir, config.app.icon]);
			var destPath = Path.join([CLI.userDir, 'icon.png']);
			if (FileSystem.exists(iconPath)) {
				File.copy(iconPath, destPath);
				CLI.print('Copy icon from: $iconPath');
			} else {
				CLI.print('Can`t find icon at: $iconPath');
			}
		}

        if(config.target == 'all') {
        	for (t in CLI.targets) {
	        	if(Reflect.hasField(config, t)) {
	        		config.target = t;
					buildProject(config);
	        	}
        	}
        } else {
			buildProject(config);
        }

	}

	function buildProject(config:ConfigData) {

		var args:Array<String> = [];
		args.push('--target');
		args.push(config.target);
		if(config.debug) {
			args.push('--debug');
		}

		for (o in config.compiler.options) {
			args.push(o);
		}

		switch (config.target) {
			case 'windows', 'windows-hl': {
				if(config.windows != null) {
					if(config.windows.graphics != null) {
						if(windowsGraphics.indexOf(config.windows.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${windowsGraphics.join(',')}]'); 
						}
						args.push('--graphics');
						args.push(config.windows.graphics);
					}
					if(config.windows.audio != null) {
						if(audio.indexOf(config.windows.audio) == -1) {
							CLI.error('Unknown audio target, use: [${audio.join(',')}]'); 
						}
						args.push('--audio');
						args.push(config.windows.audio);
					}
				}
			}
			case 'android-native', 'android-hl': {
				var arch = 'arm7';
				if(config.android != null) {
					if(config.android.arch != null) {
						arch = config.android.arch;
					}
				}
				args.push('--arch ${arch}');
			}
			case 'linux': {
				if(config.linux != null) {
					if(config.linux.graphics != null) {
						if(linuxGraphics.indexOf(config.linux.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${linuxGraphics.join(',')}]'); 
						}
						args.push('--graphics');
						args.push(config.linux.graphics);
					}
				}

			}
			case 'uwp' : {
				if(config.uwp != null) {
					if(config.uwp.graphics != null) {
						if(uwpGraphics.indexOf(config.uwp.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${uwpGraphics.join(',')}]'); 
						}
						args.push('--graphics');
						args.push(config.uwp.graphics);
					}
				}
			}
		}

		var compiler = config.compiler;

		if(compiler != null) {
			if(compiler.haxe != null && compiler.haxe != '') {
				args.push('--haxe');
				args.push(compiler.haxe);
			}
			if(compiler.kha != null && compiler.kha != '') {
				args.push('--kha');
				args.push(compiler.kha);
			}
			if(compiler.ffmpeg != null && compiler.ffmpeg != '') {
				args.push('--ffmpeg');
				args.push(compiler.ffmpeg);
			}
		}

		if(config.compile) {
			args.push('--compile');
		}

		if(config.onlydata) {
			args.push('--onlydata');
		}

		if(config.noshaders) {
			args.push('--noshaders');
		}

		CLI.print('Run build command: ${args.join(" ")}');
		var res = CLI.execute(CLI.khamakePath, args);
		if(res != 0) {
			CLI.error('Build failed'); 
		}

		if(config.target == 'html5') {
			postbuildHtml5(config);
		}

		CLI.print('Build ${config.target} complete.');

	}

	function postbuildHtml5(config:ConfigData) {
		
		if(config.html5 != null) {
			// copy favicon
			if(config.html5.favicon != null && config.html5.favicon != '') {
				var iconPath = Path.join([CLI.userDir, config.html5.favicon]);
				var destPath = Path.join([CLI.userDir, 'build/html5/favicon.png']);
				if (FileSystem.exists(iconPath)) {
					File.copy(iconPath, destPath);
					CLI.print('Copy favicon from: $iconPath');
				} else {
					CLI.print('Can`t find favicon at: $iconPath');
				}
			}

			// copy html
			var htmlPath:String;
			if(config.html5.htmlFile != null && config.html5.htmlFile != '') {
				htmlPath = Path.join([CLI.userDir, config.html5.htmlFile]);
			} else {
				htmlPath = Path.join([CLI.engineDir, 'assets/html/index.html']);
			}

			if (FileSystem.exists(htmlPath)) {
				var destPath = Path.join([CLI.userDir, 'build/html5/index.html']);
				var htmlFile = File.getContent(htmlPath);

				var canvasWidth:Int = 800;
				var canvasHeight:Int = 600;

				var r = ~/\{name\}/g;
				htmlFile = r.replace(htmlFile, config.project.title);
				r = ~/\{scriptName\}/g;
				htmlFile = r.replace(htmlFile, config.html5.script);
				r = ~/\{canvasID\}/g;
				htmlFile = r.replace(htmlFile, config.html5.canvas);

				if(config.html5.width != null) {
					r = ~/\{canvasWidth\}/g;
					htmlFile = r.replace(htmlFile, '${config.html5.width}');
					r = ~/\{canvasHalfWidth\}/g;
					htmlFile = r.replace(htmlFile, '${config.html5.width/2}'); // todo: ftw
				}
				if(config.html5.height != null) {
					r = ~/\{canvasHeight\}/g;
					htmlFile = r.replace(htmlFile, '${config.html5.height}');
				}

		    	File.saveContent(destPath, htmlFile);
				CLI.print('Copy html from: $htmlPath');
			} else {
				CLI.print('Can`t find html at: $htmlPath');
			}

		}
			
	}


}

