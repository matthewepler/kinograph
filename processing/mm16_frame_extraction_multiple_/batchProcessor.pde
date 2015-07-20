class BatchProcessor {
  
  PApplet batchApplet;
  File[] fileDir;
  Rectangle bRect;
  PImage finalFrame;
  Extractor e;

  BatchProcessor( PApplet p, File d, Extractor _e ) {
    batchApplet = p;
    fileDir = d.listFiles();
    e = _e;
  }

  void process() {
    for ( int i = 0; i < fileDir.length; i++ ) {
      File thisFile = fileDir[ i ];
      String thisFileName = thisFile.getName();
     
      if ( thisFileName.contains(fileType) ) {
        println("processing " + thisFileName);
        try {
          e.reload( thisFileName );
          println( (i+1) + " of " + (fileDir.length-1) + " complete: " + thisFileName );
        }
        catch ( Exception e ) {
          println( "Error: " + thisFileName + " >>> " + e ); 
        }
      } 
      else {
        println( "skipping " + thisFileName ); 
      }
      scrubber( i + 1 );
      display();
    }
    background( #75FF6F, 200 );
    fill( 255 );
    text( "PROCESS COMPLETE", width/2 - 50, height/2 );
    println( "PROCESS COMPLETE" );
  }

  // gui feedback
  void display() {
    image( e.frame, width/2 - (e.frame.width/2), width/2 - (e.frame.height/2) );
  }
}

