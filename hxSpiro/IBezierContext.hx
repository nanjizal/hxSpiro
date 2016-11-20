package hxSpiro;

import hxSpiro.Spiro;// PointType

interface IBezierContext{
    /// <summary>
    /// Called by spiro to start a contour.
    /// </summary>
    /// <param name="x">The X coordinate of the new start point.</param>
    /// <param name="y">The Y coordinate of the new start point.</param>
    /// <param name="isOpen">An boolean flag indicating wheter spline is open (True) or closed (False).</param>
    function moveTo( x: Float, y: Float, isOpen: Bool ): Void;

    /// <summary>
    /// Called by spiro to move from the last point to the next one on a straight line.
    /// </summary>
    /// <param name="x">The X coordinate of the new end point.</param>
    /// <param name="y">The Y coordinate of the new end point.</param>
    function lineTo( x: Float, y: Float ): Void;

    /// <summary>
    /// Called by spiro to move from the last point to the next along a quadratic bezier spline
    /// (x1,y1) is the quadratic bezier control point and (x2,y2) will be the new end point.
    /// </summary>
    /// <param name="x1">The X coordinate of quadratic bezier bezier control point.</param>
    /// <param name="y1">The Y coordinate of quadratic bezier bezier control point.</param>
    /// <param name="x2">The X coordinate of the new end point.</param>
    /// <param name="y2">The Y coordinate of the new end point.</param>
    function quadTo( x1: Float, y1: Float, x2: Float, y2: Float ): Void;

    /// <summary>
    /// Called by spiro to move from the last point to the next along a cubic bezier spline
    /// (x1,y1) and (x2,y2) are the two off-curve control point and (x3,y3) will be the new end point.
    /// </summary>
    /// <param name="x1">The X coordinate of first cubic bezier spline off-curve control point.</param>
    /// <param name="y1">The Y coordinate of first cubic bezier spline off-curve control point.</param>
    /// <param name="x2">The X coordinate of second cubic bezier spline off-curve control point.</param>
    /// <param name="y2">The Y coordinate of second cubic bezier spline off-curve control point.</param>
    /// <param name="x3">The X coordinate of the new end point.</param>
    /// <param name="y3">The Y coordinate of the new end point.</param>
    function curveTo( x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float ): Void;

    /// <summary>
    /// Called by spiro to mark current control point knot.
    /// </summary>
    /// <param name="index">The spiros control point knot index.</param>
    /// <param name="theta">The spiros control point knot theta angle.</param>
    /// <param name="x">The spiros control point X location.</param>
    /// <param name="y">The spiros control point Y location.</param>
    /// <param name="type">The spiros control point type.</param>
    function markKnot( index: Int, theta: Float, x: Float, y: Float, type: PointType ): Void;
}
