package;
import js.Browser;
import js.html.svg.SVGElement;
import js.html.Element;
import js.html.svg.PathElement;
import js.html.CSSStyleDeclaration;
import hxSpiro.Spiro;
import hxSpiro.SvgPathContext;
import haxe.ds.Vector;
// Test with SVG
class Main{
    inline public static var svgNameSpace: String = "http://www.w3.org/2000/svg" ;
    public static function main(){ 
        new Main();
    } 
    function new(){
        trace( 'Example of Spiro' );
        var doc = Browser.document;
        var svgElement: SVGElement = cast doc.createElementNS( svgNameSpace, 'svg' );
        var element: Element = cast svgElement;
        var style: CSSStyleDeclaration = element.style;
        style.paddingLeft = "0px";
        style.paddingTop = "0px";
        style.left = Std.string( 0 + 'px' );
        style.top = Std.string( 0 + 'px' );
        style.position = "absolute";
        Browser.document.body.appendChild( element );
        var svgPath: PathElement = cast doc.createElementNS( svgNameSpace, 'path' );
        svgPath.setAttribute("fill", "#F7931E");
        var d = createSpiroSvgPath();
        trace( d );
        svgPath.setAttribute( "d", d );
        svgElement.appendChild( svgPath );
    }
    public function createSpiroSvgPath():String {
        var points = new Vector<ControlPoint>(4);
        var p0: ControlPoint = { x: -100, y: 0, pointType: G4 };
        var p1: ControlPoint = { x: 0, y: 100, pointType: G4 };
        var p2: ControlPoint = { x: 100, y: 0, pointType: G4 };
        var p3: ControlPoint = { x: 0, y: -100, pointType: G4 };
        points[ 0 ] = p0;
        points[ 1 ] = p1;
        points[ 2 ] = p2;
        points[ 3 ] = p3;
        var bc = new SvgPathContext();
        trace( 'd calculated ' + Spiro.spiroCPsToBezier0( points, 4, true, bc ) );
        return bc.d;
    }
}
