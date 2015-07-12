# Kinograph Project Code Repository

## Summary

Code for the kinograph project v0.1 (http://kinograph.cc). Videos describing how to use the machine and this software together will be located there.

Kinograph is a DIY Film Scanner/Telecine for 35mm, 16mm, and 8mm film (8mm is still in development and not included in the project at this time). This entire project is just getting started and should be considered highly experimental (read: nowhere near full public release), but I want to make it available to those with an interest in helping improve its current state. 

## Arduino - Electronics Control (For controlling machine)

This code is written in Arduino for the Arduino UNO board. Instructions for electronics assembly can be found on the [Instructables site](http://www.instructables.com/id/Kinograph-v01-DIY-Film-Scanner/step9/Electronics/).

Upload this code, connect your power supply, camera, and the switch on your Kinograph to operate.

## Processing - Frame Extraction (Post-processing of images captured by Kinograph machine)

These programs are written in Processing and extract single frames from raw images of film captured with the Kinograph machine (or any other machine, really). The underlying logic is that all frames can be identified in relation to sprocket holes. Because sprocket hole spacing is different for every gauge of film, there are different programs for each gauge. 

### Dependencies
[Processing](http://processing.org)

[Control P5 library for processing](http://www.sojamo.de/libraries/controlP5/)

[OpenCV library for Processing by Greg Borenstein](https://github.com/atduskgreg/opencv-processing)

### Details
So far, there are two approaches:

The 16mm software is more advanced than 35mm software right now. It allows you to load a whole folder of images, find the proper thresholds and ROI (region of interest) information and use those setting to extract frames from all images in the folder. It isn't pretty looking but it works. This approach uses brightness information in a binary image to find sprocket positions and then extracts the frame relative to the sprocket's location.

35mm extraction currently relies on the user evaluating a single frame and capturing coordinates manually. Assuming your collection of frames was caputred with minimum flutter in the gate, those values should work for almost all of your frames. Obviously, this is not ideal but allows the most direct control over the software.

Contact me directly (info@kinograph.cc) if you have any questions or comments. 
