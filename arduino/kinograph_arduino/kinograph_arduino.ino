// Kinograph - Electronics Control
// Updated July, 2015 by M.Epler
// kinograph.cc

int sensorPin = 8;
int ledPin = 13;
int motorPin = 6; 

boolean sprocket;
float prevMills = 0;
int captureCount = 0;

float targetFps = 2;
int speed = 100;

void setup() {
  Serial.begin(9600);
  pinMode(sensorPin, OUTPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(motorPin, OUTPUT);
  sprocket = false;
}

void loop() {
  int sensorValue = digitalRead(sensorPin);
  Serial.print(sensorValue);
  Serial.print(" : ");
  Serial.println(sprocket);
  
  if(sensorValue == 0) {
    if(!sprocket) {
      Serial.println("here");
      double currMills = millis();
      digitalWrite(ledPin, HIGH);
      delay(100);
      digitalWrite(ledPin, LOW);

      float elap = currMills - prevMills;
      float fps = (1 / elap ) * 1000;
      prevMills = currMills;
      captureCount += 1;

      if(fps < targetFps) {
        speed += 2;
      } else if(fps > targetFps) {
        speed -= 2;
      }
      sprocket = true;
    }
  } else if(sensorValue == 1) {
      sprocket = false;
  }
  
  speed = constrain(speed, 0, 255);
  analogWrite(motorPin, speed);
}
