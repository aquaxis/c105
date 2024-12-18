`timescale 1ns / 1ns
//
`default_nettype none

module adder (
    input wire A,
    input wire B,

    output wire S,
    output wire C
);

  logic [1:0] rslt;

  assign rslt = A + B;

  assign S = rslt[0];
  assign C = rslt[1];

endmodule

`default_nettype wire
