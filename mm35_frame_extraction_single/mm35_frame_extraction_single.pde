/*
  >> GUI to include:
  + all variables
  + threshold
 
  >> Frame doctor for frames with false positive results post-extraction
  
*/

import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;

import org.opencv.core.Point;

import java.awt.Rectangle;

/* random 3 images - run each and compare values
_MG_0351 copy.jpg
_MG_0490 copy.jpg
 */

String inputFilename = "001.jpg";
int resizedImageWidth = 800;

int roiTop = 100;
int roiBottom = 210;
int roiHeight = roiBottom - roiTop;
int searchColumn = 772;
int distanceBetweenSprockets = 70;
int minVerticalEdgeLength = roiBottom - roiTop;

// MINE
int frameRightTarget = 720;
int frameLeftTarget = 166;
int frameWidth = frameRightTarget - frameLeftTarget;
int frameHeight = 400;
int frameHorizMargin = 10;
int framePadding = 0;
int threshLevel = 90;


OpenCV sprocketProcessor, edgeProcessor;
PImage src, sprocketImage, edgeImage;
PGraphics output;

Rectangle selectedArea;

ArrayList<Contour> contours, approximations;
//ArrayList<MatOfPoint2f> approximations;

Rectangle roi;


void setup() {
  // load source image and resize it
  src = loadImage(inputFilename);
  src.resize(resizedImageWidth, 0);
  
  size(src.width * 2, src.height);

  roi = new Rectangle(0, roiTop, src.width, roiHeight);
  
  PImage binaryImage = createImage( roi.width, roi.height, ARGB );
  binaryImage.copy( src, roi.x, roi.y, roi.width, roi.height, 0, 0, roi.width, roi.height );
  
  sprocketProcessor = new OpenCV( this, binaryImage );
  sprocketProcessor.gray();
  sprocketProcessor.findSobelEdges(0, 2);
  sprocketProcessor.dilate();
  sprocketProcessor.threshold( threshLevel );
  
  sprocketImage = sprocketProcessor.getOutput();
  
  edgeProcessor = new OpenCV( this, binaryImage );
  edgeProcessor.gray();
  edgeProcessor.equalizeHistogram();
  edgeProcessor.findSobelEdges(2, 0);
  edgeProcessor.threshold( 100 );
  
  edgeImage = edgeProcessor.getOutput();
  
  // === BEGIN FIND TOP SPROCKETS EDGE === //

  int topSprocketEdge = 0;

  for (int row = 0; row < sprocketImage.height; row++) {
    int i = searchColumn + row*sprocketImage.width;

    if (brightness(sprocketImage.pixels[i]) > 0) {
      topSprocketEdge = row;
      break;
    }
  }

  // === FIND RIGHT FRAME EDGE === //

  contours = new ArrayList<Contour>();
  contours = edgeProcessor.findContours();
  contours = filterContours( contours );
  approximations = createPolygonApproximations(contours);
  //println("num approximations: " + approximations.size());
  
  
  // === CALCULATE FRAME DIMENSIONS === //
  float frameRight = 0;
  for (Contour edge : approximations) {
    ArrayList<PVector> edgePoints = edge.getPolygonApproximation().getPoints();
    float edgeX = edgePoints.get(0).x;
    if (edgeX > frameRight && edgeX < searchColumn) {
      frameRight = edgeX;
    }
  }

  float frameLeft = frameRight - frameWidth;
  selectedArea = new Rectangle((int)frameLeft - framePadding, topSprocketEdge - framePadding, frameWidth + (framePadding*2), frameHeight + (framePadding*2));

  output = createGraphics(selectedArea.width, selectedArea.height);
  output.beginDraw();
  output.copy(src, selectedArea.x, roi.y + selectedArea.y, selectedArea.width, selectedArea.height, 0, 0, selectedArea.width, selectedArea.height);
  output.endDraw();
}


// === HELPER FUNCTIONS ===

ArrayList<Contour> filterContours(ArrayList<Contour> cntrs) {
  ArrayList<Contour> result = new ArrayList<Contour>();
  for (Contour contour : cntrs) {
    if (contour.getPoints().size() > minVerticalEdgeLength) {
      result.add(contour);
    }
  }
  return result;
}

ArrayList<Contour> createPolygonApproximations(ArrayList<Contour> cntrs) {
  ArrayList<Contour> result = new ArrayList<Contour>();

  //double epsilon = cntrs.get(0).getPoints().size().height * 0.01;

  for (Contour contour : cntrs) {
    Contour approx = contour.getPolygonApproximation();
    result.add(approx);
  }

  return result;
}

void drawContours(ArrayList<Contour> cntrs) {
  for (Contour contour : cntrs) {
    beginShape();
    ArrayList<PVector> points = contour.getPoints();
    for (int i = 0; i < points.size(); i++) {
      PVector p = points.get( i );
      vertex((float)p.x, (float)p.y);
    }
    endShape();
  }
}


void draw() {
  background(125);
  fill(0);
  text("press 's' to save output frame", 563, 756);
  // scale(0.5);
  image(src, 0, 0);
  image(sprocketImage, src.width, 5);
  image(edgeImage, src.width, roi.height + 10);
  image(output, src.width + 120, roi.y + roi.height + 50 );
  
  
  noFill();
  strokeWeight(4);
  stroke(255, 0, 0);
  rect(roi.x, roi.y, roi.width, roi.height);
  strokeWeight(1);

  stroke(0, 0, 255);
  translate(roi.x, roi.y);
  line(searchColumn, 0, searchColumn, src.height);

  stroke(255);
  strokeWeight(3);
  drawContours(approximations);

  strokeWeight(5);
  stroke(0, 255, 0);
  rect(selectedArea.x, selectedArea.y, selectedArea.width, selectedArea.height);

  println( mouseX + " : " + mouseY );
}

void keyPressed() {
  if (key == 's') {
    output.save( "output.jpg" );
  }
}

