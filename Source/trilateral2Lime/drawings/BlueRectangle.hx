package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class BlueRectangle extends DrawingLayout{
    override public function draw(){
        var len = Shaper.rectangle( pen.drawType
                              , centre.x - 100, centre.y - 50
                              , size*2, size );
        pen.colorTriangles( Blue, len );
    }
}