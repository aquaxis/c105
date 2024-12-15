`timescale 1ns / 1ns

module tb_adder;

  logic A, B, S, C;

  adder u_dut (
      .A(A),
      .B(B),

      .S(S),
      .C(C)
  );

  initial begin
    A = 0;
    B = 0;
    #0;
    $display(" %d + %d = %d (C = %d)", A, B, S, C);
    if ((S != 0) && (C != 0)) $display("[Error] not match");

    #10ns;

    A = 1;
    B = 0;
    #0;
    $display(" %d + %d = %d (C = %d)", A, B, S, C);
    if ((S != 1) && (C != 0)) $display("[Error] not match");

    #10ns;

    A = 0;
    B = 1;
    #0;
    $display(" %d + %d = %d (C = %d)", A, B, S, C);
    if ((S != 1) && (C != 0)) $display("[Error] not match");

    #10ns;

    A = 1;
    B = 1;
    #0;
    $display(" %d + %d = %d (C = %d)", A, B, S, C);
    if ((S != 0) && (C != 1)) $display("[Error] not match");

    #10ns;

    A = 0;
    B = 0;
    #0;
    $display(" %d + %d = %d (C = %d)", A, B, S, C);
    if ((S != 0) && (C != 0)) $display("[Error] not match");

    #10ns;

    $finish();
  end

endmodule
