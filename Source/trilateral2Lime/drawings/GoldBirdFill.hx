package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Color pallettes
import pallette.QuickARGB;
import pallette.Gold;
// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;
// Sketching
import trilateral2.EndLineCurve;
import trilateral2.Sketch;
import trilateral2.SketchForm;
import trilateral2.Fill;
// SVG paths
import trilateral2Lime.helpers.PathTests; // poly2trihxText

class GoldBirdFill extends DrawingLayout{
    override public function draw(){
        pen.currentColor = periniNavi;
        var sketch = new Sketch( pen, SketchForm.FillOnly, EndLineCurve.both );
        sketch.width = 2;
        var scaleTranslateContext = new ScaleTranslateContext( sketch, 0, 0, 1.5, 1.5 );
        var p = new SvgPath( scaleTranslateContext );
        p.parse( bird_d );
        /*
    tess2;
    polyK;
    poly2tri;
        */
        Fill.triangulate( pen, sketch, tess2 );
    }
}