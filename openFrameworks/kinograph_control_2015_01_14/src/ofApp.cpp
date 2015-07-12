#include "ofApp.h"
#include <ofMath.h>
#include <math.h>

#define POTPIN 1    // A1 on Arduino Uno  (analog INPUT )
#define SENSORPIN 8 // 8  on Arduino Uno  (digital INPUT)
#define MOTORPIN 6  // 6  on Arduino Uno  (PWM)
#define LEDPIN 13   // 13  on Arduino Uno  (digital OUTPUT)
#define CAMPIN 10   // 10 on Arduino Uno  (digital OUTPUT)

void ofApp::setup()
{
    //ofSetVerticalSync( false );
    
    arduino.connect( "/dev/tty.usbmodemfa131", 57600 );
    
    ofAddListener(arduino.EInitialized, this, &ofApp::setupArduino);
    bSetupArduino	= false;
    
    font.loadFont("DIN.otf", 64);
    
    counter = 0;
    targetFps = 2;
    speed = 100;
    
    arduino.sendDigital( LEDPIN, ARD_LOW );
}

void ofApp::update()
{
    arduino.update();
    
    if (bSetupArduino)
    {
        sensorValue = arduino.getDigital( SENSORPIN );
        
        if( sensorValue == 0 )
        {
            if( !sprocket )
            {
                {
                    currMillis = ofGetElapsedTimeMillis();
                    arduino.sendDigital( LEDPIN, ARD_HIGH );
                    ofSleepMillis( 100 );
                    arduino.sendDigital( LEDPIN, ARD_LOW );
                    
                    // calculate frames per second
                    float elap = currMillis - prevMillis;
                    fps = ( 1 / elap ) * 1000;
                    prevMillis = currMillis;
                    captureCount += 1;
                    
                    if( fps < targetFps )
                    {
                        speed += 2;
                    } else if( fps > targetFps ) {
                        speed -= 2;
                    }
                }
            }
            sprocket = true;
        } else if ( sensorValue == 1 )
        {
            sprocket = false;
        }
    }
    
    speed = ofClamp( speed, 0, 255 );
    arduino.sendPwm( MOTORPIN, speed );
}


void ofApp::draw()
{
    ofBackground( 200, 200, 200 );
    ofSetColor(20);
    
    string msg;
    msg += "Frame Rate: " + ofToString( ofGetFrameRate() ) + "\n";
    msg += "SensorValue =  " + ofToString( sensorValue ) + "\n";
    msg += "\n";
    msg += "Speed : " + ofToString( speed ) + "\n";
    msg += "FPS : " + ofToString( fps ) + "\n";
    msg += "Frames Captured: " + ofToString( captureCount );
    font.drawString(msg, 50, 100);
    
    
}


void ofApp::keyReleased(int key)
{
    if( key == ' ' )
    {
        arduino.sendDigital( LEDPIN, ARD_HIGH );
        ofSleepMillis( 100 );
        arduino.sendDigital( LEDPIN, ARD_LOW );
    }
}


void ofApp::setupArduino( const int & version )
{
    ofRemoveListener( arduino.EInitialized, this, &ofApp::setupArduino );
    
    bSetupArduino = true;
    
    cout << arduino.getFirmwareName() << endl;
    cout << "firmata v" << arduino.getMajorFirmwareVersion() << "." << arduino.getMinorFirmwareVersion() << endl;
    
    arduino.sendDigitalPinMode( SENSORPIN, ARD_INPUT );
    arduino.sendDigitalPinMode( LEDPIN, ARD_OUTPUT );
    arduino.sendDigitalPinMode( CAMPIN, ARD_OUTPUT );
    arduino.sendAnalogPinReporting( POTPIN, ARD_ANALOG );
    arduino.sendDigitalPinMode( MOTORPIN, ARD_PWM );
}


