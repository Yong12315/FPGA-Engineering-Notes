#include <iostream>
#include <iomanip>
#include <cstdlib>
#include "pl2ps_dma.h"

static void run_one_case(u16 len) {
    fifoStream fifoIn;

    const int MEM_WORDS = 70000;
    u32 *mem = new u32[MEM_WORDS];

    // 哨兵值初始化
    for (int i = 0; i < MEM_WORDS; i++) {
        mem[i] = 0xDEADBEEF;
    }

    // 写入 0,1,2,... 递增数据
    for (int i = 0; i < (int)len; i++) {
        fifoIn.write((u32)i);
    }

    // 调用 DUT
    PL2PS_DMA(fifoIn, mem, len);

    // 校验
    int err = 0;
    for (int i = 0; i < (int)len; i++) {
        u32 expect = (u32)i;
        if (mem[i] != expect) {
            if (err < 10) {
                std::cout << "Mismatch @ " << i
                          << " expect=" << (unsigned)expect
                          << " got="    << (unsigned)mem[i] << "\n";
            }
            err++;
        }
    }

    // 抽查 len 后未被改写
    for (int i = (int)len; i < (int)len + 64 && i < MEM_WORDS; i++) {
        if (mem[i] != 0xDEADBEEF) {
            std::cout << "Overwrite detected @ " << i
                      << " got=0x" << std::hex << (unsigned)mem[i] << std::dec << "\n";
            err++;
            break;
        }
    }

    delete[] mem;

    if (err) {
        std::cout << "[FAIL] len=" << (int)len << " errors=" << err << "\n";
        std::exit(1);
    } else {
        std::cout << "[PASS] len=" << (int)len << "\n";
    }
}

int main() {
    run_one_case(1);
    run_one_case(16);
    run_one_case(257);
    run_one_case(1024);
    run_one_case(10000);

    std::cout << "All tests passed.\n";
    return 0;
}

