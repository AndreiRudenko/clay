package clay.math;

import clay.math.Transform;
import kha.math.FastMatrix3;
import kha.FastFloat;

/*
| a | c | tx |
| b | d | ty |
| 0 | 0 | 1  |
 */

abstract FastMatrix3(kha.math.FastMatrix3) from kha.math.FastMatrix3 to kha.math.FastMatrix3 {

	public var a(get, set):FastFloat;
	inline function get_a() return this._00; 
	inline function set_a(v:FastFloat) return this._00 = v;

	public var b(get, set):FastFloat;
	inline function get_b() return this._01; 
	inline function set_b(v:FastFloat) return this._01 = v;

	public var c(get, set):FastFloat;
	inline function get_c() return this._10; 
	inline function set_c(v:FastFloat) return this._10 = v;

	public var d(get, set):FastFloat;
	inline function get_d() return this._11; 
	inline function set_d(v:FastFloat) return this._11 = v;

	public var tx(get, set):FastFloat;
	inline function get_tx() return this._20; 
	inline function set_tx(v:FastFloat) return this._20 = v;

	public var ty(get, set):FastFloat;
	inline function get_ty() return this._21; 
	inline function set_ty(v:FastFloat) return this._21 = v;	
	
	public function new(a:FastFloat = 1, b:FastFloat = 0, c:FastFloat = 0, d:FastFloat = 1, tx:FastFloat = 0, ty:FastFloat = 0) {
		this = kha.math.FastMatrix3.identity();
		set(a, b, c, d, tx, ty);
	}

	public inline function identity():FastMatrix3 {
		set(
			1, 0,
			0, 1,
			0, 0
		);

		return  this;
	}

	public inline function set(a:FastFloat, b:FastFloat, c:FastFloat, d:FastFloat, tx:FastFloat, ty:FastFloat):FastMatrix3 {
		set_a(a);
		set_b(b);
		set_c(c);
		set_d(d);
		set_tx(tx);
		set_ty(ty);

		return this;
	}

	public inline function translate(x:FastFloat, y:FastFloat):FastMatrix3 {
		tx += x;
		ty += y;

		return this;
	}    

	public inline function prependTranslate(x:FastFloat, y:FastFloat):FastMatrix3 {
		tx = a * x + c * y + tx;
		ty = b * x + d * y + ty;

		return this;
	}
	
	public inline function scale(x:FastFloat, y:FastFloat):FastMatrix3 {
		a *= x;
		b *= x;
		c *= y;
		d *= y;

		return this;
	}
	
	public inline function rotate(radians:FastFloat):FastMatrix3 {
		var sin:FastFloat = Math.sin(radians);
		var cos:FastFloat = Math.cos(radians);

		var a1:FastFloat = a;
		var b1:FastFloat = b;
		var c1:FastFloat = c;
		var d1:FastFloat = d;

		a = a1 *  cos + b1 * sin;
		b = a1 * -sin + b1 * cos;
		c = c1 *  cos + d1 * sin;
		d = c1 * -sin + d1 * cos;

		return this;
	}	

	public inline function append(m:FastMatrix3):FastMatrix3 {
        var a1 = a;
        var b1 = b;
        var c1 = c;
        var d1 = d;

        a  = m.a * a1 + m.b * c1;
        b  = m.a * b1 + m.b * d1;
        c  = m.c * a1 + m.d * c1;
        d  = m.c * b1 + m.d * d1;

        tx = m.tx * a1 + m.ty * c1 + tx;
        ty = m.tx * b1 + m.ty * d1 + ty;

		return this;
	}

	public inline function prepend(m:FastMatrix3):FastMatrix3 {
	    var tx1 = tx;

	    if (m.a != 1 || m.b != 0 || m.c != 0 || m.d != 1) {
	        var a1 = a;
	        var c1 = c;

	        a = a1 * m.a + b * m.c;
	        b = a1 * m.b + b * m.d;
	        c = c1 * m.a + d * m.c;
	        d = c1 * m.b + d * m.d;
	    }

	    tx = tx1 * m.a + ty * m.c + m.tx;
	    ty = tx1 * m.b + ty * m.d + m.ty;

	    return this;
	}

	public inline function orto(left:FastFloat, right:FastFloat, bottom:FastFloat, top:FastFloat):FastMatrix3 {
		var sx:FastFloat = 1.0 / (right - left);
		var sy:FastFloat = 1.0 / (top - bottom);

		set(
			2.0*sx,      0,
			0,           2.0*sy,
			-(right+left)*sx, -(top+bottom)*sy
		);

		return this;
	}

	public inline function invert():FastMatrix3 {
		var a1:FastFloat = a;
		var b1:FastFloat = b;
		var c1:FastFloat = c;
		var d1:FastFloat = d;
		var tx1:FastFloat = tx;
		var n:FastFloat = a1 * d1 - b1 * c1;

		a = d1 / n;
		b = -b1 / n;
		c = -c1 / n;
		d = a1 / n;
		tx = (c1 * ty - d1 * tx1) / n;
		ty = -(a1 * ty - b1 * tx1) / n;

		return this;
	}

	public inline function copyFrom(other:FastMatrix3):FastMatrix3 {
		set(
			other.a,  other.b,
			other.c,  other.d,
			other.tx, other.ty
		);

		return this;
	}

	public inline function clone():FastMatrix3 {
		return new FastMatrix3(a, b, c, d, tx, ty);
	}

	public inline function decompose(into:Spatial) {
		var determ:FastFloat = a * d - b * c;

		into.pos.set(tx, ty);

		if(a != 0 || b != 0) {
			var r:FastFloat = Math.sqrt(a * a + b * b);
			into.rotation = (b > 0) ? Math.acos(a / r) : -Math.acos(a / r);
			into.scale.set(r, determ / r);
		} else if(c != 0 || d != 0) {
			var s:FastFloat = Math.sqrt(c * c + d * d);
			into.rotation = Math.PI * 0.5 - (d > 0 ? Math.acos(-c / s) : -Math.acos(c / s));
			into.scale.set(determ / s, s);
		} else {
			into.rotation = 0;
			into.scale.set(0,0);
		}
	}

	public inline function fromMatrix(m:Matrix):FastMatrix3 {
		set(m.a, m.b, m.c, m.d, m.tx, m.ty);

		return this;
	}

	public inline function getTransformX(x:FastFloat, y:FastFloat):FastFloat {
		return a * x + c * y + tx;
	}

	public inline function getTransformY(x:FastFloat, y:FastFloat):FastFloat {
		return b * x + d * y + ty;
	}
	
	public function setTransform(x:FastFloat, y:FastFloat, angle:FastFloat, sx:FastFloat, sy:FastFloat, ox:FastFloat, oy:FastFloat, kx:FastFloat, ky:FastFloat):FastMatrix3 {
		var sin:FastFloat = Math.sin(angle);
		var cos:FastFloat = Math.cos(angle);

		a = cos * sx - ky * sin * sy;
		b = sin * sx + ky * cos * sy;
		c = kx * cos * sx - sin * sy;
		d = kx * sin * sx + cos * sy;
		tx = x - ox * a - oy * c;
		ty = y - ox * b - oy * d;

		return this;
	}
	
}
