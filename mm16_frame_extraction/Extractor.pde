class Extractor {

  int resizer;
  int mWidth, mHeight;
  String path;
  int currX, currY;
  int roiY, roiH;
  double angleAvg;
  PImage src1, src, CVout, frame, roiFrame;
  PGraphics prep;
  ArrayList<Line> lines, edges;
  boolean roiSet, showRoi, posCaptured;
  boolean sprocketSet, frameFound;
  PFont font;
  ArrayList<Contour> vertContours;
  // controller variables
  int canny1, canny2;
  int hLines1, hLines2, hLines3;

  int sprocketThresh = 150;
  float sprocketHeight;
  PVector sprocketPos;
  int topY, bottomY, rightX, leftX, sprktHeight, sprktWidth;
  float minX, maxX;

  int startX;
  int endX;
  int startY;
  int endY;
  int minEdgeLen;
  int rowThresh;
  int colThresh;
  
  Rectangle firstSprocket, secondSprocket, frameRect;
  OpenCV full, sprocket;
  PApplet applet;

  // ============================================================= CONSTRUCTOR =========== //
  Extractor( PApplet _this, int _r ) {
    applet = _this;
    resizer = _r;
    src1 = loadImage( files[ (int)files.length/2 ] );
    src1.resize( resizer, 0 );

    setInitValues();
    
    full = new OpenCV(  applet, src1 );
    full.findCannyEdges( canny1, canny2 );
    full.dilate();
    full.erode();
    full.dilate();
    // thresh,  minLen,  maxGap
    lines = full.findLines( hLines1, hLines2, hLines3 );

    calcRotation();
  } 
  
  
  // ===================================================================== SET INIT VALUES //
  void setInitValues() {
    canny1  = 20;
    canny2  = 75;
    hLines1 = 100;
    hLines2 = 600;
    hLines3 = 5;
  }
  
  // ============================================================================== RELOAD //
  void reload( String s ) {
    src1 = loadImage( s );
    src1.resize( resizer, 0 );
    full = new OpenCV(  applet, src1 );
    full.findCannyEdges( canny1, canny2 );
    full.dilate();
    full.erode();
    full.dilate();
    hLines2 = 600;
    lines = full.findLines( hLines1, hLines2, hLines3 );
    calcRotation();
    hLines2 = roiFrame.height - 20;
  }




  // =================================================================== CALCULATE ROTATION //
  void calcRotation() {
    double angleTotal = 0;
    for ( int i = 0; i < lines.size(); i++ ) {
      Line line = lines.get( i );
      angleTotal += line.angle;
    }
    angleAvg = angleTotal / lines.size();

    prep = createGraphics( src1.height, src1.width );
    prep.beginDraw();
    prep.rotate( (float) angleAvg * -1 );
    prep.image( src1, src1.width * -1, 0 );
    prep.endDraw();

    src = prep.get(  0, 0, prep.width, prep.height );
    mWidth = src.width;
    mHeight = src.height;
  }


  // ============================================================================= DISPLAY //
  void display() {
    image( src, 0, 0 );
    fill( 255, 200 );

    updateRoi();
    if ( roiSet && !sprocketSet ) {
      cf.update();
      findFilmEdges();
      findSprockets();
    }


    if ( sprocketSet ) {
      image( CVout, width/2, 0 );
      stroke( 0, 255, 0 );
      strokeWeight( 3 );
      noFill();
      rect( firstSprocket.x, firstSprocket.y, firstSprocket.width, firstSprocket.height );
      rect( secondSprocket.x, secondSprocket.y, secondSprocket.width, secondSprocket.height );
      stroke( 255, 0, 255 );

      // SHOW HUGH LINES
      for ( Line l : edges ) {
        line( l.start.x, roiY + l.start.y, l.end.x, l.end.y + roiY );
      }
      // show minX and maxX lines as ellipses at top of window
      fill( 255, 0, 255 );
      ellipse( minX, roiY, 10, 10 );
      ellipse( maxX, roiY, 10, 10 );
    }

    // IF FRAME FOUND, DISPLAY
    if ( sprocketSet && frameFound ) { 
      image( frame, src.width + 100, roiH + 20);
    } else if( !sprocketSet && !frameFound ){
      fill( #FCE400 );
      text( "Click and drag to create new region of interest.", src.width + 25, 50 ); 
    } else {
      fill( #FCE400 );
      text( "No frame found. Please adjust settings and refresh", src.width + 70, roiH + 200 ); 
    }

    // DISPLAY MOUSE POSITION
    fill( 0 );
    noStroke();
    rect( width/2 - 50, 0, 105, 30 );
    textSize( 20 );
    fill( 255, 0, 0 );
    text( mouseX + " : " + mouseY, width/2 - 45, 25 );
  } 


  // ============================================================= FIND FILM EDGES ======== //
  void findFilmEdges() {   
    roiFrame = createImage( src.width, roiH, ARGB );
    roiFrame.copy( src, 0, roiY, src.width, roiH, 0, 0, src.width, roiH );
    sprocket = new OpenCV( applet, roiFrame );
    sprocket.gray();
    sprocket.findCannyEdges( canny1, canny2 );
    sprocket.dilate();
    sprocket.erode();
    sprocket.dilate(); 

    hLines2 = roiFrame.height - 20;

    edges = sprocket.findLines( hLines1, hLines2, hLines3 );  
    
    if( edges.size() < 2 ) {
      fill( #FCE400 );
      text( "No frame edges found. Adjust settings and refresh.", src.width + 70, roiH + 200 ); 
    }
    
    CVout = sprocket.getOutput();
    image( sprocket.getOutput(), width/2, 0 );

    // sort Hugh Lines to determine which lines represent the edges of the film.
    float[] linePos = new float[ edges.size() ];
    for ( int i = 0; i < edges.size(); i++ ) {
      Line l = edges.get( i );
      linePos[ i ] = l.start.x;
    }

    float[] sorted = sort( linePos );

    int margin = 15;
    if ( sorted[0] > margin ) {
      minX = sorted[0];
    } 
    else {
      minX = sorted[1];
    }

    if ( sorted[ sorted.length - 2 ] < src.width - margin ) {
      maxX = sorted[ sorted.length - 2 ];
    } 
    else {
      maxX = sorted[ sorted.length - 3 ];
    }
  }


  // =========================================================================== CAPTURE POS //
  void capturePos() {
    if ( !posCaptured ) {
      currX = mouseX;
      currY = mouseY;
      posCaptured = true;
    } 
    else {
      posCaptured = true;
    }
  } 


  // ============================================================= FIND SPROCKETS ========= //
  void findSprockets() { 
    try {
      // find first sprocket
      int startX = width/2 + (int)minX + 10;
      int endX = startX + 90;
      int startY = 0;
      int endY = roiFrame.height / 3;
      cf.update();

      firstSprocket = evaluatePixels( startX, endX, startY, endY, minEdgeLen, rowThresh, colThresh );
      float firstArea = firstSprocket.width * firstSprocket.height;

      // find second spocket based on Rect values of firstSprocket
      startX = firstSprocket.x - 5;
      endX = firstSprocket.x + firstSprocket.width + 5;
      startY = firstSprocket.y + firstSprocket.height*2; 
      endY = roiFrame.height - 20;
      minEdgeLen = firstSprocket.width - 5;

      secondSprocket = evaluatePixels( startX, endX, startY, endY, minEdgeLen, rowThresh, colThresh );
      float secondArea = secondSprocket.width * secondSprocket.height; 

      //println( "secondArea: " + secondArea + ", " + "firstArea: " + firstArea );

      if ( abs( secondArea - firstArea) < 250 ) {
        frameFound = true;
        calcFrameRect();
        extractFrame();
      } 
      else {
        // do nothing for now
      }
      sprocketSet = true;
    } 
    catch ( Exception e ) {
      //println( e );
      sprocketSet = false;
    }
  }


  Rectangle evaluatePixels( int _startX, int _endX, int _startY, int _endY, int _minEdgeLen, int _rowThresh, int _colThresh ) {
    List<Integer> Xvalues = new ArrayList();
    List<Integer> Yvalues = new ArrayList();

    int startX = _startX;
    int endX   = _endX;
    int startY = _startY;
    int endY   = _endY;
    int minEdgeLen = _minEdgeLen;
    int rowThresh = _rowThresh;
    int colThresh = _colThresh;


    // FIND THE HORIZONTAL ROWS
    int rowCount = 0;
    for ( int y = startY; y < endY; y++ ) {
      int whiteCount = 0;
      for ( int x = startX; x < endX; x++ ) {
        color c = get( x, y );     
        if ( brightness( c ) > 200 ) {
          whiteCount++;
        }
      } 
      if ( whiteCount > minEdgeLen ) {
        rowCount++;
        if ( rowCount > rowThresh ) {
          Yvalues.add( y );
          rowCount = 0;
        }
      }
    }
    int[] rows = new int[ Yvalues.size() ];
    for ( int i = 0; i < rows.length; i++ ) {
      Integer e = Yvalues.get( i );
      rows[ i ] = e.intValue();
    }
    //  sort( rows );
    //println( rows );
    topY = rows[0];
    bottomY = rows[ rows.length-1 ];
    sprktHeight = bottomY - topY;


    // FIND THE VERTICAL COLUMNS
    int colCount = 0;
    for ( int x = startX; x < endX; x++ ) {
      int whiteCount = 0;
      for ( int y = topY; y < bottomY; y++ ) {
        color c = get( x, y );
        if ( brightness( c ) > 200 ) {
          whiteCount++;
        }
      }
      if ( whiteCount > sprktHeight * 0.75 ) {
        colCount++;
        if ( colCount > colThresh ) {
          Xvalues.add( x );
          colCount = 0;
        }
      }
    }

    int[] cols = new int[ Xvalues.size() ];
    for ( int i = 0; i < cols.length; i++ ) {
      Integer e = Xvalues.get( i );
      cols[ i ] = e.intValue();
    }
    sort( cols );
    //println( cols );
    leftX  = cols[ 0 ];
    //println( leftX );
    rightX = cols[ cols.length-1 ];
    sprktWidth = rightX - leftX;

    Rectangle result = new Rectangle( leftX, topY, sprktWidth, sprktHeight );
    return result;
  }


  // ============================================================= EXTRACT FRAMES ========= //
  void calcFrameRect() {
    // find the top & bottom of the frame
    float frameTop = roiY + firstSprocket.y + (firstSprocket.height/2);
    float frameBot = roiY + secondSprocket.y + (secondSprocket.height/2);
    int frameHeight = (int)frameBot - (int)frameTop;

    // find the left side of the frame (split any difference there might be)
    int frameLeft = (firstSprocket.x - src.width) + firstSprocket.width;

    // dist between left edge of film & left side of frame == dst between right side of film and right side of frame
    // aka, frame width
    float sideMargin = (firstSprocket.x - src.width) + firstSprocket.width - minX;
    float frameRight = maxX - sideMargin;

    int frameWidth = (int)frameRight - (int)frameLeft;
    frameRect = new Rectangle( frameLeft, (int)frameTop, frameWidth, frameHeight ); // for reference in frame adjustment controls
  }
  
  void extractFrame() {
    frame = createImage( frameRect.width, frameRect.height, ARGB );
    frame.copy( src, frameRect.x, frameRect.y, frameRect.width, frameRect.height, 0, 0, frameRect.width, frame.height );
    if( processAll ) {
      save( "output/" + frame ); 
      println( "saved" );
    }
  }
  
  
  // ============================================================= UPDATE ROI ============= //
  void updateRoi() {
    if ( !roiSet && mousePressed && !scrubber ) {
      showRoi = true;
      capturePos();
      roiY = currY;
      roiH = mouseY - roiY;
    }

    if ( showRoi ) {
      fill( 255, 0, 0, 50 );
      stroke( 255, 0, 0 );
      rect( 0, roiY, src.width, roiH );
    }
  }
} // * END OF CLASS * //

