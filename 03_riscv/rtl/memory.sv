`timescale 1ns / 1ns
//
`default_nettype none

`ifndef FILE_IMEM
`define FILE_IMEM ""
`endif
`ifndef FILE_DMEM
`define FILE_DMEM ""
`endif

module memory (
    input wire RST_N,
    input wire CLK,

    // Instruction Memory
    output wire        I_MEM_READY,
    input  wire        I_MEM_VALID,
    input  wire [31:0] I_MEM_ADDR,
    output wire [31:0] I_MEM_RDATA,
    input  wire [ 3:0] I_MEM_WSTB,
    input  wire [31:0] I_MEM_WDATA,

    // Data Memory
    output wire        D_MEM_READY,
    input  wire        D_MEM_VALID,
    input  wire [ 3:0] D_MEM_WSTB,
    input  wire [31:0] D_MEM_ADDR,
    input  wire [31:0] D_MEM_WDATA,
    output wire [31:0] D_MEM_RDATA
);

  reg imem_ready;

  always @(posedge CLK) begin
    if (!RST_N) begin
      imem_ready <= 1'b0;
    end else begin
      imem_ready <= I_MEM_VALID;
    end
  end
  assign I_MEM_READY = imem_ready;

  reg dmem_ready;

  always @(posedge CLK) begin
    if (!RST_N) begin
      dmem_ready <= 1'b0;
    end else begin
      dmem_ready <= D_MEM_VALID;
    end
  end
  assign D_MEM_READY = dmem_ready;

  // IMEM, DMEM
  reg [31:0] imem[0:8191];
  reg [31:0] dmem[0:8191];

  initial begin
    $display("[INFO] imem filename: %s", `FILE_IMEM);
    $display("[INFO] dmem filename: %s", `FILE_DMEM);
    $readmemh(`FILE_IMEM, imem);
    $readmemh(`FILE_DMEM, dmem);
  end

  // imem
  wire        imem_wr;
  wire [ 3:0] imem_st;
  wire [15:0] imem_ad;
  wire [31:0] imem_di;
  reg  [31:0] imem_do;

  assign imem_wr = (I_MEM_WSTB[3] | I_MEM_WSTB[2] | I_MEM_WSTB[1] | I_MEM_WSTB[0]) & I_MEM_VALID;
  assign imem_st = {I_MEM_WSTB[3], I_MEM_WSTB[2], I_MEM_WSTB[1], I_MEM_WSTB[0]};
  assign imem_ad = I_MEM_ADDR[15:0];
  assign imem_di = I_MEM_WDATA;

  always @(posedge CLK) begin
    if (imem_wr & imem_st[0]) imem[imem_ad[14:2]][7:0] <= imem_di[7:0];
    if (imem_wr & imem_st[1]) imem[imem_ad[14:2]][15:8] <= imem_di[15:8];
    if (imem_wr & imem_st[2]) imem[imem_ad[14:2]][23:16] <= imem_di[23:16];
    if (imem_wr & imem_st[3]) imem[imem_ad[14:2]][31:24] <= imem_di[31:24];
    imem_do <= imem[imem_ad[14:2]];
  end

  // dmem
  wire        dmem_wr;
  wire [ 3:0] dmem_st;
  wire [15:0] dmem_ad;
  wire [31:0] dmem_di;
  reg  [31:0] dmem_do;

  assign dmem_wr = (D_MEM_WSTB[3] | D_MEM_WSTB[2] | D_MEM_WSTB[1] | D_MEM_WSTB[0]) & D_MEM_VALID;
  assign dmem_st = {D_MEM_WSTB[3], D_MEM_WSTB[2], D_MEM_WSTB[1], D_MEM_WSTB[0]};
  assign dmem_ad = D_MEM_ADDR[15:0];
  assign dmem_di = D_MEM_WDATA;

  always @(posedge CLK) begin
    if (dmem_wr & dmem_st[0]) dmem[dmem_ad[14:2]][7:0] <= dmem_di[7:0];
    if (dmem_wr & dmem_st[1]) dmem[dmem_ad[14:2]][15:8] <= dmem_di[15:8];
    if (dmem_wr & dmem_st[2]) dmem[dmem_ad[14:2]][23:16] <= dmem_di[23:16];
    if (dmem_wr & dmem_st[3]) dmem[dmem_ad[14:2]][31:24] <= dmem_di[31:24];
    dmem_do <= dmem[dmem_ad[14:2]];
  end

  assign I_MEM_RDATA = imem_ready ? imem_do : 32'd0;
  assign D_MEM_RDATA = dmem_ready ? dmem_do : 32'd0;

endmodule

`default_nettype wire
