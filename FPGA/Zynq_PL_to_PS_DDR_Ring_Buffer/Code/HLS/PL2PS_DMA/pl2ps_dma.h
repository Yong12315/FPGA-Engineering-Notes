#ifndef _PL2PS_DMA_H_
#define _PL2PS_DMA_H_

#include "ap_int.h"
#include "hls_stream.h"

typedef ap_uint<32> u32;
typedef ap_uint<16> u16;
typedef hls::stream<u32> fifoStream;

void PL2PS_DMA(fifoStream &fifoIn, u32 *axiOut, u16 DataLength);

#endif

