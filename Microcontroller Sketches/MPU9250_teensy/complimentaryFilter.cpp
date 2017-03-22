// My Defines
#define ACCELEROMETER_SENSITIVITY 8192.0
#define GYROSCOPE_SENSITIVITY 65.536
 
#define M_PI 3.14159265359      
//#define dt 0.0005211
#define dt 0.03

#define alpha 0.9989588851

#include "math.h"
#include "Filters.h"
#include "complimentaryFilter.h"

static float pitch;
//FilterOnePole highPassFilter( HIGHPASS, 0.05);
//FilterOnePole lowPassFilter( LOWPASS, 10);

// END My Defines



void ComplimentaryFilterUpdate(float ay, float az, float gx){
  
  float pitchAcc;            
  
  // Set integration time by time elapsed since last filter update
  // Integrate the gyroscope data -> int(angularSpeed) = angle
    pitch += (gx * dt); // Angle around the X-axis
    
    // Compensate for drift with accelerometer data if !bullshit
    // Sensitivity = -2 to 2 G at 16Bit -> 2G = 32768 && 0.5G = 8192
    //int forceMagnitudeApprox = abs(ay) + abs(az);
//      if (isnan(i_az)) { i_az = 1.0; };
  //  Turning around the X axis results in a vector on the Y-axis
//      pitchAcc = (atan2(ay, az) * 180.0 / M_PI);
      pitchAcc = ay * (180.0 / M_PI);
      if (isnan(pitchAcc)) { pitchAcc = 0; };
      pitch = (pitch * alpha) + (pitchAcc * (1-alpha));

}

float get_pitch() { return pitch; }

