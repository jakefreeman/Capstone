/* MPU9250 Basic Example Code
 by: Kris Winer
 date: April 1, 2014
 license: Beerware - Use this code however you'd like. If you
 find it useful you can buy me a beer some time.
 Modified by Brent Wilkins July 19, 2016

 Demonstrate basic MPU-9250 functionality including parameterizing the register
 addresses, initializing the sensor, getting properly scaled accelerometer,
 gyroscope, and magnetometer data out. Added display functions to allow display
 to on breadboard monitor. Addition of 9 DoF sensor fusion using open source
 Madgwick and Mahony filter algorithms. Sketch runs on the 3.3 V 8 MHz Pro Mini
 and the Teensy 3.1.

 SDA and SCL should have external pull-up resistors (to 3.3V).
 10k resistors are on the EMSENSR-9250 breakout board.

 Hardware setup:
 MPU9250 Breakout --------- Arduino
 VDD ---------------------- 3.3V
 VDDI --------------------- 3.3V
 SDA ----------------------- A4
 SCL ----------------------- A5
 GND ---------------------- GND
 */

#include "complimentaryFilter.h"
#include "MPU9250.h"


#define AHRS true         // Set to false for basic data read
#define SerialDebug true  // Set to true to get Serial output for debugging
#define pi 3.141592645

// Pin definitions
int intPin = 12;  // These can be changed, 2 and 3 are the Arduinos ext int pins
int myLed  = 13;  // Set up pin 13 led for toggling
int count = 0;
float XAccOffset=0.0; // calculated offset from average calibration data
float YAccOffset=0.0; // calculated offset from average calibration data
float ZAccOffset=0.0; // calculated offset from average calibration data

float XOffset = -0.05445861;
float YOffset = -0.003;
float ZOffset = 0.001513894;
float temp_mag;
float rest_angle;

MPU9250 myIMU;

void setup()
{
  pinMode(11, OUTPUT);
  flashLED(5,2);
  Wire.begin();
  // TWBR = 12;  // 400 kbit/sec I2C speed
  Serial.begin(9600);
  Serial1.begin(115200);//was 19200

  // Set up the interrupt pin, its set as active high, push-pull
  pinMode(intPin, INPUT);
  digitalWrite(intPin, LOW);
  pinMode(myLed, OUTPUT);
  digitalWrite(myLed, HIGH);



  // Read the WHO_AM_I register, this is a good test of communication
  byte c = myIMU.readByte(MPU9250_ADDRESS, WHO_AM_I_MPU9250);
  Serial.print("MPU9250 "); Serial.print("I AM "); Serial.print(c, HEX);
  Serial.print(" I should be "); Serial.println(0x71, HEX);


  if (c == 0x71) // WHO_AM_I should always be 0x71
  {
    //Serial.println("MPU9250 is online...");

//     Start by performing self test and reporting values
    myIMU.MPU9250SelfTest(myIMU.selfTest);
    Serial.print("x-axis self test: acceleration trim within : ");
    Serial.print(myIMU.selfTest[0],1); Serial.println("% of factory value");
    Serial.print("y-axis self test: acceleration trim within : ");
    Serial.print(myIMU.selfTest[1],1); Serial.println("% of factory value");
    Serial.print("z-axis self test: acceleration trim within : ");
    Serial.print(myIMU.selfTest[2],1); Serial.println("% of factory value");
    Serial.print("x-axis self test: gyration trim within : ");
    Serial.print(myIMU.selfTest[3],1); Serial.println("% of factory value");
    Serial.print("y-axis self test: gyration trim within : ");
    Serial.print(myIMU.selfTest[4],1); Serial.println("% of factory value");
    Serial.print("z-axis self test: gyration trim within : ");
    Serial.print(myIMU.selfTest[5],1); Serial.println("% of factory value");

    
    // Calibrate gyro and accelerometers, load biases in bias registers
    myIMU.calibrateMPU9250(myIMU.gyroBias, myIMU.accelBias);

    myIMU.initMPU9250();
    // Initialize device for active mode read of acclerometer, gyroscope, and
    // temperature
    Serial.println("MPU9250 initialized for active data mode....");
    
    Serial.print("Accel bias x = ");
    Serial.println(myIMU.accelBias[0]);
    Serial.print("Accel bias y = ");
    Serial.println(myIMU.accelBias[1]);
    Serial.print("Accel bias z = ");
    Serial.println(myIMU.accelBias[2]);


    // Read the WHO_AM_I register of the magnetometer, this is a good test of
    // communication
    byte d = myIMU.readByte(AK8963_ADDRESS, WHO_AM_I_AK8963);
    Serial.print("AK8963 ");
    Serial.print("I AM ");
    Serial.print(d, HEX);
    Serial.print(" I should be ");
    Serial.println(0x48, HEX);

    if (SerialDebug)
    {
      Serial.println("Calibration values: ");
      Serial.print("X-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[0], 2);
      Serial.print("Y-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[1], 2);
      Serial.print("Z-Axis factory sensitivity adjustment value ");
      Serial.println(myIMU.factoryMagCalibration[2], 2);
    }


    // Get sensor resolutions, only need to do this once
    myIMU.getAres();
    myIMU.getGres();
    Serial.print("Accelerometer resolution: ");
    Serial.println(myIMU.aRes,8);
    Serial.print("Gyroscope resolution: ");
    Serial.println(myIMU.gRes,8);

    delay(2000); // Add delay to see results before serial spew of data

    // Get average output data over x samples
    int x = 2000;
    int y = 0;
    int divider = 0;
    
    for (int i=0; i<2000; i++){ 

    myIMU.readAccelData(myIMU.accelCount);  // Read the x/y/z adc values
    
        if(i>1000){
          Serial.print((float)myIMU.accelCount[0] * myIMU.aRes, 8);
          Serial.print(", ");
          Serial.print((float)myIMU.accelCount[1] * myIMU.aRes, 8);
          Serial.print(", ");
          Serial.println((float)myIMU.accelCount[2] * myIMU.aRes, 8);
          XAccOffset += (float)myIMU.accelCount[0] * myIMU.aRes; // - myIMU.accelBias[0];
          YAccOffset += (float)myIMU.accelCount[1] * myIMU.aRes; // - myIMU.accelBias[1];
          ZAccOffset += (float)myIMU.accelCount[2] * myIMU.aRes; // - myIMU.accelBias[2];
          divider++;
        }
      } // for loop 

    XAccOffset=XAccOffset/divider;
    YAccOffset=YAccOffset/divider;
    ZAccOffset=ZAccOffset/divider;
    temp_mag=sqrt(sq(XAccOffset)+sq(YAccOffset)+sq(ZAccOffset));
    XAccOffset=XAccOffset/temp_mag + XOffset;
    YAccOffset=YAccOffset/temp_mag + YOffset;
    ZAccOffset=ZAccOffset/temp_mag + ZOffset;
    Serial.print("X Accel Output rest value ");
    Serial.println(XAccOffset,8);
    Serial.print("Y Accel Output rest value ");
    Serial.println(YAccOffset,8);
    Serial.print("Z Accel Output rest value ");
    Serial.println(ZAccOffset,8);
    Serial.print("Rest angle is ");
    Serial.println(atan(ZAccOffset/YAccOffset)*(180/pi));
    delay(2000);
    flashLED(5,2);


  } // if (c == 0x71)
  else
  {
    Serial.print("Could not connect to MPU9250: 0x");
    Serial.println(c, HEX);
    while(1) ; // Loop forever if communication doesn't happen
  }
  
}

void loop()
{
  digitalWriteFast(11,HIGH);
  // If intPin goes high, all data registers have new data
  // On interrupt, check if data ready interrupt
//  if (myIMU.readByte(MPU9250_ADDRESS, INT_STATUS) & 0x01)
//  {
    myIMU.readAccelData(myIMU.accelCount);  // Read the x/y/z adc values

    // Now we'll calculate the accleration value into actual g's
    // This depends on scale being set
//    myIMU.ax = (float)myIMU.accelCount[0] * myIMU.aRes; // - myIMU.accelBias[0];
    myIMU.ay = (float)myIMU.accelCount[1] * myIMU.aRes - YOffset;
    myIMU.az = (float)myIMU.accelCount[2] * myIMU.aRes - ZOffset;

    myIMU.readGyroData(myIMU.gyroCount);  // Read the x/y/z adc values

    // Calculate the gyro value into actual degrees per second
    // This depends on scale being set
    myIMU.gx = (float)myIMU.gyroCount[0] * myIMU.gRes;
//    myIMU.gy = (float)myIMU.gyroCount[1] * myIMU.gRes;
//    myIMU.gz = (float)myIMU.gyroCount[2] * myIMU.gRes;

    //myIMU.readMagData(myIMU.magCount);  // Read the x/y/z adc values

    // Calculate the magnetometer values in milliGauss
    // Include factory calibration per data sheet and user environmental
    // corrections
    // Get actual magnetometer value, this depends on scale being set
//    myIMU.mx = (float)myIMU.magCount[0] * myIMU.mRes
//               * myIMU.factoryMagCalibration[0] - myIMU.magBias[0];
//    myIMU.my = (float)myIMU.magCount[1] * myIMU.mRes
//               * myIMU.factoryMagCalibration[1] - myIMU.magBias[1];
//    myIMU.mz = (float)myIMU.magCount[2] * myIMU.mRes
//               * myIMU.factoryMagCalibration[2] - myIMU.magBias[2];
//  } // if (readByte(MPU9250_ADDRESS, INT_STATUS) & 0x01)
//  else
//  {
//    //delayMicroseconds(1847);
//  }

  // Must be called before updating quaternions!
  //myIMU.updateTime();

  // Sensors x (y)-axis of the accelerometer is aligned with the y (x)-axis of
  // the magnetometer; the magnetometer z-axis (+ down) is opposite to z-axis
  // (+ up) of accelerometer and gyro! We have to make some allowance for this
  // orientationmismatch in feeding the output to the quaternion filter. For the
  // MPU-9250, we have chosen a magnetic rotation that keeps the sensor forward
  // along the x-axis just like in the LSM9DS0 sensor. This rotation can be
  // modified to allow any convenient orientation convention. This is ok by
  // aircraft orientation standards! Pass gyro rate as rad/s
  //MahonyQuaternionUpdate(myIMU.ax, myIMU.ay, myIMU.az, myIMU.gx * DEG_TO_RAD,
  //                       myIMU.gy * DEG_TO_RAD, myIMU.gz * DEG_TO_RAD, myIMU.my,
  //                       myIMU.mx, myIMU.mz, myIMU.deltat);
  
  ComplimentaryFilterUpdate(myIMU.ay, myIMU.az, myIMU.gx * DEG_TO_RAD);

    // Serial print and/or display at 0.5 s rate independent of data rates
    //myIMU.delt_t = millis() - myIMU.count;

      if(SerialDebug)
      {
         
          float pitch  = get_pitch();
         // }
          digitalWriteFast(11,LOW);
          if(Serial){
            Serial.println(int((pitch+90)*100));
          }
          if(Serial1){
            Serial1.println(int(((pitch+90)*100)));
          }

        
//        Serial1.println(int((myIMU.roll-outputOffset+90)*10));

          //Serial.println(get_pitch(),4);
          //Serial.print(",");Serial.println(get_ddi());

//        Serial.print("rate = ");
//        Serial.print((float)myIMU.sumCount / myIMU.sum, 2);
//        Serial.println(" Hz");
      }


//      myIMU.count = millis();
//      myIMU.sumCount = 0;
//      myIMU.sum = 0;
}

void flashLED(int rate, float duration){
  float period = 1.0/float(rate);
  float x=duration/period;
  for(int i=0; i < x; i++){
    digitalWrite(myLed,LOW);
    delay(period/2*1000);
    digitalWrite(myLed,HIGH);
    delay(period/2*1000);
  }
  return;
}

