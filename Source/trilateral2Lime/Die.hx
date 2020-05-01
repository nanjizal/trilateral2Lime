package trilateral2Lime;
import trilateral2.Pen;
import trilateral2.Shaper;
import trilateral2.IndexRange;
import trilateral2.DieSpots;
import geom.matrix.Matrix4x3;
import geom.flat.f32.Float32FlatTriangle;
import trilateral2.Regular;
import trilateral2.RegularShape;
import geom.obj.CubeTransforms;
/**
left
5
1 3 6 4
2
right
4
1 2 6 5
3
*/
@:structInit
class Die{
    var left: LeftisRight = RIGHT;
    var spots: DieSpots;
    var spotShape: RegularShape = { x: 0., y: 0., radius: 15., color: 0xfff0ffff };
    var dieShape:  RegularShape = { x: 0., y: 0., radius: 60., color: 0xc0ff0000 };
    public
    function new( pen: Pen ){
        this.spots = pen;
    }
    public inline
    function one( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.goldOne( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public inline
    function two( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.two( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public inline
    function three( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.three( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public inline
    function four( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.four( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public inline
    function five( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.five( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public inline 
    function six( trans: Matrix4x3 ): IndexRange {
        var s0 = spots.roundedSquare( dieShape );
        spots.down( s0 );
        var s1 = spots.colorSix( spotShape );
        var s2: IndexRange = { start: s0.start, end: s1.end };
        spots.transformRange( trans, s2 );
        return s2;
    }
    public function create( x: Float, y: Float ): IndexRange {
        spotShape.x = x;
        spotShape.y = y;
        dieShape.x  = x;
        dieShape.y  = y;
        var diceRadius = dieShape.radius * 1/Main.stageRadius;
        var trans = CubeTransforms.getDieLayout({radius: diceRadius, isLeft: left } );
        var s6 = six(   trans[5] );
        var s2 = two(   trans[1] );
        var s3 = three( trans[2] );
        var s4 = four(  trans[3] );
        var s5 = five(  trans[4] );
        var s1 = one(   trans[0] );
        var startEnd: IndexRange = { start: s6.start, end: s1.end };
        //spots.transformRange( Matrix4x3.unit.scale( .5 ), startEnd );
        return startEnd;
    }
}