`timescale 1ns / 1ns

module tb_riscv;

  reg RST_N;
  reg CLK;

  reg [1:0] SW;
  wire [1:0] LED;

  riscv u_riscv (
      .RST_N(RST_N),
      .CLK  (CLK),

      .SW (SW),
      .LED(LED)
  );

  initial begin
    RST_N = 0;
    CLK   = 0;
    SW    = 0;
  end

  always begin
    #10ns CLK <= ~CLK;
  end

  initial begin
    #50ns;
    RST_N = 1;

    #10s;

    $finish();
  end

endmodule
