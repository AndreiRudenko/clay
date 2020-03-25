package clay.graphics.particles.utils;

import clay.graphics.particles.core.Particle;

enum abstract ParticlesSortMode(Int) {
	var NONE;
	var LIFETIME;
	var LIFETIME_INV;
	var YOUNGEST;
	var OLDEST;
	var CUSTOM;
}

class ParticlesSortFunc {

	public static function lifetimeSort(a:Particle, b:Particle):Int {
		return a.lifetime < b.lifetime ? -1 : 1;
	}

	public static function lifetimeInvSort(a:Particle, b:Particle):Int {
		return a.lifetime > b.lifetime ? -1 : 1;
	}

	public static function youngestSort(a:Particle, b:Particle):Int {
		return a.age > b.age ? -1 : 1;
	}

	public static function oldestSort(a:Particle, b:Particle):Int {
		return a.age < b.age ? -1 : 1;
	}

	public static function getSortModeFunc(sortMode:ParticlesSortMode):(p1:Particle, p2:Particle)->Int {
		switch (sortMode) {
			case ParticlesSortMode.LIFETIME: return lifetimeSort;
			case ParticlesSortMode.LIFETIME_INV: return lifetimeInvSort;
			case ParticlesSortMode.YOUNGEST: return youngestSort;
			case ParticlesSortMode.OLDEST: return oldestSort;
			// case ParticlesSortMode.CUSTOM: return null;
			default: return null;
		}
	}

}
	