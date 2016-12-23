package hxSpiro;
import hxSpiro.Spiro;// PointType
import hxSpiro.IBezierContext;
class SvgPathContext implements IBezierContext {
    var _d: String;
    var _isOpen: Bool;
    public function new(){
        _d = '';
    }
    public var d( get, never ): String;
    public function get_d():String {
        if( _isOpen ){
            var len = _d.length;
            _d.substr( 0, _d.length - 1 );
        } else {
            _d + 'z';
        }
        return _d;
    }
    public function moveTo( x: Float, y: Float, isOpen_: Bool ): Void {
        _isOpen = isOpen_;
        _d += 'M $x $y ';
    }
    public function lineTo( x: Float, y: Float ): Void {
        _d += 'L $x $y ';
    }
    public function quadTo( x1: Float, y1: Float, x2: Float, y2: Float ): Void {
        _d += 'Q $x1 $y1, $x2 $y2 ';
    }
    public function curveTo( x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float ): Void {
        _d += 'C $x1 $y1, $x2 $y2, $x3 $y3 ';
    }
    // not used ??
    public function markKnot( index: Int, theta: Float, x: Float, y: Float, type: PointType ): Void {
    }
}
