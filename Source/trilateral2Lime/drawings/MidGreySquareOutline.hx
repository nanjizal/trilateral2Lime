package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class MidGreySquareOutline extends DrawingLayout{
    override public function draw(){
        var len = Shaper.squareOutline( pen.drawType
                            , ( bottomRight.x + centre.x )/2
                            , ( bottomRight.y + centre.y )/2, 0.7*size, 6 );
        pen.colorTriangles( Red, len );
    }
}