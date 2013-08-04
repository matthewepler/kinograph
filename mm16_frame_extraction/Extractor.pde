class Extractor {

  int resizer;
  int mWidth, mHeight;
  String path;
  int currX, currY;
  int roiY, roiH;
  boolean roiSet, showRoi, posCaptured;
  boolean sprocketSet, frameFound;
  PFont font;

  // controller variables
  int canny1, canny2;
  int hLines1, hLines2, hLines3;

  int sprocketThresh;
  float sprocketHeight;
  PVector sprocketPos;
  int topY, bottomY, rightX, leftX, sprktHeight, sprktWidth;
  float minX, maxX;
  
  // adjustable in GUI by user
  int minEdgeLen;
  int rowThresh;
  int colThresh;

  PImage copy, CVout, ROImage, frame;
  float[] edges = new float[2];
  double angleAvg;
  Rectangle firstSprocket, secondSprocket, frameRect;
  OpenCV sprocket;
  PApplet applet;


  // ============================================================= CONSTRUCTOR =========== //
  Extractor( PApplet _this, int _r, String _f ) {
    applet = _this;
    resizer = _r;
    copy = loadImage( _f );
    copy.resize( resizer, 0 ); 
  }

    
  // ================================================================================== GO //
  void go() {
    copy = calcRotation( copy );
    if( roiSet ) {
      ROImage = createImage( copy.width, roiH, ARGB );
      ROImage.copy( copy, 0, roiY, copy.width, roiH, 0, 0, copy.width, roiH );
      edges = findFilmEdges();
      if( sprocketSet ) {
        frame = extractFrame( calcFrameRect() );
      }
    } 
  }
  
  // ================================================================== SET DEFAULT VALUES //
  void setDefaultValues() {
      canny1  = 20;
      canny2  = 75;
      hLines1 = 100;
      hLines2 = 600;
      hLines3 = 5;
      sprocketThresh = 150;
  }
  
  void getUserDefinedValues() {
      cf.update(); 
  } 
    
  // =================================================================== CALCULATE ROTATION // 
  PImage calcRotation( PImage input ) {
    OpenCV full = new OpenCV( applet, input );
    full.findCannyEdges( canny1, canny2 );
    full.dilate();
    full.erode();
    full.dilate();
    // thresh,  minLen,  maxGap
    ArrayList<Line> lines = full.findLines( hLines1, hLines2, hLines3 );

    double angleTotal = 0;
    for ( int i = 0; i < lines.size(); i++ ) {
      Line line = lines.get( i );
      angleTotal += line.angle;
    }
    
    angleAvg = angleTotal / lines.size();

    PGraphics prep = createGraphics( input.height, input.width );
    prep.beginDraw();
    prep.rotate( (float) angleAvg * -1 );
    prep.image( input, input.width * -1, 0 );
    prep.endDraw();

    PImage result = prep.get(  0, 0, prep.width, prep.height );
    return result;
  } 
  
  
  // ============================================================= FIND FILM EDGES ======== //
  float[] findFilmEdges() {   
    PImage roiFrame = createImage( copy.width, roiH, ARGB );
    roiFrame.copy( copy, 0, roiY, copy.width, roiH, 0, 0, copy.width, roiH );
    sprocket = new OpenCV( applet, roiFrame );
    sprocket.gray();
    sprocket.findCannyEdges( canny1, canny2 );
    sprocket.dilate();
    sprocket.erode();
    sprocket.dilate(); 

    hLines2 = roiFrame.height - 20;

    ArrayList<Line> edges = sprocket.findLines( hLines1, hLines2, hLines3 );  

    if( !processAll ) {
      if ( edges.size() < 2 ) {
        fill( #FCE400 );
        text( "No frame edges found. Adjust settings and refresh.", copy.width + 70, roiH + 200 );
      }
      CVout = sprocket.getOutput();
      image( sprocket.getOutput(), width/2, 0 );
    }

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

    if ( sorted[ sorted.length - 2 ] < copy.width - margin ) {
      maxX = sorted[ sorted.length - 2 ];
    } 
    else {
      maxX = sorted[ sorted.length - 3 ];
    }
    
    float[] result = { minX, maxX };
    return result;
  }


  // ============================================================= FIND SPROCKETS ========= //
  boolean findSprockets() { 
    try {
      // find first sprocket
      cf.update();
      int startX = width/2 + (int)minX + 10;
      int endX = startX + 90;
      int startY = 0;
      int endY = ROImage.height / 3;

      firstSprocket = evaluatePixels( startX, endX, startY, endY, minEdgeLen, rowThresh, colThresh );
      float firstArea = firstSprocket.width * firstSprocket.height;

      // find second spocket based on Rect values of firstSprocket
      startX = firstSprocket.x - 5;
      endX = firstSprocket.x + firstSprocket.width + 5;
      startY = firstSprocket.y + firstSprocket.height*2; 
      endY = ROImage.height - 20;
      minEdgeLen = firstSprocket.width - 5;

      secondSprocket = evaluatePixels( startX, endX, startY, endY, minEdgeLen, rowThresh, colThresh );
      float secondArea = secondSprocket.width * secondSprocket.height; 

      //println( "secondArea: " + secondArea + ", " + "firstArea: " + firstArea );

      if ( abs( secondArea - firstArea) < 250 ) {
        frameFound = true;
        sprocketSet = true;
        calcFrameRect();
        return true;
      }
    }  
    catch ( Exception e ) {
      //println( e );
      sprocketSet = false;
      return false;
    }
    return true;
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


  // ============================================================== CALCULATE FRAME RECTANGLE //
  Rectangle calcFrameRect() {
    // find the top & bottom of the frame
    float frameTop = roiY + firstSprocket.y + (firstSprocket.height/2);
    float frameBot = roiY + secondSprocket.y + (secondSprocket.height/2);
    int frameHeight = (int)frameBot - (int)frameTop;

    // find the left side of the frame (split any difference there might be)
    int frameLeft = (firstSprocket.x - copy.width) + firstSprocket.width;

    // dist between left edge of film & left side of frame == dst between right side of film and right side of frame
    // aka, frame width
    float sideMargin = (firstSprocket.x - copy.width) + firstSprocket.width - minX;
    float frameRight = maxX - sideMargin;

    int frameWidth = (int)frameRight - (int)frameLeft;
    Rectangle result = new Rectangle( frameLeft, (int)frameTop, frameWidth, frameHeight ); // for reference in frame adjustment controls
    return result;
  }


  // ============================================================= EXTRACT FRAMES ========= //
  PImage extractFrame( Rectangle r ) {
    PImage result = createImage( r.width, r.height, ARGB );
    result.copy( copy, r.x, r.y, r.width, r.height, 0, 0, r.width, r.height );
    if ( processAll ) {
      save( "output/" + result ); 
      println( "saved" );
    }
    return result;
  }

  
  // ============================================================================= DISPLAY //
  void display() {
    image( copy, 0, 0 );
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
      line( edges[0], roiY, edges[0], roiH );
      line( edges[1], roiY, edges[1], roiH );
     
      // show minX and maxX lines as ellipses at top of window
      fill( 255, 0, 255 );
      ellipse( minX, roiY, 10, 10 );
      ellipse( maxX, roiY, 10, 10 );
    }

    // IF FRAME FOUND, DISPLAY
    if ( sprocketSet && frameFound ) { 
      image( frame, copy.width + 100, roiH + 20);
    } 
    else if ( !sprocketSet && !frameFound ) {
      fill( #FCE400 );
      text( "Click and drag to create new region of interest.", copy.width + 25, 50 );
    } 
    else {
      fill( #FCE400 );
      text( "No frame found. Please adjust settings and refresh", copy.width + 70, roiH + 200 );
    }

    // DISPLAY MOUSE POSITION
    fill( 0 );
    noStroke();
    rect( width/2 - 50, 0, 105, 30 );
    textSize( 20 );
    fill( 255, 0, 0 );
    text( mouseX + " : " + mouseY, width/2 - 45, 25 );
  } 


  // ============================================================================== RELOAD // **
  void reload( String s ) {
//    PImage src1 = loadImage( s );
//    src1.resize( resizer, 0 );
//    full = new OpenCV(  applet, src1 );
//    full.findCannyEdges( canny1, canny2 );
//    full.dilate();
//    full.erode();
//    full.dilate();
//    hLines2 = 600;
//    ArrayList<Line> lines = full.findLines( hLines1, hLines2, hLines3 );
//    copy = calcRotation();
//    hLines2 = roiFrame.height - 20;
  }


  // ============================================================================== HELPERS //
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
      rect( 0, roiY, copy.width, roiH );
    }
  }
} // * END OF CLASS * //

