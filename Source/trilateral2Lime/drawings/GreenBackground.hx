package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class GreenBackground extends DrawingLayout{
    override public function draw(){
        var len = Shaper.square( pen.drawType
                            , centre.x
                            , centre.y,  600 );
        pen.colorTriangles( Green, len );
    }
}