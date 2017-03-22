#ifndef _COMPLIMENTARYFILTER_H_
#define _COMPLIMENTARYFILTER_H_

#include <Arduino.h>

void ComplimentaryFilterUpdate(float ay, float az, float gx);
                       
float get_pitch();

#endif // _COMPLIMENTARYFILTER_H_
