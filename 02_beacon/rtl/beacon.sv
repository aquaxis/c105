`timescale 1ns / 1ns
//
`default_nettype none

module beacon (
    input wire RST_N,
    input wire CLK,

    output wire LED
);

  reg [31:0] counter;
  reg beacon;

  always @(posedge CLK) begin
    if (!RST_N) begin
      counter <= 0;
      beacon  <= 0;
    end else begin
      if (counter >= (50000000 - 1)) begin
        counter <= 0;
        beacon  <= ~beacon;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  assign LED = beacon;

endmodule
`default_nettype wire
