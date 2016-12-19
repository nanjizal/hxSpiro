package;
import js.Browser;
import js.html.svg.SVGElement;
import js.html.Element;
import js.html.svg.PathElement;
import js.html.CSSStyleDeclaration;
import hxSpiro.Spiro;
import hxSpiro.SvgPathContext;
import svg.SvgRoot;
import svg.SvgPath;
import js.html.Event;
import js.html.MouseEvent;
import haxe.ds.Vector;
// Test with SVG
class Main{
    var svgRoot: SvgRoot;
    public static function main(){ 
        new Main();
    } 
    function new(){
        trace( 'Example of Spiro' );
        var doc = Browser.document;
        svgRoot = new SvgRoot();
        svgRoot.width = 1024;
        svgRoot.height = 1024;
        doc.body.addEventListener( 'mousedown', addPoint );
        testCircle({ x: 100., y: 100. }, 100., 100.,0xF7931E);
        //testCurve();
    }
    var arr = new Array<ControlPoint>();
    var totAdded: Int = 0;
    var tot: Int = 30;
    public function addPoint( e: MouseEvent ){
        var p: Point =  { x: e.clientX - 3, y: e.clientY - 3 };
        testCircle( p, 6, 6, 0xFF0000 );
        var pointType: PointType;
        var last = (tot-1);
        if( totAdded == 0 ){
            pointType = OpenContour;
        } else if ( totAdded == last ){
            pointType = EndOpenContour;
        } else {
            pointType = G4;
        }
        if( totAdded < tot ){
            arr[ totAdded ] = cast { x: p.x, y: p.y, pointType: pointType };
            totAdded++;
        } else if( totAdded == tot ){
            testRandom();
        }
    }
    function testRandom(){
        var curvePath = new SvgPath();
        curvePath.color = 0xFF00FF;
        curvePath.thickness = 2;
        curvePath.noFill();
        var points = new Vector<ControlPoint>( totAdded );
        for( p in 0...arr.length ) points[p] = arr[p]; 
        var bc = new SvgPathContext();
        Spiro.taggedSpiroCPsToBezier0( points, bc );
        curvePath.path = bc.d;
        svgRoot.appendChild( curvePath );
    }
    function testCircle( point, x: Float, y: Float, color: Int ){
        var circlePath = new SvgPath();
        circlePath.fill = color;
        var points = circle( point, x, y );
        var bc = new SvgPathContext();
        Spiro.spiroCPsToBezier0( points, 4, true, bc );
        circlePath.path = bc.d;
        svgRoot.appendChild( circlePath );
    }
    function testCurve(){
        var curvePath = new SvgPath();
        curvePath.color = 0xFF00FF;
        curvePath.thickness = 2;
        curvePath.noFill();
        var points = openCurve( { x: 200., y: 200. }, 100., 100. );
        var bc = new SvgPathContext();
        Spiro.taggedSpiroCPsToBezier0( points, bc );
        curvePath.path = bc.d;
        svgRoot.appendChild( curvePath );
    }
    function openCurve( centre: Point, dw: Float, dh: Float ){
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
    function circle( centre: Point, dw: Float, dh: Float ): Vector<ControlPoint> {
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
