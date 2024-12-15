`default_nettype none

module rv32i_reg (
    input wire RST_N,
    input wire CLK,

    input wire [ 4:0] WADDR,
    input wire        WE,
    input wire [31:0] WDATA,

    input  wire [ 4:0] RS1ADDR,
    output reg  [31:0] RS1,
    input  wire [ 4:0] RS2ADDR,
    output reg  [31:0] RS2,

    input  wire        AR_EN,
    input  wire        AR_WR,
    input  wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO
);

  reg [31:0]
      reg01,
      reg02,
      reg03,
      reg04,
      reg05,
      reg06,
      reg07,
      reg08,
      reg09,
      reg0A,
      reg0B,
      reg0C,
      reg0D,
      reg0E,
      reg0F,
      reg10,
      reg11,
      reg12,
      reg13,
      reg14,
      reg15,
      reg16,
      reg17,
      reg18,
      reg19,
      reg1A,
      reg1B,
      reg1C,
      reg1D,
      reg1E,
      reg1F;

  always @(posedge CLK) begin
    if (!RST_N) begin
      //reg00 <= 0;
      reg01 <= 0;
      reg02 <= 0;
      reg03 <= 0;
      reg04 <= 0;
      reg05 <= 0;
      reg06 <= 0;
      reg07 <= 0;
      reg08 <= 0;
      reg09 <= 0;
      reg0A <= 0;
      reg0B <= 0;
      reg0C <= 0;
      reg0D <= 0;
      reg0E <= 0;
      reg0F <= 0;
      reg10 <= 0;
      reg11 <= 0;
      reg12 <= 0;
      reg13 <= 0;
      reg14 <= 0;
      reg15 <= 0;
      reg16 <= 0;
      reg17 <= 0;
      reg18 <= 0;
      reg19 <= 0;
      reg1A <= 0;
      reg1B <= 0;
      reg1C <= 0;
      reg1D <= 0;
      reg1E <= 0;
      reg1F <= 0;
    end else begin
      //if(WE && (WADDR == 5'h00)) reg00 <= WDATA;
      if (AR_EN && AR_WR && (AR_AD == 16'h1001)) reg01 <= AR_DI;
      else if (WE && (WADDR == 5'h01)) reg01 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1002)) reg02 <= AR_DI;
      else if (WE && (WADDR == 5'h02)) reg02 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1003)) reg03 <= AR_DI;
      else if (WE && (WADDR == 5'h03)) reg03 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1004)) reg04 <= AR_DI;
      else if (WE && (WADDR == 5'h04)) reg04 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1005)) reg05 <= AR_DI;
      else if (WE && (WADDR == 5'h05)) reg05 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1006)) reg06 <= AR_DI;
      else if (WE && (WADDR == 5'h06)) reg06 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1007)) reg07 <= AR_DI;
      else if (WE && (WADDR == 5'h07)) reg07 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1008)) reg08 <= AR_DI;
      else if (WE && (WADDR == 5'h08)) reg08 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1009)) reg09 <= AR_DI;
      else if (WE && (WADDR == 5'h09)) reg09 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100A)) reg0A <= AR_DI;
      else if (WE && (WADDR == 5'h0A)) reg0A <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100B)) reg0B <= AR_DI;
      else if (WE && (WADDR == 5'h0B)) reg0B <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100C)) reg0C <= AR_DI;
      else if (WE && (WADDR == 5'h0C)) reg0C <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100D)) reg0D <= AR_DI;
      else if (WE && (WADDR == 5'h0D)) reg0D <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100E)) reg0E <= AR_DI;
      else if (WE && (WADDR == 5'h0E)) reg0E <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h100F)) reg0F <= AR_DI;
      else if (WE && (WADDR == 5'h0F)) reg0F <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1010)) reg10 <= AR_DI;
      else if (WE && (WADDR == 5'h10)) reg10 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1011)) reg11 <= AR_DI;
      else if (WE && (WADDR == 5'h11)) reg11 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1012)) reg12 <= AR_DI;
      else if (WE && (WADDR == 5'h12)) reg12 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1013)) reg13 <= AR_DI;
      else if (WE && (WADDR == 5'h13)) reg13 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1014)) reg14 <= AR_DI;
      else if (WE && (WADDR == 5'h14)) reg14 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1015)) reg15 <= AR_DI;
      else if (WE && (WADDR == 5'h15)) reg15 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1016)) reg16 <= AR_DI;
      else if (WE && (WADDR == 5'h16)) reg16 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1017)) reg17 <= AR_DI;
      else if (WE && (WADDR == 5'h17)) reg17 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1018)) reg18 <= AR_DI;
      else if (WE && (WADDR == 5'h18)) reg18 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h1019)) reg19 <= AR_DI;
      else if (WE && (WADDR == 5'h19)) reg19 <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101A)) reg1A <= AR_DI;
      else if (WE && (WADDR == 5'h1A)) reg1A <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101B)) reg1B <= AR_DI;
      else if (WE && (WADDR == 5'h1B)) reg1B <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101C)) reg1C <= AR_DI;
      else if (WE && (WADDR == 5'h1C)) reg1C <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101D)) reg1D <= AR_DI;
      else if (WE && (WADDR == 5'h1D)) reg1D <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101E)) reg1E <= AR_DI;
      else if (WE && (WADDR == 5'h1E)) reg1E <= WDATA;

      if (AR_EN && AR_WR && (AR_AD == 16'h101F)) reg1F <= AR_DI;
      else if (WE && (WADDR == 5'h1F)) reg1F <= WDATA;
    end
  end

  always @(posedge CLK) begin
    if (!RST_N) begin
      RS1 <= 0;
    end else begin
      case (RS1ADDR)
        //5'h00: RS1 <= reg00;
        5'h01:   RS1 <= reg01;
        5'h02:   RS1 <= reg02;
        5'h03:   RS1 <= reg03;
        5'h04:   RS1 <= reg04;
        5'h05:   RS1 <= reg05;
        5'h06:   RS1 <= reg06;
        5'h07:   RS1 <= reg07;
        5'h08:   RS1 <= reg08;
        5'h09:   RS1 <= reg09;
        5'h0A:   RS1 <= reg0A;
        5'h0B:   RS1 <= reg0B;
        5'h0C:   RS1 <= reg0C;
        5'h0D:   RS1 <= reg0D;
        5'h0E:   RS1 <= reg0E;
        5'h0F:   RS1 <= reg0F;
        5'h10:   RS1 <= reg10;
        5'h11:   RS1 <= reg11;
        5'h12:   RS1 <= reg12;
        5'h13:   RS1 <= reg13;
        5'h14:   RS1 <= reg14;
        5'h15:   RS1 <= reg15;
        5'h16:   RS1 <= reg16;
        5'h17:   RS1 <= reg17;
        5'h18:   RS1 <= reg18;
        5'h19:   RS1 <= reg19;
        5'h1A:   RS1 <= reg1A;
        5'h1B:   RS1 <= reg1B;
        5'h1C:   RS1 <= reg1C;
        5'h1D:   RS1 <= reg1D;
        5'h1E:   RS1 <= reg1E;
        5'h1F:   RS1 <= reg1F;
        default: RS1 <= 32'd0;
      endcase
    end
  end

  always @(posedge CLK) begin
    if (!RST_N) begin
      RS2 <= 0;
    end else begin
      case (RS2ADDR)
        //5'h00: RS2 <= reg00;
        5'h01:   RS2 <= reg01;
        5'h02:   RS2 <= reg02;
        5'h03:   RS2 <= reg03;
        5'h04:   RS2 <= reg04;
        5'h05:   RS2 <= reg05;
        5'h06:   RS2 <= reg06;
        5'h07:   RS2 <= reg07;
        5'h08:   RS2 <= reg08;
        5'h09:   RS2 <= reg09;
        5'h0A:   RS2 <= reg0A;
        5'h0B:   RS2 <= reg0B;
        5'h0C:   RS2 <= reg0C;
        5'h0D:   RS2 <= reg0D;
        5'h0E:   RS2 <= reg0E;
        5'h0F:   RS2 <= reg0F;
        5'h10:   RS2 <= reg10;
        5'h11:   RS2 <= reg11;
        5'h12:   RS2 <= reg12;
        5'h13:   RS2 <= reg13;
        5'h14:   RS2 <= reg14;
        5'h15:   RS2 <= reg15;
        5'h16:   RS2 <= reg16;
        5'h17:   RS2 <= reg17;
        5'h18:   RS2 <= reg18;
        5'h19:   RS2 <= reg19;
        5'h1A:   RS2 <= reg1A;
        5'h1B:   RS2 <= reg1B;
        5'h1C:   RS2 <= reg1C;
        5'h1D:   RS2 <= reg1D;
        5'h1E:   RS2 <= reg1E;
        5'h1F:   RS2 <= reg1F;
        default: RS2 <= 32'd0;
      endcase
    end
  end

  assign AR_DO =  (AR_AD[15:8] == 8'b00010000)?
                    (AR_AD[7:0] == 8'h01)?reg01:
                    (AR_AD[7:0] == 8'h02)?reg02:
                    (AR_AD[7:0] == 8'h03)?reg03:
                    (AR_AD[7:0] == 8'h04)?reg04:
                    (AR_AD[7:0] == 8'h05)?reg05:
                    (AR_AD[7:0] == 8'h06)?reg06:
                    (AR_AD[7:0] == 8'h07)?reg07:
                    (AR_AD[7:0] == 8'h08)?reg08:
                    (AR_AD[7:0] == 8'h09)?reg09:
                    (AR_AD[7:0] == 8'h0A)?reg0A:
                    (AR_AD[7:0] == 8'h0B)?reg0B:
                    (AR_AD[7:0] == 8'h0C)?reg0C:
                    (AR_AD[7:0] == 8'h0D)?reg0D:
                    (AR_AD[7:0] == 8'h0E)?reg0E:
                    (AR_AD[7:0] == 8'h0F)?reg0F:
                    (AR_AD[7:0] == 8'h10)?reg10:
                    (AR_AD[7:0] == 8'h11)?reg11:
                    (AR_AD[7:0] == 8'h12)?reg12:
                    (AR_AD[7:0] == 8'h13)?reg13:
                    (AR_AD[7:0] == 8'h14)?reg14:
                    (AR_AD[7:0] == 8'h15)?reg15:
                    (AR_AD[7:0] == 8'h16)?reg16:
                    (AR_AD[7:0] == 8'h17)?reg17:
                    (AR_AD[7:0] == 8'h18)?reg18:
                    (AR_AD[7:0] == 8'h19)?reg19:
                    (AR_AD[7:0] == 8'h1A)?reg1A:
                    (AR_AD[7:0] == 8'h1B)?reg1B:
                    (AR_AD[7:0] == 8'h1C)?reg1C:
                    (AR_AD[7:0] == 8'h1D)?reg1D:
                    (AR_AD[7:0] == 8'h1E)?reg1E:
                    (AR_AD[7:0] == 8'h1F)?reg1F:
                    32'd0:32'd0;

endmodule

`default_nettype wire
