import gab.opencv.*;
import java.util.*;
import java.awt.Rectangle;

import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;
ControlFrame cf, fileSlider, finalFrame;

PFont font;
boolean reset, process, processAll;
String path = "/Volumes/3TBONE/kinograph/code/mm16_frame_extraction/data";
File dir;
String[] files;
int currentFrame = 1;

Extractor extractor;

boolean scrubber;

void setup() {
  getDirectory();
  extractor = new Extractor( this, 800 ); // int for resizing original image
  size( extractor.mWidth * 2, extractor.mHeight + 50 );

  font = loadFont( "HelveticaNeue-Light-16.vlw" );
  textFont( font, 18 );

  initControls();
}


void draw() {
  if ( mouseY > height - 75 ) {
    scrubber = true;
  } 
  else {
    scrubber = false;
  }

  background( 50 );
  extractor.display();
}


// ============================================================= MOUSE RELEASED ========= //
void mouseReleased() {
  if ( !scrubber ) {
    if ( !extractor.roiSet ) {
      extractor.roiSet = true;
    } 
    else {
      extractor.roiSet = false;
    }
  } 
  else {
    if ( currentFrame > 0 ) {
      extractor.reload( files[ currentFrame - 1 ] );
      extractor.roiSet = true;
      extractor.sprocketSet = false;
    }
  }
}


// ============================================================= INIT CONTROLS ========= //
void initControls() {
  cp5 = new ControlP5( this );
  cf = addControlFrame( "Controls", 225, 900, 0, 0 );

  controlP5.Slider scrubber = cp5.addSlider( "scrubber" );
  scrubber.setPosition( 75, height- 40 ).setSize( width - 100, 20 );
  scrubber.setRange( 1, files.length );
  scrubber.setNumberOfTickMarks( 24 );
  scrubber.setDefaultValue( files.length/2 );
  scrubber.snapToTickMarks( false );
  scrubber.setSliderMode(Slider.FLEXIBLE);
  int currFileNumber = int( scrubber.valueLabel().toString() );
  scrubber.setValueLabel( "File " + currFileNumber + " of " + (files.length-1) );
  scrubber.setCaptionLabel( "" );
}


// ============================================================= CONTROL FRAME ========= //
ControlFrame addControlFrame(String theName, int theWidth, int theHeight, int locX, int locY ) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation( locX, locY );
  f.setResizable(false);
  f.setVisible(true);
  return p;
}

void scrubber( int value )
{
  currentFrame = value;
  controlP5.Controller s = cp5.getController( "scrubber" );
  s.setValueLabel( "File " + value + " of " + files.length );
}

void getDirectory() {
  dir = new File( path );

  if ( dir.isDirectory() )
  {
    files = dir.list();
    String success = "Directory \'" + dir.getName() + "\' loaded successfully.";
    println( success );
  } 
  else
  {
    String fail = "Failed to load directory. Please verify the path string.";
    fail += "\n";
    fail += "Path = " + path;
    println( fail );
  }
}

void reset() {
  extractor = new Extractor( this, 800 ); 
  initControls();
}

void saveAll() {
  // save values to be used for batch processing
  // that process will be based on existing code for 35mm (see repo)
}

