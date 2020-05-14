package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Shaper for drawing shapes
import trilateral2.Shaper;
// Color pallettes
import pallette.QuickARGB;
class YellowDiamond extends DrawingLayout{
    override public function draw(){
        var len = Shaper.diamond( pen.drawType
                                , ( topLeft.x + centre.x )/2
                                , ( topLeft.y + centre.y )/2
                                , 0.7*size );
        pen.colorTriangles( Yellow, len );
    }
}