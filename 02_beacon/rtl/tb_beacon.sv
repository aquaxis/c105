`timescale 1ns / 1ns

module tb_beacon;

  reg  RST_N;
  reg  CLK;

  wire LED;

  beacon u_beacon (
      .RST_N(RST_N),
      .CLK  (CLK),

      .LED(LED)
  );

  initial begin
    RST_N = 0;
    CLK   = 0;
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
