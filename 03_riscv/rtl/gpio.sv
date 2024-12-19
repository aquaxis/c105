`timescale 1ns / 1ns
//
`default_nettype none

module gpio (
    input wire RST_N,
    input wire CLK,

    // Local Inerface
    output wire        BUS_READY,
    input  wire        BUS_VALID,
    input  wire [ 3:0] BUS_WSTB,
    input  wire [31:0] BUS_ADDR,
    input  wire [31:0] BUS_WDATA,
    output wire [31:0] BUS_RDATA,

    input  wire [31:0] GPIO_I,
    output wire [31:0] GPIO_O,
    output wire [31:0] GPIO_OE
);

  aqrv_gpio_ctrl u_aqrv_gpio_ctrl (
      .RST_N(RST_N),
      .CLK  (CLK),

      .LOCAL_CS   (BUS_VALID),
      .LOCAL_RNW  (~(|BUS_WSTB)),
      .LOCAL_ACK  (BUS_READY),
      .LOCAL_ADDR (BUS_ADDR[15:0]),
      .LOCAL_BE   (BUS_WSTB[3:0]),
      .LOCAL_WDATA(BUS_WDATA[31:0]),
      .LOCAL_RDATA(BUS_RDATA[31:0]),

      .GPIO_I (GPIO_I),
      .GPIO_O (GPIO_O),
      .GPIO_OE(GPIO_OE)
  );
endmodule

module aqrv_gpio_ctrl (
    input wire RST_N,
    input wire CLK,

    input  wire        LOCAL_CS,
    input  wire        LOCAL_RNW,
    output wire        LOCAL_ACK,
    input  wire [15:0] LOCAL_ADDR,
    input  wire [ 3:0] LOCAL_BE,
    input  wire [31:0] LOCAL_WDATA,
    output wire [31:0] LOCAL_RDATA,

    input  wire [31:0] GPIO_I,
    output wire [31:0] GPIO_O,
    output wire [31:0] GPIO_OE
);

  localparam A_GPIO_I = 16'h0000;
  localparam A_GPIO_O = 16'h0004;
  localparam A_GPIO_OE = 16'h0008;

  wire wr_ena, rd_ena, wr_ack;
  reg        rd_ack;
  reg [31:0] reg_rdata;
  reg        wr_ack_d;

  assign wr_ena = (LOCAL_CS & ~LOCAL_RNW) ? 1'b1 : 1'b0;
  assign rd_ena = (LOCAL_CS & LOCAL_RNW) ? 1'b1 : 1'b0;
  assign wr_ack = wr_ena;

  reg [31:0] reg_intena0, reg_intena1;
  reg [31:0] reg_gpio_o, reg_gpio_oe;
  reg reg_frame_err0, reg_frame_err1;
  reg [15:0] reg_rate0, reg_rate1;
  reg reg_sel_uart;

  always @(posedge CLK) begin
    if (!RST_N) begin
      reg_gpio_o  <= 32'd0;
      reg_gpio_oe <= 32'd0;
    end else begin
      wr_ack_d <= wr_ena;
      if (wr_ena) begin
        case (LOCAL_ADDR[15:0] & 16'hFFFC)
          A_GPIO_O: begin
            reg_gpio_o <= LOCAL_WDATA;
          end
          A_GPIO_OE: begin
            reg_gpio_oe <= LOCAL_WDATA;
          end
          default: begin
          end
        endcase
      end
    end
  end

  always @(posedge CLK) begin
    if (!RST_N) begin
      rd_ack          <= 1'b0;
      reg_rdata[31:0] <= 32'd0;
    end else begin
      rd_ack <= rd_ena;
      case (LOCAL_ADDR[15:0] & 16'hFFFC)
        A_GPIO_O:  reg_rdata[31:0] <= reg_gpio_o;
        A_GPIO_I:  reg_rdata[31:0] <= GPIO_I;
        A_GPIO_OE: reg_rdata[31:0] <= reg_gpio_oe;
        default:   reg_rdata[31:0] <= 32'd0;
      endcase
    end
  end

  assign LOCAL_ACK         = (wr_ack | rd_ack);
  assign LOCAL_RDATA[31:0] = (rd_ack) ? reg_rdata[31:0] : 32'd0;

  assign GPIO_O            = reg_gpio_o;
  assign GPIO_OE           = reg_gpio_oe;
endmodule

`default_nettype wire
