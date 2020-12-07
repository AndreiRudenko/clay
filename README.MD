# Clay  
a cross-platform, 2d game framework.  
Built on top of [Kha](https://github.com/Kode/Kha) framework using [Haxe](https://haxe.org/) language.  

## Installation
```bash
git clone --recursive https://github.com/clay2d/clay.git
haxelib dev clay2d path/to/clay2d
```

### Command Line Interface
- haxelib run clay2d init [ -t template ]: *initialize a new project*.
- haxelib run clay2d build < target > [ --debug ]:  *build the current project*.
- haxelib run clay2d run < target > [ --debug ]:  *build and run the current project*.
- haxelib run clay2d server : *launch server for html5 build*.
- haxelib run clay2d launch: *launch build*.
- haxelib run clay2d collect [--clear, --verbose]: *copy all libraries to project folder*.
- haxelib run clay2d clear < target >:  *remove project build files*.
  
