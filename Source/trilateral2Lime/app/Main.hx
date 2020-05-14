package trilateral2Lime.app;

import lime.graphics.RenderContext;
import lime.graphics.WebGLRenderContext;
import lime.app.Application;
import trilateral2Lime.app.AppGL;
import trilateral2Lime.app.NonGL; 
class Main extends Application {
    var ready: Bool = false;
    var runSeconds: Float = 0; // maybe delay to start.
    var other: NonGL;
    var appGL: AppGL;
    public function new() {
        super();
    }
    public override
    function onWindowCreate (): Void {
        var context = window.context;
        other = new NonGL( window.width, window.height);
        appGL = new AppGL( window.width, window.height);
        switch( context.type ){
            case OPENGL, OPENGLES, WEBGL:
                appGL.setup( context.webgl );
            default:
                other.setup( context );
        }
        ready = true;
    }
    public override
    function update( deltaTime: Int ): Void {
        runSeconds = deltaTime /1000;   
        if( !ready ) return;
        other.update();
        appGL.update();
    }
    public override
    function render ( context: RenderContext ): Void {
        if( !ready ) return;
        switch( context.type ){
            case OPENGL, OPENGLES, WEBGL:
                appGL.render( context.webgl );
            default:
                other.render( context );
        }
    }
}