/*
  Use your mouse position to set the global variables.
  All images should be rotated before running this program (I use Photoshop actions). Also crop if necessary.
  
  Copyright (C) 2013 Matthew Epler

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 */

// Greg Borenstein's OpenCV Library for Processing 2.0
// https://github.com/atduskgreg/opencv-processing
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.CvType;

import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;

import org.opencv.core.Point;
import javax.activation.MimetypesFileTypeMap;

import java.awt.Rectangle;

// put the absolute path to your data folder for this sketch here
String path = "/Users/matthewepler/Documents/myProjects/Kinograph/code_current/kinograph/mm35_frame_extraction_multiple/data";
int resizedImageWidth = 800;

int roiTop = 99;
int roiBottom = 223;
int roiHeight = roiBottom - roiTop;
int searchColumn = 765;
int distanceBetweenSprockets = 61;
int minVerticalEdgeLength = roiBottom - roiTop;

int frameRightTarget = 715;
int frameLeftTarget = 202;
int frameWidth = frameRightTarget - frameLeftTarget;
int frameHeight = 375;
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
  File dir = new File( path );
  File[] fileDir = dir.listFiles();
  String[] files;

  if ( dir.isDirectory() ) {
    files = dir.list();
    String success = "Directory \'" + dir.getName() + "\' loaded successfully.";
    println( success );
  }  else {
    String fail = "Failed to load directory. Please verify the path string.";
    fail += "\n";
    fail += "Path = " + path;
    println( fail );
    exit();
  }
  
  for ( int i = 0; i < fileDir.length; i++ ) {
    File thisFile = fileDir[ i ];
    String thisFileName = thisFile.getName();
    if ( thisFileName.contains(".jpg") ) {
      try {
        // load source image and resize it
        src = loadImage(thisFileName);
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
          int c = searchColumn + row*sprocketImage.width;

          if (brightness(sprocketImage.pixels[c]) > 0) {
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
        //  for (Contour edge : approximations) {
        //    ArrayList<PVector> edgePoints = edge.getPolygonApproximation().getPoints();
        //    float edgeX = edgePoints.get(0).x;
        //    if (edgeX > frameRight && edgeX < searchColumn) {
        //      frameRight = edgeX;
        //    }
        //  }
        //
        //  float frameLeft = frameRight - frameWidth;
        //  selectedArea = new Rectangle((int)frameLeft - framePadding, topSprocketEdge - framePadding, frameWidth + (framePadding*2), frameHeight + (framePadding*2));

        /* If you've chosen to use the left side sprockets for your seach column,
         or you want to force the program to use your frameTargetLeft and frameTargetRight values,
         use this one line. (Don't forget to comment out the lines preceeding it, starting at
         "float frameRight = 0," and ending at the new Rectangle line.)
         */
        selectedArea = new Rectangle( frameLeftTarget - framePadding, topSprocketEdge - framePadding, frameRightTarget - frameLeftTarget + (framePadding * 2), frameHeight + (framePadding * 2 ));

        output = createGraphics(selectedArea.width, selectedArea.height);
        output.beginDraw();
        output.copy(src, selectedArea.x, roi.y + selectedArea.y, selectedArea.width, selectedArea.height, 0, 0, selectedArea.width, selectedArea.height);
        output.save( "output/" + thisFileName );
        println( i + " of " + fileDir.length + " complete.");
        output.endDraw();
        
      } 
      catch( Exception e ) {
        println( " " );
        println( "-----" );
        println( "Error: " + thisFileName );
        println( e );
        println( "-----" );
        println( " " );
      }
    }
  }
  println("PROCESS COMPLETE!");
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


