package;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

import yaml.Yaml;
import yaml.Parser;


class Config {

	public static function createKhaFile(config:ConfigData):String {

		var project = config.project;
		var compiler = config.compiler;
		var resourcesPath = project.resourcesPath;

		var kfile = 'let p = new Project("${project.title}");\n';

		for (s in project.sources) {
			kfile += 'p.addSources("${s}");\n';
		}

		kfile += 'p.addLibrary("${CLI.engineName}");\n';

		if(project.libraries != null) {
			for (s in project.libraries) {
				kfile += 'p.addLibrary("${s}");\n';
			}
		}

		if(project.shaders != null) {
			for (s in project.shaders) {
				kfile += 'p.addShaders("${s}");\n';
			}
		}

		kfile += 'p.addShaders("${Path.join([CLI.engineDir, 'assets/shaders'])}");\n';

		// inputs
		if(config.input != null) {
			if(config.input.mouse) {
				kfile += 'p.addDefine("use_mouse_input");\n';
			}
			if(config.input.keyboard) {
				kfile += 'p.addDefine("use_keyboard_input");\n';
			}
			if(config.input.gamepad) {
				kfile += 'p.addDefine("use_gamepad_input");\n';
			}
			if(config.input.touch) {
				kfile += 'p.addDefine("use_touch_input");\n';
			}
			if(config.input.pen) {
				kfile += 'p.addDefine("use_pen_input");\n';
			}
		} else {
			kfile += 'p.addDefine("use_mouse_input");\n';
			kfile += 'p.addDefine("use_keyboard_input");\n';
			kfile += 'p.addDefine("use_gamepad_input");\n';
			kfile += 'p.addDefine("use_touch_input");\n';
			// kfile += 'p.addDefine("use_pen_input");\n';
		}

		var noDefaultFont = false;

		if(project.defines != null) {
			for (s in project.defines) {
				kfile += 'p.addDefine("${s}");\n';
				if(s == 'no_default_font') {
					noDefaultFont = true;
				}
			}
		}

		if(compiler.parameters != null) {
			for (s in compiler.parameters) {
				kfile += 'p.addParameter("${s}");\n';
			}
		}

		var destPath = '{name}';
		if(resourcesPath != null && resourcesPath.length > 0) destPath = '$resourcesPath/{name}';

		if(!noDefaultFont) {
			var fp = Path.join([CLI.engineDir, 'assets/fonts']);
			kfile += 'p.addAssets("${fp}", {destination: "$destPath", noprocessing: true, notinlist: true});\n';
		}

		destPath = '{dir}/{name}';
		if(resourcesPath != null && resourcesPath.length > 0) destPath = '$resourcesPath/{dir}/{name}';

		if(project.assets != null) {
			for (s in project.assets) {
				kfile += 'p.addAssets("${s}/**", {nameBaseDir: "${s}", destination: "$destPath", name: "{dir}/{name}", noprocessing: true, notinlist: true});\n';
			}
		}

		if(config.html5 != null){
			if(config.html5.canvas != null) {
				kfile += 'p.targetOptions.html5.canvasId = "${config.html5.canvas}";\n';
			}
			if(config.html5.script != null) {
				kfile += 'p.targetOptions.html5.scriptName = "${config.html5.script}";\n';
			}
			if(config.html5.webgl != null) {
				kfile += 'p.targetOptions.html5.webgl = ${config.html5.webgl};\n';
			}
		}

		if(config.android != null){
			if(project.version != null) {
				kfile += 'p.targetOptions.android_native.versionName = "${project.version}";\n';
			}
			if(config.android.orientation != null) {
				kfile += 'p.targetOptions.android_native.screenOrientation = "${config.android.orientation}";\n';
			}
			if(config.android.versionCode != null) {
				kfile += 'p.targetOptions.android_native.versionCode = ${config.android.versionCode};\n';
			}
			if(config.android.permissions != null) {
				kfile += 'p.targetOptions.android_native.permissions = [${config.android.permissions.join(',')}];\n';
			}
			if(config.android.installLocation != null) {
				kfile += 'p.targetOptions.android_native.installLocation = "${config.android.installLocation}";\n';
			}
			
			if(Reflect.field(config.android, 'package') != null) {
				kfile += 'p.targetOptions.android_native.package = "${Reflect.field(config.android, 'package')}";\n';
			}
		}

		if(config.ios != null){
			if(project.version != null) {
				kfile += 'p.targetOptions.ios.version = "${project.version}";\n';
			}
			if(config.ios.orientation != null) {
				kfile += 'p.targetOptions.ios.screenOrientation = "${config.ios.orientation}";\n';
			}
			if(config.ios.bundle != null) {
				kfile += 'p.targetOptions.ios.bundle = "${config.ios.bundle}";\n';
			}
			if(config.ios.build != null) {
				kfile += 'p.targetOptions.ios.build = "${config.ios.build}";\n';
			}
			if(config.ios.organizationName != null) {
				kfile += 'p.targetOptions.ios.organizationName = "${config.ios.organizationName}";\n';
			}
			if(config.ios.developmentTeam != null) {
				kfile += 'p.targetOptions.ios.developmentTeam = "${config.ios.developmentTeam}";\n';
			}
		}

		kfile += "resolve(p);";

		return kfile;

	}

	public static function get():ConfigData {
		var configPath = Path.join([CLI.userDir, 'project.yml']);
		if (!FileSystem.exists(configPath)) {
			CLI.error('Cant find project.yml in: ${CLI.userDir}');
		}
		var data = File.getContent(configPath);
		var config:ConfigData = Yaml.parse(data, Parser.options().useObjects());

		return config;
	}

}

typedef ConfigData = {
	var project:ProjectConfig;
	var compiler:CompilerConfig;
	var app:AppConfig;
	var input:InputConfig;

	var html5:HtmlConfig;

	var windows:WindowsConfig;
	var osx:OSXConfig;
	var linux:LinuxConfig;

	var uwp:UWPConfig;
	var android:AndroidConfig;
	var ios:IOSConfig;

	// internal
	var target:String;
	var debug:Bool;
	var onlydata:Bool;
	var compile:Bool;
	var noshaders:Bool;
}

typedef InputConfig = {
	var pen:Bool;
	var touch:Bool;
	var gamepad:Bool;
	var mouse:Bool;
	var keyboard:Bool;
}

typedef ProjectConfig = {
	var title:String;
	var version:String;
	var resourcesPath:String;
	var sources:Array<String>;
	var authors:Array<String>;
	var libraries:Array<String>;
	var assets:Array<String>;
	var defines:Array<String>;
	var shaders:Array<String>;
}

typedef CompilerConfig = {
	var parameters:Array<String>;
	var options:Array<String>;
	var haxe:String;
	var kha:String;
	var ffmpeg:String;
}

typedef AppConfig = {
	var name:String;
	var icon:String;
}

typedef WindowsConfig = {
	var graphics:String;
	var audio:String;
}

typedef OSXConfig = {}

typedef LinuxConfig = {
	var graphics:String;
}

typedef UWPConfig = {
	var graphics:String;
	var audio:String;
	var orientation:String;
}

typedef AndroidConfig = {
	// var package:String;
	var graphics:String;
	var arch:String;
	var orientation:String;
	var installLocation:String;
	var versionCode:Int;
	var permissions:Array<String>;
}
typedef IOSConfig = {
	var orientation:String;
	var bundle:String;
	var build:String;
	var organizationName:String;
	var developmentTeam:String;
}

typedef HtmlConfig = {
	var webgl:Bool;
	var canvas:String;
	var script:String;
	var favicon:String;
	var width:Int;
	var height:Int;
	var htmlFile:String;
	var serverPort:Int;
}