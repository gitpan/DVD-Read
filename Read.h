#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <dvdread/dvd_reader.h>
#include <dvdread/ifo_read.h>

#define FIRST_AC3_AID 128
#define FIRST_DTS_AID 136
#define FIRST_MPG_AID 0
#define FIRST_PCM_AID 160
