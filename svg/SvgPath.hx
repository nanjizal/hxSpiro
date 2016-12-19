package svg;
import js.Browser;
import js.html.svg.PathElement;
abstract SvgPath( PathElement ) from PathElement to PathElement {
    inline public function new( ?e: PathElement ){
        if( e == null ){
            this = create();
        } else {
            this = e;
        }
    }
    inline static public function create(): PathElement {
        var doc = Browser.document;
        var svgPath: PathElement = cast doc.createElementNS( SvgRoot.svgNameSpace, 'path' );
        return svgPath;
    }
    public var fill( get, set ): Int;
    public inline function set_fill( v: Int ): Int{
        this.setAttribute( 'fill', '#' + StringTools.hex( v, 6 ));
        return v;
    }
    public inline function get_fill():Int {
        var s = this.getAttribute( 'fill' );
        return Std.parseInt( StringTools.ltrim( '#' ) );
    }
    public function noFill(){
        this.setAttribute( 'fill', 'transparent' );
    }
    public var path( get, set ): String;
    public inline function set_path( d: String ){
        this.setAttribute( 'd', d );
        return d;
    }
    public inline function get_path(): String {
        return this.getAttribute( 'd' );
    }
    public var color( get, set ): Int;
    public inline function set_color( v: Int ): Int {
        this.setAttribute( 'stroke', '#' + StringTools.hex( v, 6 ));
        return v;
    }
    public inline function get_color(): Int {
        var s = this.getAttribute( 'stroke' );
        return Std.parseInt( StringTools.ltrim( '#' ) );
    }
    public var thickness( get, set ): Float;
    public inline function set_thickness( v: Float ): Float {
        this.setAttribute( 'stroke-width', Std.string( v ) );
        return v;
    }
    public inline function get_thickness(): Float {
        return Std.parseFloat( this.getAttribute( 'stroke-width' ) );
    }
}
