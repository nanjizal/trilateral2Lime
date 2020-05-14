package trilateral2Lime.app;
import lime.graphics.RenderContext;
import lime.graphics.WebGLRenderContext;
//import lime.Assets;
//import lime.utils.AssetType;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLShader;
import trilateral2Lime.shader.ShaderStrings; 
import trilateral2Lime.shader.HelpGL;
import trilateral2Lime.shader.BufferHelpGL;
import trilateral2Lime.data.ColourPosition;
import lime.math.Matrix4;

// Trilateral2 specific
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
import pallette.QuickARGB;
import pallette.Gold;
import trilateral2Lime.drawings.*;
// Maths mostly matrix transforms
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

enum abstract ShaderTest( Int ) to Int from Int {
    var DIRECT;      // where you don't use a buffer
    var INTERLEAVE;  // with only one buffer for speed and no matrix
    var COLOR;       // color with matrix - standard
    var COLOR3;      // color but setup to draw 3 triangles
    var TRILATERAL2; // test of trilateral2
    var TEXTURE;     // color with texture perhaps
}
class AppGL{
    var width: Int;
    var height: Int;
    var ind: UInt16Array;
    var shaderTest = TRILATERAL2;
    var noVertices: Int = 3;
    var first: Bool = true;
    var program: GLProgram;
    public function new( width_: Int, height_: Int ){
        width = width_;
        height = height_;
    }
    public inline
    function update(){
        
    }
    public inline
    function setup( gl: WebGLRenderContext ){
        // Only happens when app is ready.
        switch( shaderTest ){
            case DIRECT:
                // Not Implemented Yet
                // you can use a for loop to set data values manually without a buffer
                // this may in some instances be faster, investigate..
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexColor
                                             , ShaderStrings.fragmentColor );
                createColorDirect( gl, program );
            case INTERLEAVE:
                // Current working setup
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexSimpleColor
                                             , ShaderStrings.fragmentSimpleColor );
                createInterleave( gl, program );
            case COLOR:
                // aim to get working next
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexColor
                                             , ShaderStrings.fragmentColor );
                passIndicesToShader( gl, createIndices() );
                createMatrix( gl, program, 'modelViewProjection' );
                createColor1( gl, program );
            case COLOR3:
                // aim to get working next
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexColor
                                             , ShaderStrings.fragmentColor );
                createColor3( gl, program );
            case TRILATERAL2:
                // Lets interleave it 2D for now?
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexSimpleColor
                                             , ShaderStrings.fragmentSimpleColor );
                createTrilateral2( gl, program );
            case TEXTURE:
                // need to look at trilateralXtra at the Kha stuff polyTriangles?
                // aim to get working next
                program = HelpGL.programSetup( gl
                                             , ShaderStrings.vertexTexture
                                             , ShaderStrings.fragmentTexture );
                createTexture( gl, program );
        }
    }
    //  MAIN RENDER LOOP
    public inline
    function render( gl: WebGLRenderContext ){
        // happens every frame.
        HelpGL.clearAll( gl, width, height );
        if( first ) trace( 'rendering triangles ( first time )' );
        gl.useProgram( program );
        doProjection( gl );
        gl.drawArrays( gl.TRIANGLES, 0, noVertices );
        if( first ) first = false; // provides a way to trace the first render loop
    }
    public inline
    function doProjection( gl: WebGLRenderContext ){
        switch( shaderTest ){
            case INTERLEAVE, TRILATERAL2:
                
            default:
                createMatrix( gl, program, 'modelViewProjection' );
        }
    }
    /**
     * REFACTOR THIS OUT WHEN IT PROPERLY USED
     * Currently part of my attempt at modelViewProjection matrix
     */
    function createIndices(): UInt16Array{
        ind = new UInt16Array( 3 );
        for( i in 0...1) {
            ind[ 0 ] = i *3 + 0;
            ind[ 1 ] = i *3 + 1;
            ind[ 2 ] = i *3 + 2; 
        }
        return ind;
    }
    /**
     * REFACTOR THIS OUT WHEN IT PROPERLY USED
     * Currently part of my attempt at modelViewProjection matrix
     */
    public static inline
    function passIndicesToShader( gl: WebGLRenderContext, indices: UInt16Array ){
        var indexBuffer = gl.createBuffer(); // triangle indicies data 
        gl.bindBuffer( gl.ELEMENT_ARRAY_BUFFER, indexBuffer );
        gl.bufferData( gl.ELEMENT_ARRAY_BUFFER, untyped indices, gl.STATIC_DRAW );
        gl.bindBuffer( gl.ELEMENT_ARRAY_BUFFER, null );
    }
    inline
    function createColor1( gl: WebGLRenderContext, program: GLProgram ){
        var p = ColourPosition.othogPositions();
        var l = p.length;
        for( i in 0...l ){
            trace( p[i] );
        }
        BufferHelpGL.colorsXYZ_RGBA( gl
                                   , program
                                   , ColourPosition.othogPositions()
                                   , ColourPosition.colors()
                                   , 'vertexPosition'
                                   , 'vertexColor' );
    }
    // test interleave
    inline
    function createTrilateral2( gl: WebGLRenderContext, program: GLProgram ){
        layoutPos   = new LayoutPos( stageRadius );
        createPen();
        pen.currentColor = 0xff663300;
        //new GoldBirdFill(                           pen, layoutPos );
        //new OrangeBirdOutline(                      pen, layoutPos );
        new GreenSquare(                            pen, layoutPos );
        new OrangeDavidStar(                        pen, layoutPos );
        new IndigoCircle(                           pen, layoutPos );
        new VioletRoundedRectangle(                 pen, layoutPos );
        new YellowDiamond(                          pen, layoutPos );
        new MidGreySquareOutline(                   pen, layoutPos );
        new BlueRectangle(                          pen, layoutPos );
        new RedRoundedRectangleOutline(             pen, layoutPos );
        //new FillPoly2Trihx(                         pen, layoutPos );
        //new OutlinePoly2Trihx(                      pen, layoutPos );
        new QuadCurveTest(                          pen, layoutPos );
        new CubicCurveTest(                         pen, layoutPos );
        scaleToGL();
        var len = verts.length; // this is measure in triangles, so 3 verts pers side
        noVertices = len;
        var tots = 2*len + 3*len;
        var data = new lime.utils.Float32Array( tots );
        var count = 0;
        var colCounter = 0;
        for( i in 0...len ){
            verts.pos = i;
            data[ count++ ] = verts.ax;
            data[ count++ ] = verts.ay;
            cols.pos = colCounter; 
            data[ count++ ] = cols.red;
            data[ count++ ] = cols.green;
            data[ count++ ] = cols.blue;
            colCounter++;
            data[ count++ ] = verts.bx;
            data[ count++ ] = verts.by;
            cols.pos = colCounter; 
            data[ count++ ] = cols.red;
            data[ count++ ] = cols.green;
            data[ count++ ] = cols.blue;
            colCounter++;
            data[ count++ ] = verts.cx;
            data[ count++ ] = verts.cy;
            cols.pos = colCounter; 
            data[ count++ ] = cols.red;
            data[ count++ ] = cols.green;
            data[ count++ ] = cols.blue;
            colCounter++;
        }
        BufferHelpGL.interleaveXY_RGB( gl
                                     , program
                                     , data
                                     , 'vertexPosition'
                                     , 'vertexColor' );
    }
    // test interleave
    inline
    function createInterleave( gl: WebGLRenderContext, program: GLProgram ){
        var data = ColourPosition.tri2D();
        BufferHelpGL.interleaveXY_RGB( gl
                                     , program
                                     , data
                                     , 'vertexPosition'
                                     , 'vertexColor' );
    }
    function createMatrix ( gl: WebGLRenderContext, program: GLProgram, matrixNom: String ){
        var matrixUniform = gl.getUniformLocation( program, matrixNom );
        var matrix        = new Matrix4();
        matrix.createOrtho( 0, width, height, 0, -1000, 1000 );
        gl.uniformMatrix4fv( matrixUniform, false, matrix );
        // direct uniform   gl.uniform4f(uFragColor, 1.0, 0.0, 0.0, 1.0);
    }
    inline
    function createColorDirect( gl: WebGLRenderContext, program: GLProgram ){
        var pos      = ColourPosition.positions3();
        var col      = ColourPosition.colors3();
        var posLoc   = gl.getAttribLocation( program, 'vertexPosition' );
        var colorLoc = gl.getAttribLocation( program, 'vertexColor' );
        var p = 0;
        var c = 0;
        for( i in 0...3 ){
            p = i*3;
            gl.vertexAttrib3f( posLoc, pos[ p ], pos[ p+1 ], pos[ p+2 ] );
            c = i*4;
            gl.vertexAttrib4f( posLoc, col[ c ], col[ c+1 ], col[ c+2 ], col[ c+3 ] );
        }
        gl.enableVertexAttribArray( posLoc );
        gl.enableVertexAttribArray( colorLoc );
    }
    inline
    function createColor3( gl: WebGLRenderContext, program: GLProgram ){
        noVertices = Std.int( 3*3 );
        BufferHelpGL.colorsXYZ_RGBA( gl
                                   , program
                                   , ColourPosition.positions3()
                                   , ColourPosition.colors3()
                                   , 'vertexPosition'
                                   , 'vertexColor' );
    }
    inline
    function createTexture( gl: WebGLRenderContext, program: GLProgram ){
        trace( 'not implemented yet' );
    }

    // TRILATERAL2 Specific code for testing
    var pen:                    Pen;
    static final largeEnough    = 2000000;
    var verts                   = new Float32FlatTriangle( largeEnough );
    var textPos                 = new Float32FlatTriangleXY( largeEnough );
    var cols                    = new Float32FlatRGBA(largeEnough);
    //var ind                     = new Int32Flat3(largeEnough);
    var layoutPos:              LayoutPos;
    var scale:                  Float;
    public inline static var stageRadius: Int = 600;
    function createPen() {
        pen = Pen.create( verts, cols );
        pen.transformMatrix = scaleToGL();
        Shaper.transformMatrix = scaleToGL();
    }
    function scaleToGL(){
        scale = 1/(stageRadius);
        var v = new Matrix1x4( { x: scale, y: -scale, z: scale, w: 1. } );
        return ( Matrix4x3.unit.translateXYZ( -1., 1., 0. ) ).scaleByVector( v );
    }
    
}
