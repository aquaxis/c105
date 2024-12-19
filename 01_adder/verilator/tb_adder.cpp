#include <iostream>
#include <verilated.h>
#include "verilated_vcd_c.h"
#include "Vadder.h"

int time_counter = 0;

int main(int argc, char **argv)
{
  Verilated::commandArgs(argc, argv);

  // Trace DUMP ON
  Verilated::traceEverOn(true);
  VerilatedVcdC *tfp = new VerilatedVcdC;

  // Instantiate DUT
  Vadder *dut = new Vadder();

  // Wave dump
  dut->trace(tfp, 100); // Trace 100 levels of hierarchy
  tfp->open("sim.vcd");

  int cycle = 0;
  // Test case
  while (time_counter < 100)
  {
    if ((time_counter % 10) == 0)
    {
      if (cycle >= (4 - 1))
      {
        cycle = 0;
      }
      else
      {
        cycle++;
      }
      dut->A = (cycle & 0x1) ? 1 : 0;
      dut->B = (cycle & 0x2) ? 1 : 0;
    }

    dut->eval();
    tfp->dump(time_counter); // 波形ダンプ用の記述を追加
    time_counter++;

    if (time_counter > 1000)
      break; // 強制的に抜ける
  }

  dut->final();
  tfp->close();
}
