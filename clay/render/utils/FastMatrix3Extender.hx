package clay.render.utils;


import kha.math.FastMatrix3;


class FastMatrix3Extender {


	public static function orto(m:FastMatrix3, left:Float, right:Float, bottom:Float, top:Float):FastMatrix3 {

		var sx:Float = 1.0 / (right - left);
		var sy:Float = 1.0 / (top - bottom);

		m._00 = 2.0*sx;
		m._10 = 0;
		m._20 = -(right+left)*sx;

		m._01 = 0;
		m._11 = 2.0*sy;
		m._21 = -(top+bottom)*sy;

		m._02 = 0;
		m._12 = 0;
		m._22 = 1;

		return m;

	}
	
	public static function append(m:FastMatrix3, other:FastMatrix3):FastMatrix3 {

        var _00 = m._00;
        var _01 = m._01;
        var _10 = m._10;
        var _11 = m._11;

        m._00 = (other._00 * _00) + (other._01 * _10);
        m._01 = (other._00 * _01) + (other._01 * _11);
        m._10 = (other._10 * _00) + (other._11 * _10);
        m._11 = (other._10 * _01) + (other._11 * _11);

        m._20 = (other._20 * _00) + (other._21 * _10) + m._20;
        m._21 = (other._20 * _01) + (other._21 * _11) + m._21;

		return m;

	}

	public static function append_matrix(m:FastMatrix3, other:clay.math.Matrix):FastMatrix3 {

        var _00 = m._00;
        var _01 = m._01;
        var _10 = m._10;
        var _11 = m._11;

        m._00 = (other.a * _00) + (other.b * _10);
        m._01 = (other.a * _01) + (other.b * _11);
        m._10 = (other.c * _00) + (other.d * _10);
        m._11 = (other.c * _01) + (other.d * _11);

        m._20 = (other.tx * _00) + (other.ty * _10) + m._20;
        m._21 = (other.tx * _01) + (other.ty * _11) + m._21;

		return m;

	}

	public static function rotate(m:FastMatrix3, radians:Float):FastMatrix3 {
		
		var _sin:Float = Math.sin(radians);
		var _cos:Float = Math.cos(radians);

		var _00:Float = m._00;
		var _01:Float = m._01;
		var _10:Float = m._10;
		var _11:Float = m._11;

		m._00 = _00 *  _cos + _01 * _sin;
		m._01 = _00 * -_sin + _01 * _cos;
		m._10 = _10 *  _cos + _11 * _sin;
		m._11 = _10 * -_sin + _11 * _cos;

		return m;
		
	}

	public static function scale(m:FastMatrix3, _x:Float, _y:Float):FastMatrix3 {
		
		m._00 *= _x;
		m._01 *= _x;
		m._10 *= _y;
		m._11 *= _y;

		return m;
		
	}

	public static function translate(m:FastMatrix3, _x:Float, _y:Float):FastMatrix3 {
		
		m._20 += _x;
		m._21 += _y;

		return m;

	}    

	public static function apply(m:FastMatrix3, _x:Float, _y:Float):FastMatrix3 {
		
		m._20 = m._00 * _x + m._10 * _y + m._20;
		m._21 = m._01 * _x + m._11 * _y + m._21;

		return m;

	}

	public static function identity(m:FastMatrix3):FastMatrix3 {

		m._00 = 1;
		m._10 = 0;
		m._20 = 0;

		m._01 = 0;
		m._11 = 1;
		m._21 = 0;

		m._02 = 0;
		m._12 = 0;
		m._22 = 1;

		return m;

	}

	public static function invert(m:FastMatrix3):FastMatrix3 {

        var a1 = m._00;
        var b1 = m._01;
        var c1 = m._10;
        var d1 = m._11;
        var tx1 = m._20;
        var n = (a1 * d1) - (b1 * c1);

        m._00 = d1 / n;
        m._01 = -b1 / n;
        m._10 = -c1 / n;
        m._11 = a1 / n;
        m._20 = ((c1 * m._21) - (d1 * tx1)) / n;
        m._21 = -((a1 * m._21) - (b1 * tx1)) / n;

		return m;

	}

	public static function from_matrix(m3:FastMatrix3, m:clay.math.Matrix):FastMatrix3 {

		m3._00 = m.a;
		m3._10 = m.c;
		m3._20 = m.tx;

		m3._01 = m.b;
		m3._11 = m.d;
		m3._21 = m.ty;

		m3._02 = 0;
		m3._12 = 0;
		m3._22 = 1;

		return m3;

	}
	

}