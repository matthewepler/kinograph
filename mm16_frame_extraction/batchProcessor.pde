class BatchProcessor {
  
  PApplet batchApplet;
  File[] fileDir;
  Rectangle bRect;
  int bSizer;
  Extractor batch;
  OpenCV rotator, frameFinder;
  PImage finalFrame;
  Extractor e;

  BatchProcessor( PApplet p, File d, Rectangle r, int s ) {
    batchApplet = p;
    fileDir = d.listFiles();
    bRect = r;
    bSizer = s;
  }

  void process() {
//    for ( int i = 0; i < fileDir.length; i++ ) {
//      File thisFile = fileDir[ i ];
//      String thisFileName = thisFile.getName();
//      String mimetype = new MimetypesFileTypeMap().getContentType( thisFile );
//      String type = mimetype.split("/")[0];
//      if ( type.equals("image")) {
//        //println( thisFileName );
//        // do the thing
//        try {
//        e = new Extractor( batchApplet, 800, thisFileName );
//
//        // translate coordinates based on resizer value
//        float factor = e.src.height / bSizer;
//
//        PGraphics finalFrame = createGraphics( int( e.frameRect.width * factor ), int( e.frameRect.height * factor ) );
//        finalFrame.beginDraw();
//        finalFrame.copy( e.src, int( e.frameRect.x * factor ), int( e.frameRect.y * factor ), e.frameRect.width, e.frameRect.height, 
//        0, 0, finalFrame.width, finalFrame.height );
//        finalFrame.save( "output/" + i + "_" + thisFileName );
//        finalFrame.endDraw();
//        display( i );
//        println( i + " of " + (fileDir.length-1) + " complete" );
//        }
//        catch ( Exception e ){
//         println( "Error: " + thisFileName + " >>> " + e ); 
//        }
//      } else {
//        println( "skipping " + thisFileName ); 
//      }
//    }
//    background( #75FF6F, 200 );
//    fill( 255 );
//    text( "PROCESS COMPLETE", width/2 - 50, height/2 );
//    println( "PROCESS COMPLETE" );
  }

  // gui feedback
  void display( int _i ) {
    fill( 0, 200 );
    rect( 0, 0, width, height );
    text( _i + " of " + (fileDir.length-1) + "complete", width/2 - 50, height/2 );
    
    // progress bar
    float percent = _i / fileDir.length;
    
    fill( #FFFFFF );
    rect( 100, width - 100, width - 200, 25 );
    fill( #75FF6F );
    rect( 100, width - 100, int( percent * (width-200) ), 25 );
  }
}

