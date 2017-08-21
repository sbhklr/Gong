#include <Servo.h>                           // Include servo library

//Servo Middle 0 - 150
//Servo Outer 0 - 175
//Servo Inner 10 - 160
#define MINA 10
#define MAXA 160
#define DELAY 40
 
Servo servoOuter;                             // Declare left servo
Servo servoMiddle;
Servo servoInner;

int counter = 0;
int direction = 1;

void setup()                                 // Built in initialization block
{
  servoOuter.attach(9);                      // Attach left signal to pin 13
  servoMiddle.attach(8);
  servoInner.attach(7);
  
  //servoOuter.writeMicroseconds(500);         // 1.5 ms stay still signal  
  //servoOuter.write(180);
  Serial.begin(9600);
}  
 
void loop()                                  // Main loop auto-repeats
{                                            // Empty, nothing needs repeating

  counter = counter + direction;
  if(counter > 180){
    counter = 180;
    direction *= -1;
  }

  if(counter < 0){
    counter = 0;
    direction *= -1;
  }


  // for(int i = MINA; i <= MAXA; ++i){
  //   servoOuter.write(i);
  //   //servoOuter.writeMicroseconds(map(i,0,180,500,2500));
  //   delay(DELAY);
  //   Serial.println(i);
  // }
  // delay(1000);

  // for(int i = MAXA; i >= MINA; --i){
  //   servoOuter.write(i);
  //   //servoOuter.writeMicroseconds(map(i,0,180,500,2500));
  //   delay(DELAY);
  //   Serial.println(i);
  // }
  
  servoInner.write(map(counter,0,180,5,160));
  servoMiddle.write(map(counter,0,180,150,0));
  servoOuter.write(map(counter,0,180,5,165));
  delay(38);

  if(counter == 180 || counter == 0){
    delay(1500);
  }
}
