import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress dest;

import processing.serial.*;
import cc.arduino.*;

//Constants
int ARDUINO_PORT_INDEX = 2;
int MAX_ANGLE = 75;
int MIN_ANGLE = 0;

int MIN_ANGLE_OUTER = 0;
int MAX_ANGLE_OUTER = 175;
int MIN_ANGLE_MIDDLE = 150;
int MAX_ANGLE_MIDDLE = 0;
int MIN_ANGLE_INNER = 10;
int MAX_ANGLE_INNER = 160;

//Pins
int ledPin = 3;
int servo1Pin = 9;
int servo2Pin = 10;
int servo3Pin = 11;

//Global Variables
Arduino arduino;
int brightness = 0;

int servo1Angle = 0;
int servo2Angle = 0;
int servo3Angle = 0;

float breathingValue1 = 0.0f;
float breathingValue2 = 0.0f;
float breathingValue3 = 0.0f;

void setup() {  
  oscP5 = new OscP5(this, 12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1", 6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  arduino = new Arduino(this, Arduino.list()[ARDUINO_PORT_INDEX]);

  setupPins();
  printArduinoList();
  size(400, 400, P3D);  
  background(255);
  sendOscNames();
}

void setupPins() {
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  arduino.pinMode(servo1Pin, Arduino.SERVO);
  arduino.pinMode(servo2Pin, Arduino.SERVO);
  arduino.pinMode(servo3Pin, Arduino.SERVO);
}

void printArduinoList() {
  for (String name : Arduino.list()) {
    println(name);
  }
}

void moveServos() {
  arduino.servoWrite(servo1Pin, servo1Angle);
  arduino.servoWrite(servo2Pin, servo2Angle);
  arduino.servoWrite(servo3Pin, servo3Angle);
}

void draw() {
  arduino.analogWrite(ledPin, brightness);
  moveServos();
  delay(20);
}

void calculateBreathingSyncState() {
  float diff12 = max(breathingValue1, breathingValue2) - min(breathingValue1, breathingValue2);
  float diff13 = max(breathingValue1, breathingValue3) - min(breathingValue1, breathingValue3);
  float diff23 = max(breathingValue2, breathingValue3) - min(breathingValue2, breathingValue3);
  float syncValue = (diff12 + diff13 + diff23) / 3.0f;  
  float maxDiff = 2.0/3.0;  
  //brightness = int(map(syncValue, 0, maxDiff, 255, 0));

  if (syncValue < 0.25) {
    brightness = 255;
  } else {
    brightness = 0;
  }

  println(diff12);
  println(diff13);
  println(diff23);
  println("---------");
  println(syncValue);
  println("\n\n");
}

void processInput(int inputSource, float value) {
  float adjustedValue = constrain(value, 0, 1);
  adjustedValue = round(adjustedValue * 100.0f) / 100.0f;   

  if (inputSource == 1) {
    breathingValue1 = adjustedValue;
    servo1Angle = int(map(adjustedValue, 0, 1, MIN_ANGLE_INNER, MAX_ANGLE_INNER));
  }

  if (inputSource == 2) {
    breathingValue2 = adjustedValue;
    servo2Angle = int(map(adjustedValue, 0, 1, MIN_ANGLE_MIDDLE, MAX_ANGLE_MIDDLE));
  }

  if (inputSource == 3) {
    breathingValue3 = adjustedValue;
    servo3Angle = int(map(adjustedValue, 0, 1, MIN_ANGLE_OUTER, MAX_ANGLE_OUTER));
  }

  calculateBreathingSyncState();
}

void oscEvent(OscMessage theOscMessage) {

  //theOscMessage.print();

  String pattern = theOscMessage.addrPattern();
  if (!pattern.substring(0, 4).equals("/wek")) return;
  int inputSource = Integer.parseInt(pattern.substring(14, 15));  

  if (theOscMessage.checkTypetag("f")) {
    float receivedValue = theOscMessage.get(0).floatValue();
    processInput(inputSource, receivedValue);
  } else {
    println("Error: unexpected OSC message received by Processing: ");
    theOscMessage.print();
  }
}

//Sends current parameter to Wekinator
void sendOscNames() {
  OscMessage msg = new OscMessage("/wekinator/control/setOutputNames");
  msg.add("breathing1");
  msg.add("breathing2");
  msg.add("breathing3");
  oscP5.send(msg, dest);
}