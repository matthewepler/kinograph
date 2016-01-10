# Kinograph Project Code Repository

## Summary

Code for the kinograph project v0.1 (http://kinograph.cc). Videos describing how to use the machine and this software together will be located there.

Kinograph is a DIY Film Scanner/Telecine for 35mm, 16mm, and 8mm film (8mm is still in development and not included in the project at this time). This entire project is just getting started and should be considered highly experimental (read: nowhere near full public release), but I want to make it available to those with an interest in helping improve its current state. 

## Arduino - Electronics Control (For controlling machine)

### openFrameworks
If you are familiar with openFrameworks, you can use this code in tandem with the Arduino hardware. You will need to upload the Standard Firmata code for your Arduino to communicate with the app. 

You DO NOT have to use this code to get Kinograph to work. If you're more familiar with Arduino code, just use that instead. The only difference between the two is the on-screen feedback (current speed, # of pictures taken, etc.)

Plug in the Arduino to your computer via USB. Change the port string for the Arduino in the code. Power up your power supply and camera. When ready, start the OF app by clicking "Run" in XCode.

### Arduino
Use the Arduino code if you do not need on-screen feedback of frame capture rate. This code has everything the OF code has, including auto speed control if you want it. The only thing it doesn't have is the on-screen feedback.

This code is written in Arduino for the Arduino UNO board. Instructions for electronics assembly can be found on the [Instructables site](http://www.instructables.com/id/Kinograph-v01-DIY-Film-Scanner/step9/Electronics/).

Upload this code, connect your power supply, camera, and the switch on your Kinograph to operate.

## Processing - Frame Extraction (Post-processing of images captured by Kinograph machine)

These programs are written in Processing and extract single frames from raw images of film captured with the Kinograph machine (or any other machine, really). The underlying logic is that all frames can be identified in relation to sprocket holes. Because sprocket hole spacing is different for every gauge of film, there are different programs for each gauge. 

[This video](https://vimeo.com/134367767) describes how to use this software (16mm only right now).

### Dependencies
[Processing 2.2.1](https://processing.org/download/?processing) NOTE: This does not work with Processing 3.

[Control P5 library v 2.0.4 for Processing](https://code.google.com/p/controlp5/downloads/detail?name=controlP5-2.0.4.zip&can=2&q=) NOTE: Download the zip file at this link and [install manually](https://github.com/processing/processing/wiki/How-to-Install-a-Contributed-Library). You must use this version. Processing will ask you if you want to update the library. DO NOT udpate. 

[OpenCV library for Processing by Greg Borenstein](https://github.com/atduskgreg/opencv-processing) NOTE: You should install this library from within Processing by using the menu bar Sketch > Import Library > Add Library. Search for "opencv" and select the one with "Greg Borenstein" as the author. Click the Import button and restart Processing when install is complete. 

### Details
So far, there are two approaches:

The 16mm software is more advanced than 35mm software right now. It allows you to load a whole folder of images, find the proper thresholds and ROI (region of interest) information and use those setting to extract frames from all images in the folder. It isn't pretty looking but it works. This approach uses brightness information in a binary image to find sprocket positions and then extracts the frame relative to the sprocket's location.

35mm extraction currently relies on the user evaluating a single frame and capturing coordinates manually. Assuming your collection of frames was caputred with minimum flutter in the gate, those values should work for almost all of your frames. Obviously, this is not ideal but allows the most direct control over the software.

Contact me directly (info@kinograph.cc) if you have any questions or comments. 

### Alternatives 
Charles Pomanski, a member of the Kinograph community, has made videos showing how he uses Blender and Fusion to stabilize a sequence of frames captured with the Kinograph machine. You can see them on YouTube:

[Image Stabilization with Blender](https://www.youtube.com/watch?v=Y5o09uRTzdU)

[Image Registration with Fusion 7](https://www.youtube.com/watch?v=EE_T-g8w2Pc)

