`default_nettype none

module rv32i_csr (
    input wire RST_N,
    input wire CLK,

    input  wire [11:0] CSR_ADDR,
    input  wire        CSR_WE,
    input  wire [31:0] CSR_WDATA,
    input  wire [31:0] CSR_WMASK,
    output wire [31:0] CSR_RDATA,

    input wire        EXT_INTERRUPT,
    input wire        SW_INTERRUPT,
    input wire [31:0] SW_INTERRUPT_PC,
    input wire        EXCEPTION,
    input wire [11:0] EXCEPTION_CODE,
    input wire [31:0] EXCEPTION_ADDR,
    input wire [31:0] EXCEPTION_PC,
    input wire        TIMER_EXPIRED,
    input wire        RETIRE,

    output wire [31:0] HANDLER_PC,
    output wire [31:0] EPC,
    output wire        INTERRUPT_PENDING,
    output wire        INTERRUPT,

    output wire ILLEGAL_ACCESS,

    input wire [31:0] DPC,

    input wire RESUMEREQ,
    input wire EBREAK,
    input wire HALTREQ,

    input  wire        AR_EN,
    input  wire        AR_WR,
    input  wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO
);

  /* ------------------------------------------------------------ *
   * Machine mode register                                        *
   * ------------------------------------------------------------ */
  // Machine Information Register
  wire [31:0] mvendorid;
  wire [31:0] marchid;
  wire [31:0] mimpid;
  wire [31:0] mhartid;
  // Machine Trap Setup
  wire [31:0] mstatus;
  wire [31:0] misa;
  reg  [31:0] medeleg;
  reg  [31:0] mideleg;
  wire [31:0] mie;
  reg  [31:0] mtvec;
  // Machine Trap Handlling
  reg  [31:0] mscratch;
  reg  [31:0] mepc;
  reg  [31:0] mcause;
  reg  [31:0] mbadaddr;
  wire [31:0] mip;
  // Machine Protction and Trnslation
  wire [31:0] mbase;
  wire [31:0] mbound;
  wire [31:0] mibase;
  wire [31:0] mibound;
  wire [31:0] mdbase;
  wire [31:0] mdbound;
  // Machine Counter/Timer
  reg  [63:0] mcycle;
  reg  [63:0] minstret;
  wire [63:0] mhpmcounter3;
  wire [63:0] mhpmcounter4;
  wire [63:0] mhpmcounter5;
  wire [63:0] mhpmcounter6;
  wire [63:0] mhpmcounter7;
  wire [63:0] mhpmcounter8;
  wire [63:0] mhpmcounter9;
  wire [63:0] mhpmcounter10;
  wire [63:0] mhpmcounter11;
  wire [63:0] mhpmcounter12;
  wire [63:0] mhpmcounter13;
  wire [63:0] mhpmcounter14;
  wire [63:0] mhpmcounter15;
  wire [63:0] mhpmcounter16;
  wire [63:0] mhpmcounter17;
  wire [63:0] mhpmcounter18;
  wire [63:0] mhpmcounter19;
  wire [63:0] mhpmcounter20;
  wire [63:0] mhpmcounter21;
  wire [63:0] mhpmcounter22;
  wire [63:0] mhpmcounter23;
  wire [63:0] mhpmcounter24;
  wire [63:0] mhpmcounter25;
  wire [63:0] mhpmcounter26;
  wire [63:0] mhpmcounter27;
  wire [63:0] mhpmcounter28;
  wire [63:0] mhpmcounter29;
  wire [63:0] mhpmcounter30;
  wire [63:0] mhpmcounter31;
  // Machine Counter Setup
  wire [31:0] mucounteren;
  wire [31:0] mscounteren;
  wire [31:0] mhcounteren;
  wire [31:0] mhpmevent3;
  wire [31:0] mhpmevent4;
  wire [31:0] mhpmevent5;
  wire [31:0] mhpmevent6;
  wire [31:0] mhpmevent7;
  wire [31:0] mhpmevent8;
  wire [31:0] mhpmevent9;
  wire [31:0] mhpmevent10;
  wire [31:0] mhpmevent11;
  wire [31:0] mhpmevent12;
  wire [31:0] mhpmevent13;
  wire [31:0] mhpmevent14;
  wire [31:0] mhpmevent15;
  wire [31:0] mhpmevent16;
  wire [31:0] mhpmevent17;
  wire [31:0] mhpmevent18;
  wire [31:0] mhpmevent19;
  wire [31:0] mhpmevent20;
  wire [31:0] mhpmevent21;
  wire [31:0] mhpmevent22;
  wire [31:0] mhpmevent23;
  wire [31:0] mhpmevent24;
  wire [31:0] mhpmevent25;
  wire [31:0] mhpmevent26;
  wire [31:0] mhpmevent27;
  wire [31:0] mhpmevent28;
  wire [31:0] mhpmevent29;
  wire [31:0] mhpmevent30;
  wire [31:0] mhpmevent31;
  // Debug/Trace Register
  wire [31:0] tselect;
  wire [31:0] tdata1;
  wire [31:0] tdata2;
  wire [31:0] tdata3;
  // Debug Mode Register
  reg  [31:0] dcsr;
  wire [31:0] dpc;
  wire [31:0] dscratch;

  // mvendorid(F11h), marchid(F12h), mimpid(F13h), mhartid(F14h)
  assign mvendorid = 32'd0;
  assign marchid   = 32'd0;
  assign mimpid    = 32'd0;
  assign mhartid   = 32'd0;

  // mstatus(300h)
  reg [1:0] ms_mpp;
  reg       ms_mpie;
  reg       ms_mie;
  always @(posedge CLK) begin
    if (!RST_N) begin
      ms_mpp  <= 0;
      ms_mpie <= 0;
      ms_mie  <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'h300)) begin
        ms_mpp[1:0] <= CSR_WDATA[12:11];  // MPP[1:0]
        ms_mpie     <= CSR_WDATA[7];  // MPIE
        ms_mie      <= CSR_WDATA[3];  // MIE
      end
    end
  end
  assign mstatus = {19'd0, ms_mpp[1:0], 3'd0, ms_mpie, 3'd0, ms_mie, 3'd0};

  // misa(301h)
  assign misa = {
    2'b01,  // base 32bit
    4'b0000,  // WIRI
    26'b00_0000_0000_0001_0001_0000_0100
  };  // E,M

  // medeleg(302h), mideleg(303h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mideleg <= 0;
      medeleg <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'h302)) begin
        medeleg <= CSR_WDATA;
      end
      if (CSR_WE & (CSR_ADDR == 12'h303)) begin
        mideleg <= CSR_WDATA;
      end
    end
  end

  // mie(304h)
  reg meie, mtie, msie;
  always @(posedge CLK) begin
    if (!RST_N) begin
      meie <= 0;
      mtie <= 0;
      msie <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'h304)) begin
        meie <= CSR_WDATA[11];  // MEIE(M-mode Exception Interrupt Enablee)
        mtie <= CSR_WDATA[7];  // MTIE(M-mode Timer Interrupt Enable)
        msie <= CSR_WDATA[3];  // MSIE(M-mode Software Interrupt Enable)
      end
    end
  end
  assign mie = {20'd0, meie, 3'd0, mtie, 3'd0, msie, 3'd0};

  // mtvec(305h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mtvec <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'h305)) begin
        mtvec <= CSR_WDATA;
      end
    end
  end
  assign HANDLER_PC = mtvec;

  // mscratch(340h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mscratch <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'h340)) begin
        mscratch <= CSR_WDATA;
      end
    end
  end

  // mepc(341h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mepc <= 0;
    end else begin
      if (SW_INTERRUPT) begin
        mepc <= (SW_INTERRUPT_PC & {{30{1'b1}}, 2'b0});
      end else if (EXCEPTION) begin
        mepc <= (EXCEPTION_PC & {{30{1'b1}}, 2'b0});
      end else if (CSR_WE & (CSR_ADDR == 12'h341)) begin
        mepc <= (CSR_WDATA & {{30{1'b1}}, 2'b0});
      end
    end
  end
  assign EPC = mepc;

  // mcause(342h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mcause <= 0;
    end else begin
      if (INTERRUPT) begin
        mcause[31]   <= 1'b1;
        mcause[11]   <= EXT_INTERRUPT;
        mcause[10:8] <= 3'd0;
        mcause[7]    <= TIMER_EXPIRED;
        mcause[6:4]  <= 3'd0;
        mcause[3]    <= 1'b0;
        mcause[2:0]  <= 3'd0;
      end else if (EXCEPTION) begin
        mcause[31]   <= 1'b0;
        mcause[11:0] <= EXCEPTION_CODE;
      end else if (CSR_WE & (CSR_ADDR == 12'h342)) begin
        mcause[31]   <= CSR_WDATA[31];
        mcause[11:0] <= CSR_WDATA[11:0];
      end
    end
  end

  // mbadaddr(343h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mbadaddr <= 0;
    end else begin
      if (EXCEPTION) begin
        mbadaddr <= (|EXCEPTION_CODE[3:0]) ? EXCEPTION_PC : EXCEPTION_ADDR;
      end else if (CSR_WE & (CSR_ADDR == 12'h343)) begin
        mbadaddr <= CSR_WDATA;
      end
    end
  end

  // mip(344h)
  reg meip, mtip, msip;
  reg  intd;
  wire w_int;
  assign w_int = mstatus[3] & (|(mie & mip));
  always @(posedge CLK) begin
    if (!RST_N) begin
      meip <= 0;
      mtip <= 0;
      msip <= 0;
      intd <= 0;
    end else begin
      // MEIP
      if (EXT_INTERRUPT) begin
        meip <= 1'b1;
      end else if (CSR_WE & (CSR_ADDR == 12'h344)) begin
        meip <= CSR_WDATA[11];
      end
      // MTIP
      if (TIMER_EXPIRED) begin
        mtip <= 1'b1;
      end else if (CSR_WE & (CSR_ADDR == 12'h344)) begin
        mtip <= CSR_WDATA[7];
      end
      // MSIP
      if (SW_INTERRUPT) begin
        msip <= 1'b1;
      end else if (CSR_WE & (CSR_ADDR == 12'h344)) begin
        msip <= CSR_WDATA[3];
      end
      intd <= w_int;
    end
  end
  assign mip = {20'd0, meip, 3'd0, mtip, 3'd0, msip, 3'd0};
  //   assign INTERRUPT = w_int & ~intd;
  assign INTERRUPT = w_int;
  assign INTERRUPT_PENDING = |mip;

  // mbase(380h), mbound(381h), mibase(382h), mibound(383h), mdbase(384h), mdbound(385h)
  assign mbase = 32'd0;
  assign mbound = 32'd0;
  assign mibase = 32'd0;
  assign mibound = 32'd0;
  assign mdbase = 32'd0;
  assign mdbound = 32'd0;

  // mcycle(B00h,B20h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      mcycle <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'hB00)) begin
        mcycle[31:0] <= CSR_WDATA;
      end else if (CSR_WE & (CSR_ADDR == 12'hB20)) begin
        mcycle[63:32] <= CSR_WDATA;
      end else begin
        mcycle <= mcycle + 64'd1;
      end
    end
  end

  // minstret(B02h, B22h)
  always @(posedge CLK) begin
    if (!RST_N) begin
      minstret <= 0;
    end else begin
      if (CSR_WE & (CSR_ADDR == 12'hB02)) begin
        minstret[31:0] <= CSR_WDATA;
      end else if (CSR_WE & (CSR_ADDR == 12'hB20)) begin
        minstret[63:32] <= CSR_WDATA;
      end else begin
        if (RETIRE) begin
          minstret <= minstret + 64'd1;
        end
      end
    end
  end

  // mucounteren(320h), mscounteren(321h), mhcounteren(322h)
  assign mucounteren = 32'd0;
  assign mscounteren = 32'd0;
  assign mhcounteren = 32'd0;

  // mhpmcounter3-31(B803h-B1Fh), mhpmevent3-31(323h-33Fh)
  assign mhpmcounter3 = 64'd0;
  assign mhpmcounter4 = 64'd0;
  assign mhpmcounter5 = 64'd0;
  assign mhpmcounter6 = 64'd0;
  assign mhpmcounter7 = 64'd0;
  assign mhpmcounter8 = 64'd0;
  assign mhpmcounter9 = 64'd0;
  assign mhpmcounter10 = 64'd0;
  assign mhpmcounter11 = 64'd0;
  assign mhpmcounter12 = 64'd0;
  assign mhpmcounter13 = 64'd0;
  assign mhpmcounter14 = 64'd0;
  assign mhpmcounter15 = 64'd0;
  assign mhpmcounter16 = 64'd0;
  assign mhpmcounter17 = 64'd0;
  assign mhpmcounter18 = 64'd0;
  assign mhpmcounter19 = 64'd0;
  assign mhpmcounter20 = 64'd0;
  assign mhpmcounter21 = 64'd0;
  assign mhpmcounter22 = 64'd0;
  assign mhpmcounter23 = 64'd0;
  assign mhpmcounter24 = 64'd0;
  assign mhpmcounter25 = 64'd0;
  assign mhpmcounter26 = 64'd0;
  assign mhpmcounter27 = 64'd0;
  assign mhpmcounter28 = 64'd0;
  assign mhpmcounter29 = 64'd0;
  assign mhpmcounter30 = 64'd0;
  assign mhpmcounter31 = 64'd0;
  assign mhpmevent3 = 32'd0;
  assign mhpmevent4 = 32'd0;
  assign mhpmevent5 = 32'd0;
  assign mhpmevent6 = 32'd0;
  assign mhpmevent7 = 32'd0;
  assign mhpmevent8 = 32'd0;
  assign mhpmevent9 = 32'd0;
  assign mhpmevent10 = 32'd0;
  assign mhpmevent11 = 32'd0;
  assign mhpmevent12 = 32'd0;
  assign mhpmevent13 = 32'd0;
  assign mhpmevent14 = 32'd0;
  assign mhpmevent15 = 32'd0;
  assign mhpmevent16 = 32'd0;
  assign mhpmevent17 = 32'd0;
  assign mhpmevent18 = 32'd0;
  assign mhpmevent19 = 32'd0;
  assign mhpmevent20 = 32'd0;
  assign mhpmevent21 = 32'd0;
  assign mhpmevent22 = 32'd0;
  assign mhpmevent23 = 32'd0;
  assign mhpmevent24 = 32'd0;
  assign mhpmevent25 = 32'd0;
  assign mhpmevent26 = 32'd0;
  assign mhpmevent27 = 32'd0;
  assign mhpmevent28 = 32'd0;
  assign mhpmevent29 = 32'd0;
  assign mhpmevent30 = 32'd0;
  assign mhpmevent31 = 32'd0;

  // Debug/Trace Register
  assign tselect = 32'd0;
  assign tdata1 = 32'd0;
  assign tdata2 = 32'd0;
  assign tdata3 = 32'd0;

  // Debug Mode Register
  always @(posedge CLK) begin
    if (!RST_N) begin
      dcsr <= 0;
    end else begin
      if (AR_EN & AR_WR & (AR_AD == 16'h07B0)) begin
        dcsr[15] <= AR_DI[15];
        dcsr[13] <= AR_DI[13];
        dcsr[12] <= AR_DI[12];
      end

      if (RESUMEREQ) begin
        dcsr[8:6] <= 3'b0;
      end else if (EBREAK) begin
        dcsr[8:6] <= 3'b1;
        //         end else if() begin
        //           dcsr[8:6] <= 3'd2;
      end else if (HALTREQ) begin
        dcsr[8:6] <= 3'd3;
        //         end else if() begin
        //           dcsr[8:6] <= 3'd4;
        //         end else if() begin
        //           dcsr[8:6] <= 3'd5;
      end
    end
  end
  //   assign dcsr     = 32'd0;
  assign dpc = DPC;
  assign dscratch = 32'd0;

  assign CSR_RDATA = 
                (CSR_ADDR == 12'hF11)?mvendorid:
                (CSR_ADDR == 12'hF12)?marchid:
                (CSR_ADDR == 12'hF13)?mimpid:
                (CSR_ADDR == 12'hF14)?mhartid:
      // Machine Trap Setup
      (CSR_ADDR == 12'h300)?mstatus:
                (CSR_ADDR == 12'h301)?misa:
                (CSR_ADDR == 12'h302)?medeleg:
                (CSR_ADDR == 12'h303)?mideleg:
                (CSR_ADDR == 12'h304)?mie:
                (CSR_ADDR == 12'h305)?mtvec:
      // Machine Trap Handling
      (CSR_ADDR == 12'h340)?mscratch:
                (CSR_ADDR == 12'h341)?mepc:
                (CSR_ADDR == 12'h342)?mcause:
                (CSR_ADDR == 12'h343)?mbadaddr:
                (CSR_ADDR == 12'h344)?mip:
      // Machine Protection and Translation
      (CSR_ADDR == 12'h380)?mbase:
                (CSR_ADDR == 12'h381)?mbound:
                (CSR_ADDR == 12'h382)?mibase:
                (CSR_ADDR == 12'h383)?mibound:
                (CSR_ADDR == 12'h384)?mdbase:
                (CSR_ADDR == 12'h385)?mdbound:
      // Machine Counter/Timer
      (CSR_ADDR == 12'hB00)?mcycle[31:0]:
                (CSR_ADDR == 12'hB02)?minstret[31:0]:
                (CSR_ADDR == 12'hB03)?mhpmcounter3[31:0]:
                (CSR_ADDR == 12'hB04)?mhpmcounter4[31:0]:
                (CSR_ADDR == 12'hB05)?mhpmcounter5[31:0]:
                (CSR_ADDR == 12'hB06)?mhpmcounter6[31:0]:
                (CSR_ADDR == 12'hB07)?mhpmcounter7[31:0]:
                (CSR_ADDR == 12'hB08)?mhpmcounter8[31:0]:
                (CSR_ADDR == 12'hB09)?mhpmcounter9[31:0]:
                (CSR_ADDR == 12'hB0A)?mhpmcounter10[31:0]:
                (CSR_ADDR == 12'hB0B)?mhpmcounter11[31:0]:
                (CSR_ADDR == 12'hB0C)?mhpmcounter12[31:0]:
                (CSR_ADDR == 12'hB0D)?mhpmcounter13[31:0]:
                (CSR_ADDR == 12'hB0E)?mhpmcounter14[31:0]:
                (CSR_ADDR == 12'hB0F)?mhpmcounter15[31:0]:
                (CSR_ADDR == 12'hB10)?mhpmcounter16[31:0]:
                (CSR_ADDR == 12'hB11)?mhpmcounter17[31:0]:
                (CSR_ADDR == 12'hB12)?mhpmcounter18[31:0]:
                (CSR_ADDR == 12'hB13)?mhpmcounter19[31:0]:
                (CSR_ADDR == 12'hB14)?mhpmcounter20[31:0]:
                (CSR_ADDR == 12'hB15)?mhpmcounter21[31:0]:
                (CSR_ADDR == 12'hB16)?mhpmcounter22[31:0]:
                (CSR_ADDR == 12'hB17)?mhpmcounter23[31:0]:
                (CSR_ADDR == 12'hB18)?mhpmcounter24[31:0]:
                (CSR_ADDR == 12'hB19)?mhpmcounter25[31:0]:
                (CSR_ADDR == 12'hB1A)?mhpmcounter26[31:0]:
                (CSR_ADDR == 12'hB1B)?mhpmcounter27[31:0]:
                (CSR_ADDR == 12'hB1C)?mhpmcounter28[31:0]:
                (CSR_ADDR == 12'hB1D)?mhpmcounter29[31:0]:
                (CSR_ADDR == 12'hB1E)?mhpmcounter30[31:0]:
                (CSR_ADDR == 12'hB1F)?mhpmcounter31[31:0]:
                (CSR_ADDR == 12'hB20)?mcycle[63:32]:
                (CSR_ADDR == 12'hB22)?minstret[63:32]:
                (CSR_ADDR == 12'hB23)?mhpmcounter3[63:32]:
                (CSR_ADDR == 12'hB24)?mhpmcounter4[63:32]:
                (CSR_ADDR == 12'hB25)?mhpmcounter5[63:32]:
                (CSR_ADDR == 12'hB26)?mhpmcounter6[63:32]:
                (CSR_ADDR == 12'hB27)?mhpmcounter7[63:32]:
                (CSR_ADDR == 12'hB28)?mhpmcounter8[63:32]:
                (CSR_ADDR == 12'hB29)?mhpmcounter9[63:32]:
                (CSR_ADDR == 12'hB2A)?mhpmcounter10[63:32]:
                (CSR_ADDR == 12'hB2B)?mhpmcounter11[63:32]:
                (CSR_ADDR == 12'hB2C)?mhpmcounter12[63:32]:
                (CSR_ADDR == 12'hB2D)?mhpmcounter13[63:32]:
                (CSR_ADDR == 12'hB2E)?mhpmcounter14[63:32]:
                (CSR_ADDR == 12'hB2F)?mhpmcounter15[63:32]:
                (CSR_ADDR == 12'hB30)?mhpmcounter16[63:32]:
                (CSR_ADDR == 12'hB31)?mhpmcounter17[63:32]:
                (CSR_ADDR == 12'hB32)?mhpmcounter18[63:32]:
                (CSR_ADDR == 12'hB33)?mhpmcounter19[63:32]:
                (CSR_ADDR == 12'hB34)?mhpmcounter20[63:32]:
                (CSR_ADDR == 12'hB35)?mhpmcounter21[63:32]:
                (CSR_ADDR == 12'hB36)?mhpmcounter22[63:32]:
                (CSR_ADDR == 12'hB37)?mhpmcounter23[63:32]:
                (CSR_ADDR == 12'hB38)?mhpmcounter24[63:32]:
                (CSR_ADDR == 12'hB39)?mhpmcounter25[63:32]:
                (CSR_ADDR == 12'hB3A)?mhpmcounter26[63:32]:
                (CSR_ADDR == 12'hB3B)?mhpmcounter27[63:32]:
                (CSR_ADDR == 12'hB3C)?mhpmcounter28[63:32]:
                (CSR_ADDR == 12'hB3D)?mhpmcounter29[63:32]:
                (CSR_ADDR == 12'hB3E)?mhpmcounter30[63:32]:
                (CSR_ADDR == 12'hB3F)?mhpmcounter31[63:32]:
      // Machine Counter Setup
      (CSR_ADDR == 12'h320)?mucounteren:
                (CSR_ADDR == 12'h321)?mscounteren:
                (CSR_ADDR == 12'h322)?mhcounteren:
                (CSR_ADDR == 12'h323)?mhpmevent3:
                (CSR_ADDR == 12'h324)?mhpmevent4:
                (CSR_ADDR == 12'h325)?mhpmevent5:
                (CSR_ADDR == 12'h326)?mhpmevent6:
                (CSR_ADDR == 12'h327)?mhpmevent7:
                (CSR_ADDR == 12'h328)?mhpmevent8:
                (CSR_ADDR == 12'h329)?mhpmevent9:
                (CSR_ADDR == 12'h32A)?mhpmevent10:
                (CSR_ADDR == 12'h32B)?mhpmevent11:
                (CSR_ADDR == 12'h32C)?mhpmevent12:
                (CSR_ADDR == 12'h32D)?mhpmevent13:
                (CSR_ADDR == 12'h32E)?mhpmevent14:
                (CSR_ADDR == 12'h32F)?mhpmevent15:
                (CSR_ADDR == 12'h330)?mhpmevent16:
                (CSR_ADDR == 12'h331)?mhpmevent17:
                (CSR_ADDR == 12'h332)?mhpmevent18:
                (CSR_ADDR == 12'h333)?mhpmevent19:
                (CSR_ADDR == 12'h334)?mhpmevent20:
                (CSR_ADDR == 12'h335)?mhpmevent21:
                (CSR_ADDR == 12'h336)?mhpmevent22:
                (CSR_ADDR == 12'h337)?mhpmevent23:
                (CSR_ADDR == 12'h338)?mhpmevent24:
                (CSR_ADDR == 12'h339)?mhpmevent25:
                (CSR_ADDR == 12'h33A)?mhpmevent26:
                (CSR_ADDR == 12'h33B)?mhpmevent27:
                (CSR_ADDR == 12'h33C)?mhpmevent28:
                (CSR_ADDR == 12'h33D)?mhpmevent29:
                (CSR_ADDR == 12'h33E)?mhpmevent30:
                (CSR_ADDR == 12'h33F)?mhpmevent31:
      // Debug/Trace Register
      (CSR_ADDR == 12'h7A0)?tselect:
                (CSR_ADDR == 12'h7A1)?tdata1:
                (CSR_ADDR == 12'h7A2)?tdata2:
                (CSR_ADDR == 12'h7A3)?tdata3:
      // Debug Mode Register
      (CSR_ADDR == 12'h7B0)?dcsr:
                (CSR_ADDR == 12'h7B1)?dpc:
                (CSR_ADDR == 12'h7B2)?dscratch:
                32'd0;

  assign AR_DO = (AR_AD[15:12] == 4'b0000) ?
      // Machine Information
      (AR_AD[11:0] == 12'hF11)?mvendorid:
            (AR_AD[11:0] == 12'hF12)?marchid:
            (AR_AD[11:0] == 12'hF13)?mimpid:
            (AR_AD[11:0] == 12'hF14)?mhartid:
      // Machine Trap Setup
      (AR_AD[11:0] == 12'h300)?mstatus:
            (AR_AD[11:0] == 12'h301)?misa:
            (AR_AD[11:0] == 12'h302)?medeleg:
            (AR_AD[11:0] == 12'h303)?mideleg:
            (AR_AD[11:0] == 12'h304)?mie:
            (AR_AD[11:0] == 12'h305)?mtvec:
      // Machine Trap Handling
      (AR_AD[11:0] == 12'h340)?mscratch:
            (AR_AD[11:0] == 12'h341)?mepc:
            (AR_AD[11:0] == 12'h342)?mcause:
            (AR_AD[11:0] == 12'h343)?mbadaddr:
            (AR_AD[11:0] == 12'h344)?mip:
      // Machine Protection and Translation
      (AR_AD[11:0] == 12'h380)?mbase:
            (AR_AD[11:0] == 12'h381)?mbound:
            (AR_AD[11:0] == 12'h382)?mibase:
            (AR_AD[11:0] == 12'h383)?mibound:
            (AR_AD[11:0] == 12'h384)?mdbase:
            (AR_AD[11:0] == 12'h385)?mdbound:
      // Machine Counter/Timer
      (AR_AD[11:0] == 12'hB00)?mcycle[31:0]:
            (AR_AD[11:0] == 12'hB02)?minstret[31:0]:
            (AR_AD[11:0] == 12'hB03)?mhpmcounter3[31:0]:
            (AR_AD[11:0] == 12'hB04)?mhpmcounter4[31:0]:
            (AR_AD[11:0] == 12'hB05)?mhpmcounter5[31:0]:
            (AR_AD[11:0] == 12'hB06)?mhpmcounter6[31:0]:
            (AR_AD[11:0] == 12'hB07)?mhpmcounter7[31:0]:
            (AR_AD[11:0] == 12'hB08)?mhpmcounter8[31:0]:
            (AR_AD[11:0] == 12'hB09)?mhpmcounter9[31:0]:
            (AR_AD[11:0] == 12'hB0A)?mhpmcounter10[31:0]:
            (AR_AD[11:0] == 12'hB0B)?mhpmcounter11[31:0]:
            (AR_AD[11:0] == 12'hB0C)?mhpmcounter12[31:0]:
            (AR_AD[11:0] == 12'hB0D)?mhpmcounter13[31:0]:
            (AR_AD[11:0] == 12'hB0E)?mhpmcounter14[31:0]:
            (AR_AD[11:0] == 12'hB0F)?mhpmcounter15[31:0]:
            (AR_AD[11:0] == 12'hB10)?mhpmcounter16[31:0]:
            (AR_AD[11:0] == 12'hB11)?mhpmcounter17[31:0]:
            (AR_AD[11:0] == 12'hB12)?mhpmcounter18[31:0]:
            (AR_AD[11:0] == 12'hB13)?mhpmcounter19[31:0]:
            (AR_AD[11:0] == 12'hB14)?mhpmcounter20[31:0]:
            (AR_AD[11:0] == 12'hB15)?mhpmcounter21[31:0]:
            (AR_AD[11:0] == 12'hB16)?mhpmcounter22[31:0]:
            (AR_AD[11:0] == 12'hB17)?mhpmcounter23[31:0]:
            (AR_AD[11:0] == 12'hB18)?mhpmcounter24[31:0]:
            (AR_AD[11:0] == 12'hB19)?mhpmcounter25[31:0]:
            (AR_AD[11:0] == 12'hB1A)?mhpmcounter26[31:0]:
            (AR_AD[11:0] == 12'hB1B)?mhpmcounter27[31:0]:
            (AR_AD[11:0] == 12'hB1C)?mhpmcounter28[31:0]:
            (AR_AD[11:0] == 12'hB1D)?mhpmcounter29[31:0]:
            (AR_AD[11:0] == 12'hB1E)?mhpmcounter30[31:0]:
            (AR_AD[11:0] == 12'hB1F)?mhpmcounter31[31:0]:
            (AR_AD[11:0] == 12'hB20)?mcycle[63:32]:
            (AR_AD[11:0] == 12'hB22)?minstret[63:32]:
            (AR_AD[11:0] == 12'hB23)?mhpmcounter3[63:32]:
            (AR_AD[11:0] == 12'hB24)?mhpmcounter4[63:32]:
            (AR_AD[11:0] == 12'hB25)?mhpmcounter5[63:32]:
            (AR_AD[11:0] == 12'hB26)?mhpmcounter6[63:32]:
            (AR_AD[11:0] == 12'hB27)?mhpmcounter7[63:32]:
            (AR_AD[11:0] == 12'hB28)?mhpmcounter8[63:32]:
            (AR_AD[11:0] == 12'hB29)?mhpmcounter9[63:32]:
            (AR_AD[11:0] == 12'hB2A)?mhpmcounter10[63:32]:
            (AR_AD[11:0] == 12'hB2B)?mhpmcounter11[63:32]:
            (AR_AD[11:0] == 12'hB2C)?mhpmcounter12[63:32]:
            (AR_AD[11:0] == 12'hB2D)?mhpmcounter13[63:32]:
            (AR_AD[11:0] == 12'hB2E)?mhpmcounter14[63:32]:
            (AR_AD[11:0] == 12'hB2F)?mhpmcounter15[63:32]:
            (AR_AD[11:0] == 12'hB30)?mhpmcounter16[63:32]:
            (AR_AD[11:0] == 12'hB31)?mhpmcounter17[63:32]:
            (AR_AD[11:0] == 12'hB32)?mhpmcounter18[63:32]:
            (AR_AD[11:0] == 12'hB33)?mhpmcounter19[63:32]:
            (AR_AD[11:0] == 12'hB34)?mhpmcounter20[63:32]:
            (AR_AD[11:0] == 12'hB35)?mhpmcounter21[63:32]:
            (AR_AD[11:0] == 12'hB36)?mhpmcounter22[63:32]:
            (AR_AD[11:0] == 12'hB37)?mhpmcounter23[63:32]:
            (AR_AD[11:0] == 12'hB38)?mhpmcounter24[63:32]:
            (AR_AD[11:0] == 12'hB39)?mhpmcounter25[63:32]:
            (AR_AD[11:0] == 12'hB3A)?mhpmcounter26[63:32]:
            (AR_AD[11:0] == 12'hB3B)?mhpmcounter27[63:32]:
            (AR_AD[11:0] == 12'hB3C)?mhpmcounter28[63:32]:
            (AR_AD[11:0] == 12'hB3D)?mhpmcounter29[63:32]:
            (AR_AD[11:0] == 12'hB3E)?mhpmcounter30[63:32]:
            (AR_AD[11:0] == 12'hB3F)?mhpmcounter31[63:32]:
      // Machine Counter Setup
      (AR_AD[11:0] == 12'h320)?mucounteren:
            (AR_AD[11:0] == 12'h321)?mscounteren:
            (AR_AD[11:0] == 12'h322)?mhcounteren:
            (AR_AD[11:0] == 12'h323)?mhpmevent3:
            (AR_AD[11:0] == 12'h324)?mhpmevent4:
            (AR_AD[11:0] == 12'h325)?mhpmevent5:
            (AR_AD[11:0] == 12'h326)?mhpmevent6:
            (AR_AD[11:0] == 12'h327)?mhpmevent7:
            (AR_AD[11:0] == 12'h328)?mhpmevent8:
            (AR_AD[11:0] == 12'h329)?mhpmevent9:
            (AR_AD[11:0] == 12'h32A)?mhpmevent10:
            (AR_AD[11:0] == 12'h32B)?mhpmevent11:
            (AR_AD[11:0] == 12'h32C)?mhpmevent12:
            (AR_AD[11:0] == 12'h32D)?mhpmevent13:
            (AR_AD[11:0] == 12'h32E)?mhpmevent14:
            (AR_AD[11:0] == 12'h32F)?mhpmevent15:
            (AR_AD[11:0] == 12'h330)?mhpmevent16:
            (AR_AD[11:0] == 12'h331)?mhpmevent17:
            (AR_AD[11:0] == 12'h332)?mhpmevent18:
            (AR_AD[11:0] == 12'h333)?mhpmevent19:
            (AR_AD[11:0] == 12'h334)?mhpmevent20:
            (AR_AD[11:0] == 12'h335)?mhpmevent21:
            (AR_AD[11:0] == 12'h336)?mhpmevent22:
            (AR_AD[11:0] == 12'h337)?mhpmevent23:
            (AR_AD[11:0] == 12'h338)?mhpmevent24:
            (AR_AD[11:0] == 12'h339)?mhpmevent25:
            (AR_AD[11:0] == 12'h33A)?mhpmevent26:
            (AR_AD[11:0] == 12'h33B)?mhpmevent27:
            (AR_AD[11:0] == 12'h33C)?mhpmevent28:
            (AR_AD[11:0] == 12'h33D)?mhpmevent29:
            (AR_AD[11:0] == 12'h33E)?mhpmevent30:
            (AR_AD[11:0] == 12'h33F)?mhpmevent31:
      // Debug/Trace Register
      (AR_AD[11:0] == 12'h7A0)?tselect:
            (AR_AD[11:0] == 12'h7A1)?tdata1:
            (AR_AD[11:0] == 12'h7A2)?tdata2:
            (AR_AD[11:0] == 12'h7A3)?tdata3:
      // D7bug Mode Register
      (AR_AD[11:0] == 12'h7B0)?dcsr:
            (AR_AD[11:0] == 12'h7B1)?dpc:
            (AR_AD[11:0] == 12'h7B2)?dscratch:
            32'd0:32'd0;

endmodule

`default_nettype wire
