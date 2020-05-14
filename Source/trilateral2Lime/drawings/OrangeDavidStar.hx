package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class OrangeDavidStar extends DrawingLayout{
    override public function draw(){
        var len = Shaper.overlapStar( pen.drawType
                                    , ( bottomLeft.x + centre.x )/2
                                    , ( bottomLeft.y + centre.y )/2, size  );
        pen.colorTriangles( Orange, len );
    }
}
