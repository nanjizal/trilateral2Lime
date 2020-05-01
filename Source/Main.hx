package;
import lime.app.Application;
import lime.graphics.cairo.CairoImageSurface;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.Image;
import lime.ui.Window;
import lime.graphics.RenderContext;
import lime.graphics.WebGLRenderContext;
import lime.math.Matrix4;
import lime.utils.Assets;
import lime.utils.Float32Array;
import lime.ui.KeyModifier;
import lime.ui.KeyCode;
// generic typed arrays
import haxe.io.UInt16Array;
import haxe.io.Float32Array;
import haxe.io.Int32Array;

import htmlHelper.tools.DivertTrace;


// Maths mostly matrix trasforms
import geom.matrix.Matrix4x3;
import geom.matrix.Matrix4x4;
import geom.matrix.Quaternion;
import geom.matrix.DualQuaternion;
import geom.matrix.Matrix1x4;
import geom.move.Axis3;
import geom.move.Trinary;
import geom.matrix.Projection;
import geom.matrix.Matrix1x2;
import geom.flat.f32.Float32FlatRGBA;
import geom.flat.f32.Float32FlatTriangle;
import geom.flat.f32.Float32FlatTriangleXY;
import geom.flat.ui16.UInt16Flat3;
import geom.flat.i32.Int32Flat3;

// Trilateral Contour Drawing Tools
import trilateral2.Algebra;
import trilateral2.Pen;
import trilateral2.DrawType;
import trilateral2.ColorType;
import trilateral2.Shaper;
import trilateral2.Contour;
import trilateral2.EndLineCurve;
import trilateral2.Sketch;
import trilateral2.SketchForm;
import trilateral2.Fill;
import trilateral2.ArrayTriple;

import trilateral2Lime.GridLines;
import trilateral2Lime.Die;
import trilateral2.IndexRange;

#if flash
import flash.display.Bitmap;
#end
using Main;
class Main extends Application {
    /**
     *  set to false to stop update and render code from running at beginning.
     */
    var start: Bool = false;
    /**
     * depth test Bool similar to cull.
     */
    var DEPTH_TEST      = true;
    /**
     * cull face Bool ( remove faces that are obscured by other faces )
     */
    var CULL_FACE       = true; 
    /**
     * backface Bool ( when you flip an image in 3D it defines it should render back ).
     */
    var BACK            = true;
    var gl: WebGLRenderContext;
    /**
     * simple color vertex shader
     */
    public static inline var vertexColor: String =
        'attribute vec3 pos;' +
        'attribute vec4 color;' +
        'varying vec4 vcol;' +
        'uniform mat4 modelViewProjection;' +
        'void main(void) {' +
            ' gl_Position = modelViewProjection * vec4(pos, 1.);' +
            ' vcol = color;' +
        '}';
    /**
     * simple color fragmenh shader
     */
    public static inline var fragmentColor: String =
        #if !desktop
            "precision mediump float;" +
        #end
        'varying vec4 vcol;' +
        'void main(void) {' +
            ' gl_FragColor = vcol;' +
        '}';
    public inline static var stageRadius: Int = 600;
    var glMatrixUniform:         GLUniformLocation;
    var glProgram:               GLProgram;
    var glVertexAttribute:       Int;
    var glColorAttribute:        Int;

    static final largeEnough    = 2000000;
    var scale:                  Float;
    var verts                   = new Float32FlatTriangle( largeEnough );
    var textPos                 = new Float32FlatTriangleXY( largeEnough );
    var cols                    = new Float32FlatRGBA(largeEnough);
    var ind                     = new Int32Flat3(largeEnough);
    var model                   = DualQuaternion.zero;
    var pen:                    Pen;
    function resetPosition(): Void model =  DualQuaternion.zero;
    function setupSideTrace() new DivertTrace();
    /**
     * name used in vertex shader for coordinate data
     */
    public static var posName         = 'pos';
    /** 
     * name used in vertex shader for color data
     */
    public static var colorName       = 'color';
    /**
     * name used in vertex shader for texture uv data
     */
    public static var textureName     = 'aTexture';
    /**
     * transform matrix used in shader
     **/
    var matrix32Array   : Float32Array; 
    /** 
     * vertices array provide to shader
     */
    var vertices               = new Float32Array(100);
    /**
     * indices array provided to shader
     */
    var indices                = new Int32Array(100);
    /** 
     * colors array provided to shader
     */
    var colors                 = new Float32Array(100);
    public 
    function new (){ 
        super();
        setupSideTrace();
    }
    public override
    function onWindowCreate (): Void {
        var context = window.context;
        matrix32Array     = ident();
        switch( context.type ){
            case CAIRO:
            // NOT YET IMPLEMENTED
            case CANVAS:
            // NOT YET IMPLEMENTED see JustDrawing
            case DOM:
            // NOT YET IMPLEMENTED see JustDrawing
            case FLASH:
            // NOT YET IMPLEMENTED see JustDrawing
            case OPENGL, OPENGLES, WEBGL:
                gl = context.webgl;
                glProgram          = GLProgram.fromSources( gl, vertexColor, fragmentColor );
                gl.useProgram ( glProgram );
                
                gl.blendFunc( gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA );
                // gl.blendFunc(RenderingContext.ONE, RenderingContext.ONE_MINUS_SRC_ALPHA);
                gl.enable( gl.BLEND );
                
                pen                    = Pen.create( verts, cols );
                pen.transformMatrix    = scaleToGL();
                Shaper.transformMatrix = scaleToGL();
                var gridLines = new GridLines( pen, stageRadius );
                gridLines.draw( 10, 0x0396FB00, 0xF096FBF3 );
                verts.transform( Matrix4x3.unit.translateXYZ( 0., 0., -0.2 ) );
                var die     = new Die( pen );
                startEnd  = die.create( stageRadius, stageRadius );
                sceneModel = axisModel;
                uploadVectors();
            default:
        }
        start = true;
    }
    var startEnd: IndexRange;
    function updateDie():Void{
        //angle = -Math.PI/100;
        var modelDie = DualQuaternion.zero;
        modelDie  = itemModel.updateCalculate( modelDie );
        var trans: Matrix4x3 = modelDie;
        verts.transformRange( trans, startEnd.start, startEnd.end );
    }
    public override
    function render ( context: RenderContext ): Void {
        if( !start ) return;
        switch( context.type ){
            case CAIRO:
            // NOT YET IMPLEMENTED
            case CANVAS:
            // NOT YET IMPLEMENTED see JustDrawing
            case DOM:
            // NOT YET IMPLEMENTED see JustDrawing
            case FLASH:
            // NOT YET IMPLEMENTED see JustDrawing
            case OPENGL, OPENGLES, WEBGL:
                gl.viewport( 0, 0, window.width, window.height );
                
                // unsure on these settings
                if( DEPTH_TEST ) gl.enable( gl.DEPTH_TEST );
                gl.depthMask( false );
                if( CULL_FACE )  gl.enable( gl.CULL_FACE ); 
                //gl.disable(gl.CULL_FACE);
                if( BACK )       gl.cullFace( gl.BACK );
                // unsure on this setting
                gl.colorMask(false, false, false, true);
                
                var r = ((context.attributes.background >> 16) & 0xFF) / 0xFF;
                var g = ((context.attributes.background >> 8) & 0xFF) / 0xFF;
                var b = (context.attributes.background & 0xFF) / 0xFF;
                var a = ((context.attributes.background >> 24) & 0xFF) / 0xFF;
                gl.clearColor( r, g, b, a );
                gl.clear( gl.COLOR_BUFFER_BIT );
                var modelViewProjectionID = gl.getUniformLocation( glProgram, 'modelViewProjection' );
                /// you can update matrix32Array in the render loop.
                gl.uniformMatrix4fv( modelViewProjectionID, false, untyped matrix32Array );
                gl.drawArrays( gl.TRIANGLES, 0, indices.length );
            default:
        }
    }
    public override
    function update( deltaTime: Int ): Void {   
        if( !start ) return;
        // deltaTime /1000;
        updateDie();
        model  = axisModel.updateCalculate( model );
        var trans: Matrix4x3 = (  offset * model ).normalize();
        ( Projection.perspective() * trans ).updateWebGL( untyped matrix32Array );
    }
    function transformVerticesToGL() verts.transformAll( scaleToGL() );
    function scaleToGL(){
        scale = 1/(stageRadius);
        var v = new Matrix1x4( { x: scale, y: -scale, z: scale, w: 1. } );
        return ( Matrix4x3.unit.translateXYZ( -1., 1., 0. ) ).scaleByVector( v );
    }
    /**
     * links shader input to buffer and program
     */
    public static inline
    function shaderInput<T>( gl:      WebGLRenderContext
                           , program: GLProgram
                           , name:    String
                           , att:     Int
                           , arr:     T /*Float32Array */
                           , number:  Int ){
        var buffer = gl.createBuffer();
        var arrBuffer = gl.ARRAY_BUFFER;
        gl.bindBuffer( arrBuffer, buffer );
        // RenderingContext.FLOAT, RenderingContext.INT, RenderingContext.UNSIGNED_INT
        // Float32Array,Int32Array, Uint16Array
        gl.bufferData( arrBuffer, untyped arr, gl.STATIC_DRAW );
        var flo = gl.getAttribLocation( program, name );
        gl.vertexAttribPointer( flo, att, number, false, 0/*5 * lime.utils.Float32Array.BYTES_PER_ELEMENT*/, 0 ); 
        gl.enableVertexAttribArray( flo );
        gl.bindBuffer( arrBuffer, null );
    }
    /*
    public 
    function reloadVectors(){
        vertices =  cast verts.getArray();
        colors   =  cast cols.getArray();
        var texs = cast textPos.getArray();
        clearTriangles();
        passIndicesToShader( gl, indices );
        uploadDataToBuffers( gl, glProgram, vertices, colors );
    }
    */
    public
    function uploadVectors(){
        vertices =  cast verts.getArray();
        colors   =  cast cols.getArray();
        var texs = cast textPos.getArray();
        indices  =  createIndices();
        trace( 'indices length ' + indices );
        passIndicesToShader( gl, indices );
        uploadDataToBuffers( gl, glProgram, vertices, colors );
    }
    function createIndices(): Int32Array{
        ind.pos = 0;
        for( i in 0...verts.size ) {
            ind[ 0 ] = i *3 + 0;
            ind[ 1 ] = i *3 + 1;
            ind[ 2 ] = i *3 + 2; 
            ind.next();
        }
        var arr = ind.getArray();
        return cast arr;
    }

    inline
    function clearTriangles(){
        verts = new Float32FlatTriangle(largeEnough);
        cols  = new Float32FlatRGBA(largeEnough);
    }
    /**
     * general clear buffer method may need suplementing, depending on use case.
     */
    public
    function clearVerticesAndColors(){
        var vl = vertices.length;
        var il = indices.length;
        var cl = colors.length;
        vertices = new Float32Array(vl);
        indices  = new Int32Array(il);
        colors   = new Float32Array(cl);
        // texture?
    }
    /**
     *  connects array data to shaders - vertices, colors and optional textures.
     */
    public static inline
    function uploadDataToBuffers( gl: WebGLRenderContext, program: GLProgram, vertices: Float32Array, colors: Float32Array, ?texture: Float32Array ){//, indices: Uint16Array ){
        shaderInput( gl, program, posName,   3, vertices, gl.FLOAT );
        shaderInput( gl, program, colorName, 4, colors, gl.FLOAT );
        if( texture != null ) shaderInput( gl, program, textureName, 2, texture, gl.FLOAT );
    }
    /**
     * like ShaderInput but setup for indices.
     */
    public static inline
    function passIndicesToShader( gl: WebGLRenderContext, indices: Int32Array ){
        var indexBuffer = gl.createBuffer(); // triangle indicies data 
        gl.bindBuffer( gl.ELEMENT_ARRAY_BUFFER, indexBuffer );
        gl.bufferData( gl.ELEMENT_ARRAY_BUFFER, untyped indices, gl.STATIC_DRAW );
        gl.bindBuffer( gl.ELEMENT_ARRAY_BUFFER, null );
    }
    /**
     * provides an identity 4x4 matrix as Float32Array for shader transform
     */ 
    public static inline
    function ident(): Float32Array {
        var arr = new Float32Array(16);
        arr[0] = 1.0; arr[1] = 0.0; arr[2] = 0.0; arr[3] = 0.0;
        arr[4] = 1.0; arr[5] = 0.0; arr[6] = 0.0; arr[7] = 0.0;
        arr[8] = 1.0; arr[9] = 0.0; arr[10] = 0.0; arr[11] = 0.0;
        arr[12] = 1.0; arr[13] = 0.0; arr[14] = 0.0; arr[15] = 0.0;
        return arr;
    }
    public override
    function onKeyDown( key: KeyCode, modifier: KeyModifier ): Void {
        if (!start) return;
        var k = key;
        if( k == KeyCode.LEFT_CTRL ){               axisModel.roll( positive );
        } else if( k == KeyCode.LEFT_ALT ){         axisModel.roll( negative  );
        } else {                                    axisModel.roll( zero );
        }
        if( k == KeyCode.TAB ) {                    axisModel.alongY( negative  );
        } else if( k == KeyCode.LEFT_SHIFT ){        axisModel.alongY( positive );
        } else {                                    axisModel.alongY( zero );
        }
        if( k == KeyCode.SPACE ) {                  axisModel.alongX( negative );
        } else if( k == KeyCode.RIGHT_CTRL ){       axisModel.alongX( positive );
        } else {                                    axisModel.alongX( zero );
        }
        if( k == KeyCode.DELETE ) {                 axisModel.alongZ( negative );
        } else if( k == KeyCode.RETURN ){           axisModel.alongZ( positive );
        } else {                                    axisModel.alongZ( zero );
        }
        if( k == KeyCode.LEFT ) {                   axisModel.yaw( negative );
        } else if( k == KeyCode.RIGHT ){            axisModel.yaw( positive );
        } else {                                    axisModel.yaw( zero );
        }
        if( k == KeyCode.UP ) {                     axisModel.pitch( negative );
        } else if( k == KeyCode.DOWN ){             axisModel.pitch( positive );
        } else {                                    axisModel.pitch( zero );
        }
        if( k == KeyCode.R || k == KeyCode.P ){
            axisModel.reset();
            resetPosition();
        }
        if( k == KeyCode.A ){
            swapAxisModel();
        }
        //trace( axisModel );
    }
    var sceneModel: Axis3; // set to 
    var axisModel               = new Axis3();
    var itemModel               = new Axis3();
    var sceneTransform = true;
    function swapAxisModel(){
        sceneTransform = !sceneTransform;
        if( sceneTransform ){
            axisModel = sceneModel;
        } else {
            axisModel = itemModel;
        }
    }
    inline
    public static 
    function getOffset(): DualQuaternion {
        var qReal = Quaternion.zRotate( 0 );
        var qDual = new Matrix1x4( { x: 0., y: 0., z: -1., w: 1. } );
        return DualQuaternion.create( qReal, qDual );
    }
    final offset = getOffset();
    
    /*public  override
    function onKeyUp ( keyCode: Int, modifier: Int ): Void {
         if (!start) return;
    }*/
}