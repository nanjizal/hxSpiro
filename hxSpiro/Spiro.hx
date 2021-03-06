package hxSpiro;
// References: https://github.com/wieslawsoltes/SpiroNet or https://github.com/be5invis/libspiro-js
// GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
// Work in progress Haxe port based on c# and js port.
import haxe.ds.Vector;
using Math;
class Segment{
    public var x: Float;
    public var y: Float;
    public var pointType: PointType;
    public var bend_theta: Float;
    public var ks = new Vector<Float>(4);
    public var dChord: Float;
    public var segment_theta: Float;
    public var l: Int;
    public function new( ){
        ks[0] = 0.;
        ks[1] = 0.;
        ks[2] = 0.;
        ks[3] = 0.;
        dChord = 0.;
        
    }
}
class BandMatrix{
    public var a: Vector<Float>;
    public var al: Vector<Float>;
    public function new() {
        a = new Vector<Float>( 11 );
        for( i in 0...a.length ) { a[ i ] = 0.; }
        al = new Vector<Float>( 9 );
        for( i in 0...al.length ) { a[ i ] = 0.; };
    }
    function copyFrom( m: BandMatrix ){
        a = m.a.copy();
        al = m.al.copy();
    }
    public static /* inline */ function copy( from_:Vector<BandMatrix>, fromIndex: Int
                        , to_: Vector<BandMatrix>, toIndex: Int
                        , len: Int ){
        for( i in 0...len ) { to_[ i + toIndex ].copyFrom( from_[ i + fromIndex ] ); }
    }
}
typedef Point = {
    var x: Float;
    var y: Float;
}
typedef ControlPoint = {
    var x: Float;
    var y: Float;
    var pointType: PointType;
}
@:enum
abstract PointType( String ) {
    var Corner          = 'v';
    var G4              = 'o';
    var G2              = 'c';
    var Left            = '[';
    var Right           = ']';
    var End             = 'z';
    var OpenContour     = '{';
    var EndOpenContour  = '}';
}
class Spiro {
    public static function spiroCPsToBezier0( spiros: Vector<ControlPoint>, n: Int, isClosed: Bool, bc: IBezierContext ):Bool {
            var s: Vector<Segment>;
            if( n <= 0 ) return false;
            if( isClosed ){
                s = runSpiro( spiros, n );
            } else {
                var oldty_start = spiros[ 0 ].pointType;
                var oldty_end   = spiros[ n - 1 ].pointType;
                spiros[ 0 ].pointType = OpenContour;
                spiros[ n - 1 ].pointType = EndOpenContour;
                s = runSpiro( spiros, n );
                spiros[ n - 1 ].pointType = oldty_end;
                spiros[0].pointType = oldty_start;
            }
            if( s != null ){
                spiro_to_bpath( s, n, bc );
                return true; // success
            }
            return false; // spiro did not converge or encountered non-finite values
    }
    public static function taggedSpiroCPsToBezier0( spiros: Vector<ControlPoint>, bc: IBezierContext ): Bool {
        var s: Vector<Segment>;
        var n = 0;
        var pointType: PointType;
        while( true ){
            pointType = spiros[ n ].pointType;
            if( pointType == End || pointType == EndOpenContour ) break;
            if( n >= spiros.length ) return false; // invalid input
            ++n;
        }
        pointType = spiros[ n ].pointType;
        if( pointType == EndOpenContour ) ++n;
        if( n <= 0 ) return false; // invalid input
        s = runSpiro( spiros, n );
        if( s != null ){
            spiro_to_bpath( s, n, bc );
            return true; // success
        }
        return false; // spiro did not converge or encountered non-finite values
    }
    public static /* inline */ var N: Int = 4;
    public static /* inline */ function hyp( x: Float, y: Float ){
        var h = Math.sqrt( x * x + y * y );
        if( h.isNaN() == true ) {
            trace( 'failed to calculate hyp ' + x + ' ' + y );
        }
        return h;
    }
    public static /* inline */ function copyFloats( from_:Vector<Float>, fromIndex: Int
                        , to_: Vector<Float>, toIndex: Int
                        , len: Int ){
        for( i in 0...len ) { to_[ i + toIndex ] = from_[ i + fromIndex ]; }
    }
    public static /* inline */ function integrate( ks: Vector<Float>, p: Point, n: Int ){
        var th1 = ks[0];
        var th2 = 0.5 * ks[1];
        var th3 = (1.0 / 6) * ks[2];
        var th4 = (1.0 / 24) * ks[3];
        var x = 0.;
        var y = 0.;
        var ds = 1.0 / n;
        var ds2 = ds * ds;
        var ds3 = ds2 * ds;
        var k0 = ks[0] * ds;
        var k1 = ks[1] * ds;
        var k2 = ks[2] * ds;
        var k3 = ks[3] * ds;
        var s = 0.5 * ds - 0.5;
        for( i in 0...n ){
            var u: Float;
            var v: Float;
            var km0: Float;
            var km1: Float;
            var km2: Float;
            var km3: Float;
            if( n == 1 ){
                km0 = k0;
                km1 = k1 * ds;
                km2 = k2 * ds2;
            } else {
                km0 = (((1. / 6) * k3 * s + .5 * k2) * s + k1) * s + k0;
                km1 = ((.5 * k3 * s + k2) * s + k1) * ds;
                km2 = (k3 * s + k2) * ds2;
            }
            km3 = k3 * ds3;
            var t1_1 = km0;
            var t1_2 = 0.5 * km1;
            var t1_3 = (1. / 6.) * km2;
            var t1_4 = (1. / 24.) * km3;
            var t2_2 = t1_1 * t1_1;
            var t2_3 = 2. * (t1_1 * t1_2);
            var t2_4 = 2. * (t1_1 * t1_3) + t1_2 * t1_2;
            var t2_5 = 2. * (t1_1 * t1_4 + t1_2 * t1_3);
            var t2_6 = 2. * (t1_2 * t1_4) + t1_3 * t1_3;
            var t2_7 = 2. * (t1_3 * t1_4);
            var t2_8 = t1_4 * t1_4;
            var t3_4 = t2_2 * t1_2 + t2_3 * t1_1;
            var t3_6 = t2_2 * t1_4 + t2_3 * t1_3 + t2_4 * t1_2 + t2_5 * t1_1;
            var t3_8 = t2_4 * t1_4 + t2_5 * t1_3 + t2_6 * t1_2 + t2_7 * t1_1;
            var t3_10 = t2_6 * t1_4 + t2_7 * t1_3 + t2_8 * t1_2;
            var t4_4 = t2_2 * t2_2;
            var t4_5 = 2. * (t2_2 * t2_3);
            var t4_6 = 2. * (t2_2 * t2_4) + t2_3 * t2_3;
            var t4_7 = 2. * (t2_2 * t2_5 + t2_3 * t2_4);
            var t4_8 = 2. * (t2_2 * t2_6 + t2_3 * t2_5) + t2_4 * t2_4;
            var t4_9 = 2. * (t2_2 * t2_7 + t2_3 * t2_6 + t2_4 * t2_5);
            var t4_10 = 2. * (t2_2 * t2_8 + t2_3 * t2_7 + t2_4 * t2_6) + t2_5 * t2_5;
            var t5_6 = t4_4 * t1_2 + t4_5 * t1_1;
            var t5_8 = t4_4 * t1_4 + t4_5 * t1_3 + t4_6 * t1_2 + t4_7 * t1_1;
            var t5_10 = t4_6 * t1_4 + t4_7 * t1_3 + t4_8 * t1_2 + t4_9 * t1_1;
            var t6_6 = t4_4 * t2_2;
            var t6_7 = t4_4 * t2_3 + t4_5 * t2_2;
            var t6_8 = t4_4 * t2_4 + t4_5 * t2_3 + t4_6 * t2_2;
            var t6_9 = t4_4 * t2_5 + t4_5 * t2_4 + t4_6 * t2_3 + t4_7 * t2_2;
            var t6_10 = t4_4 * t2_6 + t4_5 * t2_5 + t4_6 * t2_4 + t4_7 * t2_3 + t4_8 * t2_2;
            var t7_8 = t6_6 * t1_2 + t6_7 * t1_1;
            var t7_10 = t6_6 * t1_4 + t6_7 * t1_3 + t6_8 * t1_2 + t6_9 * t1_1;
            var t8_8 = t6_6 * t2_2;
            var t8_9 = t6_6 * t2_3 + t6_7 * t2_2;
            var t8_10 = t6_6 * t2_4 + t6_7 * t2_3 + t6_8 * t2_2;
            var t9_10 = t8_8 * t1_2 + t8_9 * t1_1;
            var t10_10 = t8_8 * t2_2;
            u = 1.;
            v = 0.;
            v += (1. / 12.) * t1_2 + (1. / 80) * t1_4;
            u -= (1. / 24.) * t2_2 + (1. / 160) * t2_4 + (1. / 896) * t2_6 + (1. / 4608) * t2_8;
            v -= (1. / 480) * t3_4 + (1. / 2688) * t3_6 + (1. / 13824) * t3_8 + (1. / 67584) * t3_10;
            u += (1. / 1920) * t4_4 + (1. / 10752) * t4_6 + (1. / 55296) * t4_8 + (1. / 270336) * t4_10;
            v += (1. / 53760) * t5_6 + (1. / 276480) * t5_8 + (1. / 1.35168e+06) * t5_10;
            u -= (1. / 322560) * t6_6 + (1. / 1.65888e+06) * t6_8 + (1. / 8.11008e+06) * t6_10;
            v -= (1. / 1.16122e+07) * t7_8 + (1. / 5.67706e+07) * t7_10;
            u += (1. / 9.28973e+07) * t8_8 + (1. / 4.54164e+08) * t8_10;
            v += (1. / 4.08748e+09) * t9_10;
            u -= (1. / 4.08748e+10) * t10_10;
            if (n == 1){
                x = u;
                y = v;
            } else {
                var th = (((th4 * s + th3) * s + th2) * s + th1) * s;
                var cth = Math.cos(th);
                var sth = Math.sin(th);
                x += cth * u - sth * v;
                y += cth * v + sth * u;
                s += ds;
            }
        }
        p.x = x * ds;
        p.y = y * ds;
    }
    public static /* inline */ function computeEnds( ks: Vector<Float>, ends:Vector<Vector<Float>>, seg_ch: Float ): Float {
        var p : Point = { x: 0, y: 0 };
        integrate( ks, p, N );
        var ch = hyp( p.x, p.y );
        var th = Math.atan2( p.y, p.x );
        var l = ch / seg_ch;
        var th_even = .5 * ks[ 0 ] + (1. / 48) * ks[ 2 ];
        var th_odd = .125 * ks[ 1 ] + (1. / 384) * ks[ 3 ] - th;
        ends[ 0 ][ 0 ] = th_even - th_odd;
        ends[ 1 ][ 0 ] = th_even + th_odd;
        var k0_even = l * (ks[0] + .125 * ks[ 2 ]);
        var k0_odd = l * (.5 * ks[1] + (1. / 48) * ks[ 3 ]);
        ends[ 0 ][ 1 ] = k0_even - k0_odd;
        ends[ 1 ][ 1 ] = k0_even + k0_odd;
        var l2 = l * l;
        var k1_even = l2 * ( ks[ 1 ] + 0.125 * ks[ 3 ]);
        var k1_odd = l2 * .5 * ks[ 2 ];
        ends[ 0 ][ 2 ] = k1_even - k1_odd;
        ends[ 1 ][ 2 ] = k1_even + k1_odd;
        var l3 = l2 * l;
        var k2_even = l3 * ks[ 2 ];
        var k2_odd = l3 * .5 * ks[ 3 ];
        ends[ 0 ][ 3 ] = k2_even - k2_odd;
        ends[ 1 ][ 3 ] = k2_even + k2_odd;
        return l;
    }
    public static /* inline */ function pderivs( s: Segment, ends: Vector<Vector<Float>>, derivs: Vector<Vector<Vector<Float>>>, jinc: Int ){
        var recip_d = 2e6;
        var delta = 1. / recip_d;
        var try_ks = new Vector<Float>(4);
        var try_ends = new Vector<Vector<Float>>(2);
        try_ends[ 0 ] = new Vector<Float>(4);
        try_ends[ 1 ] = new Vector<Float>(4);
        if( s.dChord == 0 ) return;
        computeEnds( s.ks, ends, s.dChord );
        for( i in 0...jinc ){
            for( j in 0...4 ) try_ks[ j ] = s.ks[ j ];
            try_ks[ i ] += delta;
            computeEnds( try_ks, try_ends, s.dChord );
            for( k in 0...2 ) for ( j in 0...4 ) derivs[ j ][ k ][ i ] = recip_d * ( try_ends[ k ][ j ] - ends[ k ][ j ] );
        }
    }
    public static /* inline */ function mod2pi( th: Float ){
        var u = th / (2 * Math.PI);
        return 2 * Math.PI * (u - Math.floor(u + 0.5));
    }
    public static /* inline */ function setupPath( src:Vector<ControlPoint>, n: Int ): Vector<Segment> {
        // Verify that input values are within realistic limits
        var r: Vector<Segment> = null;
#if checkFitness
        var rValid: Bool = true;
        for( i in 0...n ){
            if( !Math.isFinite( src[ i ].x ) || !Math.isFinite( src[ i ].y ) ) {
                r = null;
                rValid = false;
                break;
            }
        }
        if( rValid ) {
#end
            var n_seg = src[0].pointType == OpenContour ? n - 1 : n;
            r = new Vector<Segment>( n_seg + 1 );
            for( j in 0...( n_seg + 1 )) {
                r[ j ] = new Segment();
            }
            for (i in 0...n_seg ){
                var seg = r[i];
                var srci = src[i];
                seg.x = srci.x;
                seg.y = srci.y;
                seg.pointType = srci.pointType;
                seg.ks[ 0 ] = 0.0;
                seg.ks[ 1 ] = 0.0;
                seg.ks[ 2 ] = 0.0;
                seg.ks[ 3 ] = 0.0;
            }
            r[ n_seg ].x = src[ n_seg % n ].x;
            r[ n_seg ].y = src[ n_seg % n ].y;
            r[ n_seg ].pointType = src[ n_seg % n ].pointType;
            var dx: Float;
            var dy: Float;
            for( i in 0...n_seg ){
                dx = r[ i + 1 ].x - r[ i ].x;
                dy = r[ i + 1 ].y - r[ i ].y;
                r[ i ].dChord = hyp( dx, dy );
#if checkFitness
                if(     !Math.isFinite( dx ) 
                    ||  !Math.isFinite( dy ) 
                    ||  !Math.isFinite( ( r[ i ].dChord )) ) {
                    rValid = false;
                    break;
                }
#end
                r[ i ].segment_theta = Math.atan2( dy, dx );
#if checkFitness
            }
            if( rValid ){
#end
                var ilast = n_seg - 1;
                var pType: PointType;
                for( i in 0...n_seg ){
                    pType = r[ i ].pointType;
                    if( pType == OpenContour || pType == EndOpenContour || pType == Corner ){
                        r[ i ].bend_theta = 0.0;
                    } else {
                        r[ i ].bend_theta = mod2pi( r[ i ].segment_theta - r[ ilast ].segment_theta );
                    }
                    ilast = i;
                }
            }
#if checkFitness
        }
#end
        return r;
    }
    public static /* inline */ function bandec11( m: Vector<BandMatrix>, perm: Vector<Int>, n: Int ){
        var j2: Int;
        var pivot: Int;
        var pivotVal: Float;
        var pivotScale: Float;
        var temp: Float;
        var l: Int;
        var x: Float;
        // pack top triangle to the left.
        for( i in 0...5 ){
            var j2 = i + 6;
            for( j in 0...j2 ) m[ i ].a[ j ] = m[ i ].a[ j + 5 - i ];
            for( j in j2...11 ) m[ i ].a[ j ] = 0.0;
        }
        l = 5;
        for( k in 0...n ){
            pivot = k;
            pivotVal = m[ k ].a[ 0 ];
            l = if( l < n ){
                l + 1;
            } else {
                n;
            }
            for( j in (k + 1)...l ){
                if( Math.abs( m[ j ].a[ 0 ]) > Math.abs( pivotVal ) ){
                    pivotVal = m[ j ].a[ 0 ];
                    pivot = j;
                }
            }
            perm[ k ] = pivot;
            if( pivot != k ){
                for( j in 0...11 ){
                    temp = m[ k ].a[ j ];
                    m[ k ].a[ j ] = m[ pivot ].a[ j ];
                    m[ pivot ].a[ j ] = temp;
                }
            }
            if( Math.abs( pivotVal ) < 1e-12 ) pivotVal = 1e-12;
            pivotScale = 1.0 / pivotVal;
            for( i in ( k + 1 )...l ){
                x = m[ i ].a[0] * pivotScale;
                m[ k ].al[ i - k - 1 ] = x;
                for( j in 1...11 ) m[ i ].a[ j - 1 ] = m[ i ].a[ j ] - x * m[ k ].a[ j ];
                m[ i ].a[ 10 ] = 0.0;
            }
        }
    }
    public static /* inline */ function banbks11( m: Vector<BandMatrix>, perm: Vector<Int>, v: Vector<Float>, n: Int ){
        var tmp: Float;
        var x: Float;
        // forward substitution
        var l = 5;
        var i: Int;
        for( k in 0...n ){
            i = perm[ k ];
            if( i != k ){
                tmp = v[ k ];
                v[ k ] = v[ i ];
                v[ i ] = tmp;
            }
            if( l < n ) l++;
            for( i in ( k + 1 )...l ) v[i] -= m[ k ].al[ i - k - 1 ] * v[ k ];
        }
        // back substitution
        l = 1;
        i = n - 1;
        while( i >= 0 ){
            x = v[ i ];
            for( k in 1...l ) x -= m[ i ].a[ k ] * v[ k + i ];
            v[ i ] = x / m[ i ].a[ 0 ];
            if( l < 11 ) l++;
            i--;
        }
    }
    
    public static /* inline */ function pointTypeTrace( pointType: PointType ): String {
        return switch( pointType ){
            case Corner:
                'Corner';
            case G4:
                'G4';
            case G2:
                'G2';
            case Left:
                'Left';
            case Right:
                'Right';
            case End:
                'End';
            case OpenContour:
                'OpenContour';
            case EndOpenContour:
                'EndOpenContour';
        }
    }
    
    public static /* inline */ function computeJinc( ty0: PointType, ty1: PointType ){
        var jinc: Int = 0;
        if( ty0 == G4 || ty1 == G4 || ty0 == Right || ty1 == Left ){
            jinc = 4;
        } else if( ty0 == G2 && ty1 == G2 ){
            jinc = 2;
        } else if (
                    ( ( ty0 == OpenContour || ty0 == Corner || ty0 == Left ) && ty1 == G2 ) 
                    || 
                    ( ( ty1 == EndOpenContour || ty1 == Corner || ty1 == Right ) && ty0 == G2 )
                ){
            jinc = 1;
        } else {
            jinc = 0;
        }
        return jinc;
    }
    public static /* inline */ function countVec( s: Vector<Segment>, nseg: Int ){
        var n = 0;
        for( i in 0...nseg ) n += computeJinc( s[ i ].pointType, s[ i + 1 ].pointType);
        return n;
    }
    public static /* inline */ function addMatLine( m: Vector<BandMatrix>
                                            , v: Vector<Float>, derivs: Vector<Float>
                                            , x: Float, y: Float
                                            , j: Int, jj: Int, jinc: Int, nmat: Int ){
        var joff: Int;
        if( jj >= 0 ){
            joff = ( j + 5 - jj + nmat ) % nmat;
            if( nmat < 6 ){
                joff = j + 5 - jj;
            } else if ( nmat == 6 ){
                joff = 2 + ( j + 3 - jj + nmat ) % nmat;
            }
            v[jj] += x;
            for( k in 0...jinc ) {
                m[ jj ].a[ joff + k ] += y * derivs[ k ];
            }
        }
    }
    public static /* inline */ function spiroIter( s: Vector<Segment>, m: Vector<BandMatrix>
                                            , perm: Vector<Int>, v: Vector<Float>, n: Int, nmat: Int ){
        //int i, j, jthl, jthr, jk0l, jk0r, jk1l, jk1r, jk2l, jk2r, jinc, jj
        var dk: Float;
        var n_invert: Int;
        var ends = new Vector<Vector<Float>>(2);
        ends[ 0 ] = new Vector<Float>(4);
        ends[ 1 ] = new Vector<Float>(4);
        var derivs = new Vector<Vector<Vector<Float>>>(4);
        for( i in 0...4 ){
            derivs[ i ] = new Vector<Vector<Float>>(2);
            derivs[ i ][ 0 ] = new Vector<Float>(4);
            for( j in 0...4 ) derivs[ i ][ 0 ][ j ] = 0.;
            derivs[ i ][ 1 ] = new Vector<Float>(4);
            for( j in 0...4 ) derivs[ i ][ 1 ][ j ] = 0.;
        }
        var pType = s[0].pointType;
        var cyclic: Bool = pType != OpenContour && pType != Corner;
        for( i in 0...nmat ){
            v[ i ] = 0.0;
            for( j in 0...11 ) m[ i ].a[ j ] = 0.0;
            for( j in 0...5 )  m[ i ].al[ j ] = 0.0;
        }
        var j = 0;
        var pType = s[ 0 ].pointType;
        var jj: Int;
        if( pType == G4 ){
            jj = nmat - 2;
        } else if ( pType == G2 ){
            jj = nmat - 1;
        } else {
            jj = 0;
        }
        var ty0: PointType;
        var ty1: PointType;
        var jthl: Int;
        var jk0l: Int;
        var jk1l: Int;
        var jk2l: Int;
        var jthr: Int;
        var jk0r: Int;
        var jk1r: Int;
        var jk2r: Int;
        var jinc: Int;
        var th: Float;
        var norm: Float;
        for( i in 0...n ){
            ty0 = s[ i ].pointType;
            ty1 = s[ i + 1 ].pointType;
            jinc = computeJinc( ty0, ty1 );
            th = s[ i ].bend_theta;
            jthl = jk0l = jk1l = jk2l = -1;
            jthr = jk0r = jk1r = jk2r = -1;
            pderivs( s[ i ], ends, derivs, jinc );
            // constraints crossing left
            // this is as per java and js versions, c# has second if contained?
            if( ty0 == G4 || ty0 == G2 || ty0 == Left || ty0 == Right ){
                jthl = jj++;
                jj %= nmat;
                jk0l = jj++;
            }
            if( ty0 == G4 ){
                jj %= nmat;
                jk1l = jj++;
                jk2l = jj++;
            }
            // constraints on left
            if( (ty0 == Left || ty0 == Corner || ty0 == OpenContour || ty0 == G2) && jinc == 4 ){
                if( ty0 != G2 ) jk1l = jj++;
                jk2l = jj++;
            }
            // constraints on right
            if( (ty1 == Right || ty1 == Corner || ty1 == EndOpenContour || ty1 == G2) && jinc == 4 ){
                if( ty1 != G2 ) jk1r = jj++;
                jk2r = jj++;
            }
            // constraints crossing right
            // this is as per java and js versions, c# has second if contained?
            if( ty1 == G4 || ty1 == G2 || ty1 == Left || ty1 == Right ){
                jthr = jj;
                jk0r = (jj + 1) % nmat;
            }
            if( ty1 == G4 ){
                jk1r = (jj + 2) % nmat;
                jk2r = (jj + 3) % nmat;
            }
            addMatLine( m, v, derivs[0][0], th - ends[0][0], 1, j, jthl, jinc, nmat);
            addMatLine( m, v, derivs[1][0], ends[0][1], -1, j, jk0l, jinc, nmat);
            addMatLine( m, v, derivs[2][0], ends[0][2], -1, j, jk1l, jinc, nmat);
            addMatLine( m, v, derivs[3][0], ends[0][3], -1, j, jk2l, jinc, nmat);
            addMatLine( m, v, derivs[0][1], -ends[1][0], 1, j, jthr, jinc, nmat);
            addMatLine( m, v, derivs[1][1], -ends[1][1], 1, j, jk0r, jinc, nmat);
            addMatLine( m, v, derivs[2][1], -ends[1][2], 1, j, jk1r, jinc, nmat);
            addMatLine( m, v, derivs[3][1], -ends[1][3], 1, j, jk2r, jinc, nmat);
            if( jthl >= 0 ) v[ jthl ] = mod2pi( v[ jthl ] );
            if( jthr >= 0 ) v[ jthr ] = mod2pi( v[ jthr ] );
            j += jinc;
        }
        if( cyclic ){
            BandMatrix.copy( m, 0, m, nmat, nmat );
            BandMatrix.copy( m, 0, m, 2 * nmat, nmat );
            copyFloats( v, 0, v, nmat, nmat );  // TODO: Fix this
            copyFloats( v, 0, v, 2 * nmat, nmat );
            n_invert = 3 * nmat;
            j = nmat;
        } else {
            n_invert = nmat;
            j = 0;
        }
        bandec11( m, perm, n_invert );
        banbks11( m, perm, v, n_invert );
        norm = 0.0;
        for( i in 0...n ){
            jinc = computeJinc( s[ i ].pointType, s[i + 1].pointType );
            for( k in 0...jinc ){
                dk = v[ j++ ];
                s[ i ].ks[ k ] += dk;
                norm += dk * dk;
            }
            s[ i ].ks[ 0 ] = 2.0 * mod2pi( s[ i ].ks[ 0 ] / 2.0);
        }
        return norm;
    }
#if checkFitness
    // consider rearrange returns at end to allow /* inline */?
    public static function checkFiniteness( segs: Vector<Segment>, len: Int ): Bool {
        // Check if all values are "finite", return true, else return fail=false
        for( i in 0...len ){
            for( j in 0...4 ){
                if( Math.isFinite( segs[ i ].ks[ j ] ) ) return false;
            }
        }
        return true;
    }
#end
    public static function solve( s: Vector<Segment>, nseg: Int ){
        var nmat = countVec( s, nseg );
        var n_alloc = nmat;
        var norm: Float;
        if( nmat == 0 ) return 1; // just means no convergence problems
        var pType = s[ 0 ].pointType;
        if(  pType != OpenContour && pType != Corner ) n_alloc *= 3;
        if( n_alloc < 5 )n_alloc = 5;
        var m = new Vector<BandMatrix>(n_alloc);
        for( n in 0...n_alloc ){
            m[n] = new BandMatrix();
            //m[n].a = new Vector<Float>(11);
            //m[n].al = new Vector<Float>(5);
        }
        var v = new Vector<Float>( n_alloc );
        for( i in 0...n_alloc ) v[ i ] = 0.0;
        var perm = new Vector<Int>( n_alloc );
        for( i in 0...n_alloc ) perm[ i ] = 0;
        var i = 0;
        var converged = 0; // not solved (yet)
        if( m != null && v != null && perm != null ){
            while( i++ < 60 ){
                norm = spiroIter( s, m, perm, v, nseg, nmat );
#if checkFitness
                if( checkFiniteness( s, nseg ) ) break;
#end
                if( norm < 1e-12 ){
                    converged = 1;
                    break;
                }
            }
        }
        return converged;
    }
    public static /* inline */ function spiro_seg_to_bpath( ks: Vector<Float>
                                                    , x0: Float, y0: Float
                                                    , x1: Float, y1: Float
                                                    , bc: IBezierContext
                                                    , depth: Int ){
        var th_even: Float;
        var th_odd: Float;
        var rot: Float;
        var ul: Float;
        var vl: Float;
        var ur: Float;
        var vr: Float;
        var scale: Float;
        var ksub = new Vector<Float>(4);
        var bend = Math.abs( ks[ 0 ] ) + Math.abs( 0.5 * ks[ 1 ] ) + Math.abs( 0.125 * ks[ 2 ] ) + Math.abs( ( 1.0 / 48 ) * ks[ 3 ]);
        var p: Point = { x: 0., y: 0. };
        var pSub: Point = { x: 0., y: 0. };
        if( bend <= 1e-8 ){
            bc.lineTo( x1, y1 );
        } else {
            var dChord = hyp( x1 - x0, y1 - y0 );
            var segment_theta = Math.atan2( y1 - y0, x1 - x0 );
            integrate( ks, p, N );
            var ch = hyp( p.x, p.y );
            var th = Math.atan2( p.y, p.x );
            scale = dChord / ch;
            rot = segment_theta - th;
            if( depth > 5 || bend < 1.0 ){
                th_even = (1.0 / 384) * ks[3] + (1.0 / 8) * ks[1] + rot;
                th_odd = (1.0 / 48) * ks[2] + 0.5 * ks[0];
                ul = (scale * (1.0 / 3)) * Math.cos( th_even - th_odd );
                vl = (scale * (1.0 / 3)) * Math.sin( th_even - th_odd );
                ur = (scale * (1.0 / 3)) * Math.cos( th_even + th_odd );
                vr = (scale * (1.0 / 3)) * Math.sin( th_even + th_odd );
                bc.curveTo( x0 + ul, y0 + vl, x1 - ur, y1 - vr, x1, y1 );
            } else {
                // subdivide
                ksub[ 0 ] = .5 * ks[ 0 ] - .125 * ks[ 1 ] + (1.0 / 64) * ks[ 2 ] - (1.0 / 768) * ks[ 3 ];
                ksub[ 1 ] = .25 * ks[ 1 ] - (1.0 / 16) * ks[ 2 ] + (1.0 / 128) * ks[ 3 ];
                ksub[ 2 ] = .125 * ks[ 2 ] - (1.0 / 32) * ks[ 3 ];
                ksub[ 3 ] = (1.0 / 16) * ks[3];
                var thsub = rot - .25 * ks[0] + (1.0 / 32) * ks[ 1 ] - (1.0 / 384) * ks[ 2 ] + (1.0 / 6144) * ks[ 3 ];
                var cth = .5 * scale * Math.cos( thsub );
                var sth = .5 * scale * Math.sin( thsub );
                integrate( ksub, pSub, N );
                var xmid = x0 + cth * pSub.x - sth * pSub.y;
                var ymid = y0 + cth * pSub.y + sth * pSub.x;
                spiro_seg_to_bpath( ksub, x0, y0, xmid, ymid, bc, depth + 1);
                ksub[0] += .25 * ks[ 1 ] + (1.0 / 384) * ks[ 3 ];
                ksub[1] += .125 * ks[ 2 ];
                ksub[2] += (1.0 / 16) * ks[ 3 ];
                spiro_seg_to_bpath( ksub, xmid, ymid, x1, y1, bc, depth + 1 );
            }
        }
    }
    public static /* inline */ function runSpiro( src: Vector<ControlPoint>, n: Int ){
        var out: Vector<Segment> = null;
        if( src == null || n <= 0 ) {
            trace( 'src is null || n is less or equal to 0' );
            // return
        } else {
            var converged: Int;
            var nseg: Int;
            var s = setupPath( src, n );
            if( s != null ){
                nseg = src[ 0 ].pointType == OpenContour ? n - 1 : n;
                converged = 1; // this value is for when nseg == 1; else actual value determined below
                if( nseg > 1 ) converged = solve( s, nseg );
                if (converged != 0) {
                    out = s;
                }
            }
        }
        return out;
    }
    public static /* inline */ function spiro_to_bpath( s: Vector<Segment>, n: Int, bc: IBezierContext ){
        var s0: Segment;
        var s1: Segment;
        if (s == null || n <= 0 || bc == null ) {
            // return early
        } else {
            var x0: Float;
            var y0: Float;
            var x1: Float;
            var y1: Float;
            var nsegs = s[n - 1].pointType == EndOpenContour ? n - 1 : n;
            for( i in 0...nsegs ){
                s0 = s[ i ];
                x0 = s0.x;
                s1 = s[ i + 1 ];
                x1 = s1.x;
                y0 = s0.y; 
                y1 = s1.y;
                if (i == 0) bc.moveTo( x0, y0, s[ 0 ].pointType == OpenContour ? true : false );
                bc.markKnot( i, get_knot_th( s, i ), s0.x, s0.y, s0.pointType );
                spiro_seg_to_bpath( s0.ks, x0, y0, x1, y1, bc, 0 );
            }
            if( nsegs == n - 1 ){
                bc.markKnot( n - 1, get_knot_th( s, n - 1 ), s[ n - 1 ].x, s[ n - 1 ].y, s[ n - 1 ].pointType );
            }
        }
    }
    public static /* inline */ function get_knot_th( s: Vector<Segment>, i: Int ){
        var ends = new Vector<Vector<Float>>(2);
        ends[ 0 ] = new Vector<Float>( 4 );
        ends[ 1 ] = new Vector<Float>( 4 );
        var out: Float = 0.;
        if( i == 0 ){
            computeEnds( s[ i ].ks, ends, s[ i ].dChord );
            out = s[ i ].segment_theta - ends[ 0 ][ 0 ];
        } else {
            computeEnds( s[ i - 1 ].ks, ends, s[ i - 1 ].dChord );
            out = s[ i - 1 ].segment_theta + ends[ 1 ][ 0 ];
        }
        return out;
    }
}
