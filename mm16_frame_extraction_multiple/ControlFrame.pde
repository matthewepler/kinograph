public class ControlFrame extends PApplet {

  int w, h;
  int padding = 0;
  
  public void setup() {
    size(w, h);
    //frameRate(25);
      cp5 = new ControlP5(this);
      cp5.setFont( font, 14 );
      CColor warning = new CColor( #FFFFFF, #E42523, #318E89, #1C1C1D, #1C008E );
      CColor refresh = new CColor( #FFFFFF, #FCE400, #318E89, #1C1C1D, #1C008E );
      CColor c       = new CColor( #FFFFFF, #56E44C, #318E89, #1C1C1D, #1C008E );
      
      //EDGE DETECTION
      // Canny Edges
      controlP5.Numberbox cannyLow = cp5.addNumberbox( "low" ).setPosition( 70, 80 ).setSize( 130, 20 ).setRange( 1, 150 ).setScrollSensitivity( 1.0 ).setValue( extractor.canny1 ).setDirection( Controller.HORIZONTAL ); 
      cannyLow.captionLabel().style().setMarginLeft( - 45 ).setMarginTop( - 20 );
      cannyLow.valueLabel().style().setMarginLeft( 80 ); 
      controlP5.Numberbox cannyHigh = cp5.addNumberbox( "high" ).setPosition( 70, 110).setSize( 130, 20 ).setRange( 1, 250 ).setScrollSensitivity( 1.0 ).setValue( extractor.canny2 ).setDirection( Controller.HORIZONTAL );
      cannyHigh.captionLabel().style().setMarginLeft( - 45 ).setMarginTop( - 20 );
      cannyHigh.valueLabel().style().setMarginLeft( 80 );
      // Hough Lines
      controlP5.Numberbox houghThresh = cp5.addNumberbox( "thresh" ).setPosition( 90, 180 ).setSize( 110, 20 ).setRange( 1, 600 ).setScrollSensitivity( 1.0 ).setValue( extractor.hLines1 ).setDirection( Controller.HORIZONTAL );
      houghThresh.captionLabel().style().setMarginLeft( -65 ).setMarginTop( -20 );
      houghThresh.valueLabel().style().setMarginLeft( 52 ); 
      controlP5.Numberbox houghMinLen = cp5.addNumberbox( "minLen" ).setPosition( 90, 210 ).setSize( 110, 20 ).setRange( 200, 800 ).setScrollSensitivity( 1.0 ).setValue( extractor.hLines2 ).setDirection( Controller.HORIZONTAL );
      houghMinLen.captionLabel().style().setMarginLeft( -65 ).setMarginTop( -20 );
      houghMinLen.valueLabel().style().setMarginLeft( 52 ); 
      controlP5.Numberbox maxGap = cp5.addNumberbox( "maxGap" ).setPosition( 90, 240 ).setSize( 110, 20 ).setRange( 1, 20 ).setScrollSensitivity( 1.0 ).setValue( extractor.hLines3 ).setDirection( Controller.HORIZONTAL );
      maxGap.captionLabel().style().setMarginLeft( -65 ).setMarginTop( -20 );
      maxGap.valueLabel().style().setMarginLeft( 67 ); 
      
      // SPROCKET SETTINGS
      // minEdgeLen
      controlP5.Numberbox minEdgeLen = cp5.addNumberbox( "minEdgeLen" ).setPosition( 120, 310 ).setSize( 80, 20 ).setRange( 10, 70 ).setValue( 40 ).setScrollSensitivity( 1.0 ).setDirection( Controller.HORIZONTAL );
      minEdgeLen.captionLabel().style().setMarginLeft( -95 ).setMarginTop( -20 ); 
      minEdgeLen.valueLabel().style().setMarginLeft( 30 );  
      // rowThresh
      controlP5.Numberbox rowThresh = cp5.addNumberbox( "rowThresh" ).setPosition( 120, 340 ).setSize( 80, 20 ).setRange( 1, 4 ).setValue( 1.0 ).setScrollSensitivity( 1.0 ).setDirection( Controller.HORIZONTAL );
      rowThresh.captionLabel().style().setMarginLeft( -95 ).setMarginTop( -20 );
      rowThresh.valueLabel().style().setMarginLeft( 37 ); 
      // colThresh
      controlP5.Numberbox colThresh = cp5.addNumberbox( "colThresh" ).setPosition( 120, 370 ).setSize( 80, 20 ).setRange( 1, 4 ).setValue( 1.0 ).setScrollSensitivity( 1.0 ).setDirection( Controller.HORIZONTAL );
      colThresh.captionLabel().style().setMarginLeft( -95 ).setMarginTop( -20 );
      colThresh.valueLabel().style().setMarginLeft( 37 ); 
      
      // FRAME ADJUST
      // Overall Padding
      controlP5.Button allPlus = cp5.addButton( "allPlus" ).setPosition( 100, 440 ).setSize( 20, 20 );
      allPlus.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button allMinus = cp5.addButton( "allMinus" ).setPosition( 125, 440 ).setSize( 20, 20 );
      allMinus.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      // Top
      controlP5.Button topPlus = cp5.addButton( "topPlus" ).setPosition( 100, 480 ).setSize( 20, 20 );
      topPlus.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button topMinus = cp5.addButton( "topMinus" ).setPosition( 125, 480 ).setSize( 20, 20 );
      topMinus.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      // Bottom
      controlP5.Button botPlus = cp5.addButton( "botPlus" ).setPosition( 100, 510 ).setSize( 20, 20 );
      botPlus.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button botMinus = cp5.addButton( "botMinus" ).setPosition( 125, 510 ).setSize( 20, 20 );
      botMinus.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      // Left
      controlP5.Button leftPlus = cp5.addButton( "leftPlus" ).setPosition( 100, 540 ).setSize( 20, 20 );
      leftPlus.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button leftMinus = cp5.addButton( "leftMinus" ).setPosition( 125, 540 ).setSize( 20, 20 );
      leftMinus.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      // Right
      controlP5.Button rightPlus = cp5.addButton( "rightPlus" ).setPosition( 100, 570 ).setSize( 20, 20 );
      rightPlus.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button rightMinus = cp5.addButton( "rightMinus" ).setPosition( 125, 570 ).setSize( 20, 20 );
      rightMinus.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      
      // ROI ADJUSTMENT
      // position
      controlP5.Button roiUp = cp5.addButton( "roiUp" ).setPosition( 100, 650 ).setSize( 20, 20 );
      roiUp.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button roiDown = cp5.addButton( "roiDown" ).setPosition( 125, 650 ).setSize( 20, 20 );
      roiDown.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      // size
      controlP5.Button sizeUp = cp5.addButton( "sizeUp" ).setPosition( 100, 680 ).setSize( 20, 20 );
      sizeUp.captionLabel().setText( "+" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      controlP5.Button sizeDown = cp5.addButton( "sizeDown" ).setPosition( 125, 680 ).setSize( 20, 20 );
      sizeDown.captionLabel().setText( "-" ).style().setMarginLeft( 2 ).setMarginTop( -1 );
      
      
                            // index, x,  y,  w,  h  
      cp5.addButton(" reset all", 0, 10, 800, 90, 30 ).setColor( warning ).plugTo( parent, "reset" );
      cp5.addButton("GO", 1, 110, 800, 100, 30 ).setColor( c ).plugTo( parent, "processAll" );
  }

  public void draw() {
      background( 50 );
      textFont( font );
      
      text( "ROTATION = " + (float)extractor.angleAvg, 25, 25 );
      text( "CANNY EDGES THRESH", 25, 70 );
      text( "HOUGH LINES", 25, 170 );
      text( "SPROCKET SETTINGS", 25, 300 );
      text( "FRAME MARGIN", 25, 430 );
      text( "ROI ADJUSTMENT", 25, 635 );
      
      textSize( 14 );
      text( "ALL", 25, 455 );
      text( "TOP", 25, 495 ); 
      text( "BOTTOM", 25, 525 );
      text( "LEFT", 25, 555 );
      text( "RIGHT", 25, 585 );
      text( "∆ = " + padding + ".0", 160, 455 );
      if( extractor.sprocketSet ) {
        text( extractor.frameRect.y + ".0", 160, 495 ); 
        text( extractor.frameRect.y + extractor.frameRect.height + ".0", 160, 525 ); 
        text( extractor.frameRect.x + ".0", 160, 555 );
        text( extractor.frameRect.x + extractor.frameRect.width + ".0", 160, 585 );
      }
      
      text( "POSITION", 25, 665 );
      text( "SIZE", 25, 695 );
      textSize( 16 );
  }
  
  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }
  
  public void update() {
    // Canny Edge Thresh
    controlP5.Controller cLow = cp5.getController( "low" );
    int newLow = (int)cLow.getValue();
    extractor.canny1 = newLow;

    
    controlP5.Controller cHigh = cp5.getController( "high" );
    int newHigh = (int)cHigh.getValue();
    extractor.canny2 = newHigh;
 
    
    // Hugh Lines
    controlP5.Controller t = cp5.getController( "thresh" );
    int newThresh = (int)t.getValue();
    if( processAll ) {
      b.e.hLines1 = newThresh; 
    } else {
      extractor.hLines1 = newThresh;
    }
    
    controlP5.Controller mLen = cp5.getController( "minLen" );
    int newMinLen = (int)mLen.getValue();
    if( processAll ) {
      b.e.hLines2 = newMinLen;
    } else {
      extractor.hLines2 = newMinLen;
    }
    
    controlP5.Controller mGap = cp5.getController( "maxGap" );
    int newMaxGap = (int)mGap.getValue();
    if( processAll ) {
      b.e.hLines3 = newMaxGap; 
    } else {
      extractor.hLines3 = newMaxGap;
    }
    
    // Sprockets    
    controlP5.Controller minEdge = cp5.getController( "minEdgeLen" );
    int newLen = (int)minEdge.getValue();
    if( processAll ) {
      b.e.minEdgeLen = newLen;
    } else {
      extractor.minEdgeLen = newLen;
    }
   
    controlP5.Controller rt = cp5.getController( "rowThresh" );
    int newRT = (int)rt.getValue();
    if( processAll ) {
      b.e.rowThresh = newRT; 
    } else {
      extractor.rowThresh = newRT;
    }
   
    controlP5.Controller ct = cp5.getController( "colThresh" );
    int newCT = (int)ct.getValue();
    if( processAll ) {
      b.e.colThresh = newCT; 
    } else {
      extractor.colThresh = newCT;
    } 
  }
  
  void updateFile() {
    controlP5.Controller s = cp5.getController( "scrubber" );
    int fileNum = (int)s.getValue();
    extractor.reload( files[ fileNum-1 ] ); 
  }
  
  // =============================================================== REFRESH ===== //
  void refresh() {
     update();
     extractor.go();
  }
  
  // ================================================ FRAME ADJUSTMENT FUNCS ===== //
  void allPlus() {
    padding += 2;
    extractor.frameRect.y -= 2; 
    extractor.frameRect.height += 2;
    extractor.frameRect.height += 2;
    extractor.frameRect.x -=2;
    extractor.frameRect.width += 2;
    extractor.frameRect.width += 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void allMinus() {
    padding -= 2;
    extractor.frameRect.y += 2;
    extractor.frameRect.height -= 2;
    extractor.frameRect.height -= 2;
    extractor.frameRect.x +=2;
    extractor.frameRect.width -= 2;
    extractor.frameRect.width -= 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void topPlus() { 
    extractor.frameRect.y -= 2; 
    extractor.frameRect.height += 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect); 
  }
  
  void topMinus() {
    extractor.frameRect.y += 2;
    extractor.frameRect.height -= 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void botPlus() {
    extractor.frameRect.height += 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void botMinus() {
    extractor.frameRect.height -= 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void leftPlus() {
    extractor.frameRect.x -=2;
    extractor.frameRect.width += 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);

  }
  
  void leftMinus() {
    extractor.frameRect.x +=2;
    extractor.frameRect.width -= 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void rightPlus() {
    extractor.frameRect.width += 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  void rightMinus() {
    extractor.frameRect.width -= 2;
    extractor.frame = extractor.extractFrame(extractor.frameRect);
  }
  
  
  // ROI ADJUSTMENTS
  void roiUp() {
    extractor.roiY -= 5;
    refresh();
  }
  
  void roiDown() {
    extractor.roiY += 5;
    refresh();
  }
  
  void sizeUp() {
    extractor.roiY -= 5;
    extractor.roiH += 5;
  }
  
  void sizeDown() {
    extractor.roiY += 5;
    extractor.roiH -= 5;
  }
  
  // REFRESH when values changed by user
  void mouseReleased() {
    if( mouseY < cf.h/2 ) {
      cf.refresh(); 
    }
  }
  
  
  ControlP5 cp5;

  Object parent;

  
}
