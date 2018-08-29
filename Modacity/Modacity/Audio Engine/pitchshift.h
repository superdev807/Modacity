//
//  pitchshift.h
//  Modacity
//
//  Created by Marc Gelfo on 8/27/18.
//  Copyright © 2018 Modacity, Inc. All rights reserved.
//

// NOTE (2018-08-28) We are *NOT* using this code but it may be extremely useful in the future
// so let's leave it in the project for now, if that's okay. Feel free to clean up its location.

#ifndef pitchshift_h
#define pitchshift_h

#include <stdio.h>

void smbPitchShift( float pitchShift, long numSampsToProcess,
                   long fftFrameSize, long osamp, float sampleRate,
                   float *indata, float *outdata, int stride );
void smbFft( float *fftBuffer, long fftFrameSize, long sign );
double smbAtan2( double x, double y );


#endif /* pitchshift_h */
