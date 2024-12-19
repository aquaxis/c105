`timescale 1ns / 1ns
//
`default_nettype none

module riscv (
    input wire RST_N,
    input wire CLK,

    input  wire [1:0] SW,
    output wire [1:0] LED
);
  wire EXT_INTERRUPT;
  wire SOFT_INTERRUPT;
  wire TIMER_EXPIRED;

  assign EXT_INTERRUPT  = 0;
  assign SOFT_INTERRUPT = 0;
  assign TIMER_EXPIRED  = 0;

  wire        M0_SPB_READY;
  wire        M0_SPB_VALID;
  wire [ 3:0] M0_SPB_WSTB;
  wire [31:0] M0_SPB_ADDR;
  wire [31:0] M0_SPB_WDATA;
  wire [31:0] M0_SPB_RDATA;

  wire        M1_SPB_READY;
  wire        M1_SPB_VALID;
  wire [ 3:0] M1_SPB_WSTB;
  wire [31:0] M1_SPB_ADDR;
  wire [31:0] M1_SPB_WDATA;
  wire [31:0] M1_SPB_RDATA;

  wire        I_MEM_READY;
  wire        I_MEM_VALID;
  wire [31:0] I_MEM_ADDR;
  wire [31:0] I_MEM_RDATA;

  wire        D_MEM_READY;
  wire        D_MEM_VALID;
  wire [ 3:0] D_MEM_WSTB;
  wire [31:0] D_MEM_ADDR;
  wire [31:0] D_MEM_WDATA;
  wire [31:0] D_MEM_RDATA;

  rv32i u_rv32i (
      .RST_N(RST_N),
      .CLK  (CLK),

      .I_MEM_ADDR (I_MEM_ADDR),
      .I_MEM_VALID(I_MEM_VALID),
      .I_MEM_RDATA(I_MEM_RDATA),
      .I_MEM_READY(I_MEM_READY),
      .I_MEM_EXCPT(1'b0),

      .D_MEM_ADDR (D_MEM_ADDR),
      .D_MEM_VALID(D_MEM_VALID),
      .D_MEM_RDATA(D_MEM_RDATA),
      .D_MEM_READY(D_MEM_READY),
      .D_MEM_WDATA(D_MEM_WDATA),
      .D_MEM_WSTB (D_MEM_WSTB),
      .D_MEM_EXCPT(1'b0),

      .EXT_INTERRUPT (EXT_INTERRUPT),
      .SOFT_INTERRUPT(SOFT_INTERRUPT),
      .TIMER_EXPIRED (TIMER_EXPIRED)
  );

  lct u_lct (
      .S_SPB_ADDR (D_MEM_ADDR),
      .S_SPB_EXCPT(),
      .S_SPB_VALID(D_MEM_VALID),
      .S_SPB_RDATA(D_MEM_RDATA),
      .S_SPB_READY(D_MEM_READY),
      .S_SPB_WDATA(D_MEM_WDATA),
      .S_SPB_WSTB (D_MEM_WSTB),

      .M0_SPB_ADDR (M0_SPB_ADDR),
      .M0_SPB_VALID(M0_SPB_VALID),
      .M0_SPB_RDATA(M0_SPB_RDATA),
      .M0_SPB_READY(M0_SPB_READY),
      .M0_SPB_WDATA(M0_SPB_WDATA),
      .M0_SPB_WSTB (M0_SPB_WSTB),
      .M0_SPB_EXCPT(0),

      .M1_SPB_ADDR (M1_SPB_ADDR),
      .M1_SPB_VALID(M1_SPB_VALID),
      .M1_SPB_RDATA(M1_SPB_RDATA),
      .M1_SPB_READY(M1_SPB_READY),
      .M1_SPB_WDATA(M1_SPB_WDATA),
      .M1_SPB_WSTB (M1_SPB_WSTB),
      .M1_SPB_EXCPT(0)
  );

  memory u_memory (
      .RST_N(RST_N),
      .CLK  (CLK),

      .I_MEM_ADDR (I_MEM_ADDR),
      .I_MEM_VALID(I_MEM_VALID),
      .I_MEM_RDATA(I_MEM_RDATA),
      .I_MEM_READY(I_MEM_READY),
      .I_MEM_WDATA('0),
      .I_MEM_WSTB ('0),

      .D_MEM_ADDR (M0_SPB_ADDR),
      .D_MEM_VALID(M0_SPB_VALID),
      .D_MEM_RDATA(M0_SPB_RDATA),
      .D_MEM_READY(M0_SPB_READY),
      .D_MEM_WDATA(M0_SPB_WDATA),
      .D_MEM_WSTB (M0_SPB_WSTB)
  );

  wire [31:0] w_gpio_i, w_gpio_o;

  gpio u_gpio (
      .RST_N(RST_N),
      .CLK  (CLK),

      .BUS_READY(M1_SPB_READY),
      .BUS_VALID(M1_SPB_VALID),
      .BUS_WSTB (M1_SPB_WSTB),
      .BUS_ADDR (M1_SPB_ADDR),
      .BUS_WDATA(M1_SPB_WDATA),
      .BUS_RDATA(M1_SPB_RDATA),

      .GPIO_I (w_gpio_i),
      .GPIO_O (w_gpio_o),
      .GPIO_OE()
  );

  assign w_gpio_i = {30'd0, SW[1:0]};
  assign LED = w_gpio_o[1:0];

endmodule

`default_nettype wire
