package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class BorderRed extends DrawingLayout{
    override public function draw(){
        var len = Shaper.squareOutline( pen.drawType
                            , centre.x, centre.y, 600, 20 );
        pen.colorTriangles( Red, len );
    }
}