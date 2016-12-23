package hxSpiro;
import haxe.ds.Vector;
import hxSpiro.Spiro;
// class to contain test Shapes
class SpiroShapes{
    public static inline function openCurveTest( centre: Point, dw: Float, dh: Float ): Vector<ControlPoint> {
        var points = new Vector<ControlPoint>(4);
        var rw = dw/2;
        var rh = dh/2;
        points[ 0 ] = cast { x: -rw, y: 0, pointType: OpenContour };
        points[ 1 ] = cast { x: 0, y: rh, pointType: G4 };
        points[ 2 ] = cast { x: rw, y: 0, pointType: G4 };
        points[ 3 ] = cast { x: 0, y: -rh, pointType: EndOpenContour };
        for( p in points ){
            p.x += centre.x + rw;
            p.y += centre.y + rh;
        }
        return points;
    }
    public static inline function circle( centre: Point, dw: Float, dh: Float ): Vector<ControlPoint> {
        var points = new Vector<ControlPoint>(5);
        var rw = dw/2;
        var rh = dh/2;
        points[ 0 ] = cast { x: -rw, y: 0, pointType: G4 };
        points[ 1 ] = cast { x: 0, y: rh, pointType: G4 };
        points[ 2 ] = cast { x: rw, y: 0, pointType: G4 };
        points[ 3 ] = cast { x: 0, y: -rh, pointType: G4 };
        points[ 4 ] = cast { x: 0, y: 0, pointType: End };
        for( p in points ){
            p.x += centre.x + rw;
            p.y += centre.y + rh;
        }
        return points;
    }
}
