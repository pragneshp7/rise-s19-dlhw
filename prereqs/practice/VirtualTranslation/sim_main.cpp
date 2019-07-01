#include <iostream>
#include "verilated.h"
#include "VmkTop.h"

vluint64_t main_time;

double sc_time_stamp();

int main (int argc, char** argv, char** env) {
    std::cout << "Verilator sim starting" << std::endl;
    std::cout << "======================" << std::endl << std::endl;
    Verilated::commandArgs(argc, argv);
    VmkTop* top = new VmkTop;
    main_time = 0;

    top->RST_N = 0;

    while (!Verilated::gotFinish()) {
        if (main_time > 10) {
            top->RST_N = 1;
        }

        if ((main_time % 10) == 1) {
            top->CLK = 1;
        }

        if ((main_time % 10) == 6) {
            top->CLK = 0;
        }

        top->eval();
        main_time++;
    }

    top->final();
    delete top;

    return 0;
}

double sc_time_stamp() {
    return main_time;
}
