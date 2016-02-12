#include <Adafruit_NeoPixel.h>
#include <Servo.h>   //arduino servo library to control the motors
#include <avr/power.h>

#define PIN 6

unsigned long flashTimeMark=0;
int svc[12]={                                              // servo center positions (typically 1500uS)
  1500,1550,1550,1450,                                     // D13 knee1, D12 Hip1, D11 knee2, D10 Hip2
  1500,1400,1500,1550,                                     // D29 knee3, D30 Hip3, D31 knee4, D32 Hip4
  1500,1500,1500,1400                                      // D46 knee5, D47 Hip5, D48 knee6, D49 Hip6
};

Servo sv[12];                                              

int angle;                                                 // determines the direction/angle (0°-360°) that the robot will walk in 
int rotate;                                                // rotate mode: -1 = anticlockwise, +1 = clockwise, 0 = no rotation
int Speed;                                                 // walking speed: -15 to +15 
int Stride;                                                // size of step: exceeding 400 may cause the legs to hit each other

boolean walkMode = false;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(31, PIN, NEO_GRB + NEO_KHZ800);

void setup()
{
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);

  sv[0].attach(13,800,2200);                               // knee 1 
  delay(40);
  sv[1].attach(12,800,2200);                               // Hip  1
  delay(40);
  sv[2].attach(11,800,2200);                               // knee 2
  delay(40);
  sv[3].attach(10,800,2200);                               // Hip  2
  delay(40);
  sv[4].attach(29,800,2200);                               // knee 3
  delay(40);
  sv[5].attach(30,800,2200);                               // Hip  3
  delay(40);
  sv[6].attach(31,800,2200);                               // knee 4
  delay(40);
  sv[7].attach(32,800,2200);                               // Hip  4
  delay(40);
  sv[8].attach(46,800,2200);                               // knee 5
  delay(40);
  sv[9].attach(47,800,2200);                               // Hip  5
  delay(40);
  sv[10].attach(48,800,2200);                              // knee 6
  delay(40);
  sv[11].attach(49,800,2200);                              // Hip  6
  delay(40);

  for(int i=0;i<12;i++)
  {
    sv[i].writeMicroseconds(svc[i]);                       // initialize servos
  }

  angle = rotate = 0; //no angle or rotation by default
  Speed = 6; //initialize default speed
  Serial.begin(19200); //need fast serial baude to capture the bluetooth data.

  delay(3000);      
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  
  colorWipe(strip.Color(0, 0, 255), 50); // Blue
}  

void loop()
{ 
  
  if(Serial.available() > 0)
  {    
    char remoteByte = (char)Serial.read();

    if(remoteByte == 'l')                              // STOP
    {
      rotate = 0;
      angle = 0;
      walkMode = false;
    }

    if(remoteByte == 'w')                             // FORWARD
    {
      angle = 0;
      rotate = 0;
      if(Speed < 0)
        Speed *= -1;
      walkMode = true;
    }

    if(remoteByte == 'a')                             // REVERSE    
    {
      rotate = 0;
      angle = 0;
      if(Speed > 0)
        Speed *= -1;
      walkMode = true;
    }

    if(remoteByte == 'z')                                          // ROTATE CLOCKWISE  
    {
      walkMode = true;
      rotate=1;
      angle=0;
    }

    if(remoteByte == 'e')                                          // ROTATE COUNTER CLOCKWISE  
    {
      walkMode = true;
      rotate=-1;
      angle=0;
    }

    if(remoteByte == 'd')                                          // INCREASE WALKING ANGLE 
    {
      walkMode = true;
      rotate=0;
      angle=90;
    }

    if(remoteByte == 's')                                          // DECREASE WALKING ANGLE
    {
      walkMode = true;
      rotate=0;
      angle=270;
    }
    if(remoteByte == 'k')                                          //SPEED UP
    {
      if(Speed < 12 && Speed != 0)
        Speed += 1; 
    }
    if(remoteByte == 'q')                                          //SLOW DOWN
    {
      if(Speed > -12 && Speed != 0)
        Speed -= 1; 
    }
  }
  // keep travel angle within 0°-360°
  if(walkMode == true)
    Walk();                                                  // move legs to generate walking gait
  delay(15);
}


void Walk()                                                // all legs move in a circular motion
{
  if(Speed==0)                                             // return all legs to default position when stopped
  {
    Stride-=25;                                            // as Stride aproaches 0, all servos return to center position
    if(Stride<0) Stride=0;                                 // do not allow negative values, this would reverse movements
  }
  else                                                     // this only affects the robot if it was stopped
  {
    Stride+=25;                                            // slowly increase Stride value so that servos start up smoothly
    if(Stride>450) Stride=450;                             // maximum value reached, prevents legs from colliding.
  }
  
  float A;                                                 // temporary value for angle calculations
  double Xa,Knee,Hip;                                      // results of trigometric functions
  static int Step;                                         // position of legs in circular motion from 0° to 360°                               
  
  for(int i=0;i<6;i+=2)                                    // calculate positions for odd numbered legs 1,3,5
  {
    A=float(60*i+angle);                                   // angle of leg on the body + angle of travel
    if(A>359) A-=360;                                      // keep value within 0°-360°
   
    A=A*PI/180;                                            // convert degrees to radians for SIN function
    
    Xa=Stride*rotate;                                      // Xa value for rotation
    if(rotate==0)                                          // hip movement affected by walking angle
    {
      Xa=sin(A)*-Stride;                                   // Xa hip position multiplier for walking at an angle
    }
        
    A=float(Step);                                         // angle of leg
    A=A*PI/180;                                            // convert degrees to radians for SIN function
    Knee=sin(A)*Stride;
    Hip=cos(A)*Xa;
    
    sv[i*2].writeMicroseconds(svc[i*2]+int(Knee));         // update knee  servos 1,3,5
    sv[i*2+1].writeMicroseconds(svc[i*2+1]+int(Hip));      // update hip servos 1,3,5
  }
  
  for(int i=1;i<6;i+=2)                                    // calculate positions for even numbered legs 2,4,6
  {
    A=float(60*i+angle);                                   // angle of leg on the body + angle of travel
    if(A>359) A-=360;                                      // keep value within 0°-360°
   
    A=A*PI/180;                                            // convert degrees to radians for SIN function
    Xa=Stride*rotate;                                      // Xa value for rotation
    if(rotate==0)                                          // hip movement affected by walking angle
    {
      Xa=sin(A)*-Stride;                                   // Xa hip position multiplier for walking at an angle
    }
        
    A=float(Step+180);                                     // angle of leg
    if(A>359) A-=360;                                      // keep value within 0°-360°
    A=A*PI/180;                                            // convert degrees to radians for SIN function
    Knee=sin(A)*Stride;
    Hip=cos(A)*Xa;
    
    sv[i*2].writeMicroseconds(svc[i*2]+int(Knee));         // update knee  servos 2,4,6
    sv[i*2+1].writeMicroseconds(svc[i*2+1]+int(Hip));      // update hip servos 2,4,6
  }
  
  Step+=Speed;                                             // cycle through circular motion of gait
  if (Step>359) Step-=360;                                 // keep value within 0°-360°
  if (Step<0) Step+=360;                                   // keep value within 0°-360°
}

void colorWipe(uint32_t c, uint8_t wait) {
  for(uint16_t i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      strip.show();
      delay(wait);
  }
}
