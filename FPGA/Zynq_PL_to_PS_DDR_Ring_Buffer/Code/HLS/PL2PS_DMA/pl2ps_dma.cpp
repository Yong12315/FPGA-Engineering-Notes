#include "pl2ps_dma.h"

void PL2PS_DMA (fifoStream &fifoIn, u32 *axiOut, u16 DataLength) {
#pragma HLS INTERFACE ap_none port=DataLength
#pragma HLS INTERFACE ap_ctrl_hs port=return
#pragma HLS INTERFACE m_axi depth=65535 latency=0 port=axiOut offset=direct num_read_outstanding=1 max_read_burst_length=2 max_write_burst_length=32
#pragma HLS INTERFACE axis off port=fifoIn

	u32 fifoData;

    for(int i = 0; i < (int)DataLength; i++) {
#pragma HLS PIPELINE II=1

		fifoData = fifoIn.read();
		axiOut[i] = fifoData;
    }

}

