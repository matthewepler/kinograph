#pragma once

#include "ofMain.h"

class ofApp : public ofBaseApp{
    
public:
    void setup();
    void update();
    void draw();
    void keyReleased(int key);
    void setupArduino( const int & version );
    
    bool    bSetupArduino;			// flag variable for setting up arduino once
    bool    sprocket;
    int     counter;
    int     potValue;
    float   sensorValue;
    float   currMillis, prevMillis, fps;
    float   targetFps;
    float   speed;
    int     captureCount;
    
    ofArduino arduino;
    ofTrueTypeFont font;
    
    
};
