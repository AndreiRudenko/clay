package clay.particles.utils;


import clay.particles.core.ParticleModule;
import clay.particles.modules.*;


class ModulesFactory {


	public static var modules(default, null):Map<String, Dynamic->ParticleModule> = new Map();
	

	public static function init() {

		modules.set(Type.getClassName(SpawnModule),           function(o) { return new SpawnModule(o);});
		modules.set(Type.getClassName(BurstModule),           function(o) { return new BurstModule(o);});
		modules.set(Type.getClassName(AreaSpawnModule),       function(o) { return new AreaSpawnModule(o);});
		modules.set(Type.getClassName(ColorModule),           function(o) { return new ColorModule(o);});
		modules.set(Type.getClassName(ColorLifeModule),       function(o) { return new ColorLifeModule(o);});
		modules.set(Type.getClassName(DirectionModule),       function(o) { return new DirectionModule(o);});
		modules.set(Type.getClassName(ForceModule),           function(o) { return new ForceModule(o);});
		modules.set(Type.getClassName(GravityModule),         function(o) { return new GravityModule(o);});
		modules.set(Type.getClassName(RadialSpawnModule),     function(o) { return new RadialSpawnModule(o);});
		modules.set(Type.getClassName(RotationModule),        function(o) { return new RotationModule(o);});
		modules.set(Type.getClassName(RotationLifeModule),    function(o) { return new RotationLifeModule(o);});
		modules.set(Type.getClassName(ScaleModule),           function(o) { return new ScaleModule(o);});
		modules.set(Type.getClassName(ScaleLifeModule),       function(o) { return new ScaleLifeModule(o);});
		modules.set(Type.getClassName(SizeModule),            function(o) { return new SizeModule(o);});
		modules.set(Type.getClassName(SizeLifeModule),        function(o) { return new SizeLifeModule(o);});
		modules.set(Type.getClassName(VelocityLifeModule),    function(o) { return new VelocityLifeModule(o);});
		modules.set(Type.getClassName(VelocityModule),        function(o) { return new VelocityModule(o);});
		modules.set(Type.getClassName(VelocityUpdateModule),  function(o) { return new VelocityUpdateModule(o);});
		modules.set(Type.getClassName(RadialEdgeSpawnModule), function(o) { return new RadialEdgeSpawnModule(o);});
		modules.set(Type.getClassName(PolyLineSpawnModule),   function(o) { return new PolyLineSpawnModule(o);});
	    
	}

	public static inline function create(classname:String, ?_options:Dynamic):ParticleModule {

		var _f = modules.get(classname);
		if(_f != null) {
			if(_options == null) {
				_options = {};
			}
			return _f(_options);
		}

		return null;
	    
	}


}

