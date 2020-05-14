package trilateral2Lime.drawings;
import trilateral2Lime.drawings.DrawingLayout;
// Color pallettes
import pallette.QuickARGB;
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
import trilateral2Lime.helpers.PathTests; // quadtest_d

class OrangeBirdOutline extends DrawingLayout{
    override public function draw(){
        pen.currentColor = Orange;
        var sketch = new Sketch( pen, SketchForm.Fine, EndLineCurve.both );
        sketch.width = 3.2;
        var scaleTranslateContext = new ScaleTranslateContext( sketch, 0, 0, 1.5, 1.5 );
        var p = new SvgPath( scaleTranslateContext );
        p.parse( bird_d );
    }
}