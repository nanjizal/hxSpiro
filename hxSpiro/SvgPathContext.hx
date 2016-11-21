package hxSpiro;
import hxSpiro.Spiro;// PointType
import hxSpiro.IBezierContext;
class SvgPathContext implements IBezierContext {
    var _d: String;
    public function new(){
        _d = '';
    }
    public var d( get, never ): String;
    public function get_d():String {
        return _d + 'z';
    }
    public function moveTo( x: Float, y: Float, isOpen: Bool ): Void {
        _d += 'M $x $y '; // ignoring isOpen?
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
