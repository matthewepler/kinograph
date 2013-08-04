class Extractor {

  int resizer;

  // ROI variables
  int currX, currY;
  int roiY, roiH;
  boolean roiSet, showRoi, posCaptured;
  PFont font;

  // OpenCV variables
  int canny1, canny2;
  int hLines1, hLines2, hLines3;
  int sprocketThresh;
  
  // Sprocket search variables
  int minEdgeLen;
  int rowThresh;
  int colThresh;

  // General class variables
  PImage copy, CVout, ROImage, frame;
  float[] edges = new float[2];
  double angleAvg;
  float minX, maxX;
  boolean rotationSet, edgesFound, sprocketSet, frameFound;
  String name;
  
  Rectangle firstSprocket, secondSprocket, frameRect;
  OpenCV sprocket;
  PApplet applet;


  // ========================================================================= CONSTRUCTOR //
  Extractor( PApplet _this, int _r, String _f ) {
    applet = _this;
    resizer = _r;
    copy = loadImage( _f );
    copy.resize( resizer, 0 );
    name = _f;
  }


  // ================================================================================== GO //
  void go() {
    if ( !rotationSet ) {
      copy = calcRotation( copy );
    }

    if ( roiSet ) {
      ROImage = createImage( copy.width, roiH, ARGB );
      ROImage.copy( copy, 0, roiY, copy.width, roiH, 0, 0, copy.width, roiH );
      edges = findFilmEdges(); //println( "minX: " + minX ); println( "maxX: " + maxX );
      if ( findSprockets() ) {
        frameRect = calcFrameRect();
        frame = extractFrame( frameRect );
      }
    } 

  }

  // =========================================================================== SET VALUES //
  void setDefaultValues() {
    canny1  = 20;
    canny2  = 75;
    hLines1 = 100;
    hLines2 = 600;
    hLines3 = 5;
    sprocketThresh = 150;
    roiY = 200;
    roiH = 500;
    roiSet = true;
    showRoi = true;
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

    if ( lines.size() > 2 ) {
      rotationSet = true;
    } 
    else {
      rotationSet = false;
    }

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


  // ======================================================================== FIND FILM EDGES //
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
    
    if ( !processAll ) {
      CVout = sprocket.getOutput();
      image( sprocket.getOutput(), width/2, 0 );
    }

    // sort Hugh Lines to determine which lines represent the edges of the film.
    if ( edges.size() > 1 ) {
      edgesFound = true;
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

      float[] result = { 
        minX, maxX
      };
      return result;
    } 
    else {
      edgesFound = false;
      float[] result = { 0, copy.width };
      return result;
    }
  }


  // ========================================================================= FIND SPROCKETS //
  boolean findSprockets( ) { 
    boolean result = false;
    try {
      // find first sprocket
      cf.update();
      int startX = (int)minX + 10;
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

      if ( abs( secondArea - firstArea) < 500 ) {
        sprocketSet = true;
        result = true;
        //calcFrameRect();
      }
    }  
    catch ( Exception e ) {
      //println( e );
      sprocketSet = false;
      result = false;
    }
    return result;
  }

  // ======================================================================= EVALUATE PIXELS //
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
        color c = CVout.get( x, y );     
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
    int topY = rows[0];
    int bottomY = rows[ rows.length-1 ];
    int sprktHeight = bottomY - topY;


    // FIND THE VERTICAL COLUMNS
    int colCount = 0;
    for ( int x = startX; x < endX; x++ ) {
      int whiteCount = 0;
      for ( int y = topY; y < bottomY; y++ ) {
        color c = CVout.get( x, y );
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
    int leftX  = cols[ 0 ];
    //println( leftX );
    int rightX = cols[ cols.length-1 ];
    int sprktWidth = rightX - leftX;

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
    int frameLeft = (firstSprocket.x) + firstSprocket.width;

    // dist between left edge of film & left side of frame == dst between right side of film and right side of frame
    // aka, frame width
    float sideMargin = (firstSprocket.x) + firstSprocket.width - minX;
    float frameRight = maxX - sideMargin;

    int frameWidth = (int)frameRight - (int)frameLeft;
    Rectangle result = new Rectangle( frameLeft, (int)frameTop, frameWidth, frameHeight ); // for reference in frame adjustment controls
    return result;
  }


  // ======================================================================= EXTRACT FRAMES //
  PImage extractFrame( Rectangle r ) {
    PGraphics result = createGraphics( r.width, r.height );;
    result.beginDraw();
    result.copy( copy, r.x, r.y, r.width, r.height, 0, 0, r.width, r.height );
    if( processAll ) {
      String nameStrip = name.substring( 0, name.lastIndexOf('.')).toLowerCase();
      result.save( "output/" + nameStrip + ".jpg" );
    }  
    result.endDraw(); 
    return result;
  }


  // ============================================================================= DISPLAY //
  void display() {
    image( copy, 0, 0 );
    fill( 255, 200 );

    updateRoi();

    if ( roiSet && !sprocketSet ) {
      getUserDefinedValues();
      go();
    } 

    if ( edgesFound ) {
      // SHOW HUGH LINES
      line( edges[0], roiY, edges[0], roiH );
      line( edges[1], roiY, edges[1], roiH );
      fill( 255, 0, 255 );
      ellipse( minX, roiY, 10, 10 );
      ellipse( maxX, roiY, 10, 10 );

      if ( sprocketSet ) {
        image( CVout, width/2, 0 );
        stroke( 0, 255, 0 );
        strokeWeight( 3 );
        noFill();
        rect( firstSprocket.x + width/2, firstSprocket.y, firstSprocket.width, firstSprocket.height );
        rect( secondSprocket.x + width/2, secondSprocket.y, secondSprocket.width, secondSprocket.height );
        stroke( 255, 0, 255 );
        image( frame, copy.width + 100, height - frame.height - 70);
      } 
      else {
        fill( #FCE400 );
        text( "No sprockets found. Please adjust settings and refresh.", copy.width + 25, roiH + 200 );
      }
    }
    else {
      if( roiSet ) {
      fill( #FCE400 );
      text( "No edges found. Please adjust settings and refresh", copy.width + 70, roiH + 200 );
      }
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
    copy = loadImage( s );
    name = s;
    copy.resize( resizer, 0 );
    getUserDefinedValues();
    roiSet = true;
    rotationSet = false;
    edgesFound = false;
    sprocketSet = false; 
    frameFound = false;
    go();
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

