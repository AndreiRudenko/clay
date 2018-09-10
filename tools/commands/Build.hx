package commands;


import Config;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;


class Build extends Command {


	var windows_graphics:Array<String> = ["direct3d9", "direct3d11", "direct3d12", "vulkan", "opengl"];
	var uwp_graphics:Array<String> = ["direct3d11", "direct3d12"];
	var linux_graphics:Array<String> = ["vulkan", "opengl"];

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

		config.debug = args[1] == '--debug' ? true : false;

		// create build folder
		var build_path = Path.join([CLI.user_dir, 'build']);
		if (!FileSystem.exists(build_path)) {
			FileSystem.createDirectory(build_path);
		}
		// create kha file
		var khafile = Config.create_khafile(config);
        File.saveContent(Path.join([CLI.user_dir, 'khafile.js']), khafile);

		// copy icon
		if(config.target != 'html5' && config.app.icon != null && config.app.icon != '') {
			var icon_path = Path.join([CLI.user_dir, config.app.icon]);
			var dest_path = Path.join([CLI.user_dir, 'icon.png']);
			if (FileSystem.exists(icon_path)) {
				File.copy(icon_path, dest_path);
				CLI.print('Copy icon from: $icon_path');
			} else {
				CLI.print('Can`t find icon at: $icon_path');
			}
		}

        if(config.target == 'all') {
        	if(config.html5 != null) {
        		config.target = 'html5';
				build_project(config);
        	}
        	if(config.windows != null) {
        		config.target = 'windows';
				build_project(config);
        	}
        	if(config.osx != null) {
        		config.target = 'osx';
				build_project(config);
        	}
        	if(config.linux != null) {
        		config.target = 'linux';
				build_project(config);
        	}
        	if(config.android != null) {
        		config.target = 'android';
				build_project(config);
        	}
        	if(config.ios != null) {
        		config.target = 'ios';
				build_project(config);
        	}
        	if(config.uwp != null) {
        		config.target = 'uwp';
				build_project(config);
        	}
        	return;
        }

		build_project(config);

	}

	function build_project(config:ConfigData) {

		var khamake_path = Path.join([CLI.engine_dir, CLI.backend_path, CLI.kha_path, 'Tools/khamake/khamake.js']);

		var args:Array<String> = [];
		args.push(khamake_path);
		args.push('--target');
		args.push(config.target);
		if(config.debug) {
			args.push('--debug');
		}

		for (o in config.compiler.options) {
			args.push(o);
		}

		switch (config.target) {
			case 'windows' : {
				if(config.windows != null) {
					if(config.windows.graphics != null) {
						if(windows_graphics.indexOf(config.windows.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${windows_graphics.join(',')}]'); 
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
			case 'linux': {
				if(config.linux != null) {
					if(config.linux.graphics != null) {
						if(linux_graphics.indexOf(config.linux.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${linux_graphics.join(',')}]'); 
						}
						args.push('--graphics');
						args.push(config.linux.graphics);
					}
				}

			}
			case 'uwp' : {
				if(config.uwp != null) {
					if(config.uwp.graphics != null) {
						if(uwp_graphics.indexOf(config.uwp.graphics) == -1) {
							CLI.error('Unknown graphics target, use: [${uwp_graphics.join(',')}]'); 
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

		// args.push('--from');
		// args.push('build');
		args.push('--compile');

		CLI.print('Run build command: ${args.join(" ")}');
		var res = Sys.command('node', args);
		if(res != 0) {
			CLI.error('Build failed'); 
		}

		if(config.target == 'html5') {
			postbuild_html5(config);
		}

		CLI.print('Build ${config.target} complete.');

	}

	function postbuild_html5(config:ConfigData) {
		
		if(config.html5 != null) {
			// copy favicon
			if(config.html5.favicon != null && config.html5.favicon != '') {
				var icon_path = Path.join([CLI.user_dir, config.html5.favicon]);
				var dest_path = Path.join([CLI.user_dir, 'build/html5/favicon.png']);
				if (FileSystem.exists(icon_path)) {
					File.copy(icon_path, dest_path);
					CLI.print('Copy favicon from: $icon_path');
				} else {
					CLI.print('Can`t find favicon at: $icon_path');
				}
			}

			// copy html
			var html_path:String;
			if(config.html5.html_file != null && config.html5.html_file != '') {
				html_path = Path.join([CLI.user_dir, config.html5.html_file]);
			} else {
				html_path = Path.join([CLI.engine_dir, 'assets/html/index.html']);
			}


			if (FileSystem.exists(html_path)) {
				var dest_path = Path.join([CLI.user_dir, 'build/html5/index.html']);
				var html_file = File.getContent(html_path);

				var canvas_width:Int = 800;
				var canvas_height:Int = 600;

				var r = ~/\{name\}/g;
				html_file = r.replace(html_file, config.project.title);
				r = ~/\{script_name\}/g;
				html_file = r.replace(html_file, config.html5.script);
				r = ~/\{canvas_id\}/g;
				html_file = r.replace(html_file, config.html5.canvas);

				if(config.html5.width != null) {
					r = ~/\{canvas_width\}/g;
					html_file = r.replace(html_file, '${config.html5.width}');
					r = ~/\{canvas_half_width\}/g;
					html_file = r.replace(html_file, '${config.html5.width/2}'); // todo: ftw
				}
				if(config.html5.height != null) {
					r = ~/\{canvas_height\}/g;
					html_file = r.replace(html_file, '${config.html5.height}');
				}

		    	File.saveContent(dest_path, html_file);
				CLI.print('Copy html from: $html_path');
			} else {
				CLI.print('Can`t find html at: $html_path');
			}

			if(!config.debug) {
				var script:String;
				if(config.html5.minify) {
					CLI.print('Minifying javascript...');
					var min = js.node.ChildProcess.execSync('node ${CLI.engine_dir}/tools/node_modules/uglify-js/bin/uglifyjs ${CLI.user_dir}/build/html5/${config.html5.script}.js --compress --mangle', {encoding: "UTF-8"});
		    		File.saveContent('${CLI.user_dir}/build/html5/${config.html5.script}.js', min);
				}
			}
		}
			
	}


}

