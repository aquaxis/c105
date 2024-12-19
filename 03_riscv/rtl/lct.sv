`timescale 1ns / 1ns
//
`default_nettype none

module lct (
    // Slave
    output wire        S_SPB_READY,
    input  wire        S_SPB_VALID,
    input  wire [ 3:0] S_SPB_WSTB,
    input  wire [31:0] S_SPB_ADDR,
    input  wire [31:0] S_SPB_WDATA,
    output wire [31:0] S_SPB_RDATA,
    output wire        S_SPB_EXCPT,

    // Master
    input  wire        M0_SPB_READY,
    output wire        M0_SPB_VALID,
    output wire [ 3:0] M0_SPB_WSTB,
    output wire [31:0] M0_SPB_ADDR,
    output wire [31:0] M0_SPB_WDATA,
    input  wire [31:0] M0_SPB_RDATA,
    input  wire        M0_SPB_EXCPT,

    input  wire        M1_SPB_READY,
    output wire        M1_SPB_VALID,
    output wire [ 3:0] M1_SPB_WSTB,
    output wire [31:0] M1_SPB_ADDR,
    output wire [31:0] M1_SPB_WDATA,
    input  wire [31:0] M1_SPB_RDATA,
    input  wire        M1_SPB_EXCPT
);

  // メモリマップ判定
  wire [1:0] dsel;
  assign dsel[0] = (S_SPB_ADDR[31] == 1'b0);
  assign dsel[1] = (S_SPB_ADDR[31] == 1'b1);

  assign M0_SPB_VALID = dsel[0] & S_SPB_VALID;
  assign M0_SPB_ADDR = S_SPB_ADDR;
  assign M0_SPB_WSTB = S_SPB_WSTB;
  assign M0_SPB_WDATA = S_SPB_WDATA;

  assign M1_SPB_VALID = dsel[1] & S_SPB_VALID;
  assign M1_SPB_ADDR = S_SPB_ADDR[31:0];
  assign M1_SPB_WSTB = S_SPB_WSTB[3:0];
  assign M1_SPB_WDATA = S_SPB_WDATA[31:0];

  assign S_SPB_READY = S_SPB_VALID & ((dsel[0] & M0_SPB_READY) | (dsel[1] & M1_SPB_READY));
  assign S_SPB_RDATA = {32{S_SPB_VALID}} &
      (
        ((dsel[0])?M0_SPB_RDATA:32'd0) |
        ((dsel[1])?M1_SPB_RDATA:32'd0)
      );
  assign S_SPB_EXCPT = S_SPB_VALID & ((dsel[0] & M0_SPB_EXCPT) | (dsel[1] & M1_SPB_EXCPT));

endmodule
`default_nettype wire
