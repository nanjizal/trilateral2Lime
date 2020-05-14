package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class RedRoundedRectangleOutline extends DrawingLayout{
    override public function draw(){
        var len = Shaper.roundedRectangleOutline( pen.drawType
                                    , topLeft.x - size
                                    ,( topLeft.y + bottomLeft.y )/2 - size/2
                                    , size*2, size,  6, 30 );
        pen.colorTriangles( Red, len );
    }
}