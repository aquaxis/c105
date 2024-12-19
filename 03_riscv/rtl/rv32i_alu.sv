`timescale 1ns / 1ns 
//
`default_nettype none

module rv32i_alu (
    input wire RST_N,
    input wire CLK,

    input wire INST_ADDI,
    input wire INST_SLTI,
    input wire INST_SLTIU,
    input wire INST_XORI,
    input wire INST_ORI,
    input wire INST_ANDI,
    input wire INST_SLLI,
    input wire INST_SRLI,
    input wire INST_SRAI,
    input wire INST_ADD,
    input wire INST_SUB,
    input wire INST_SLL,
    input wire INST_SLT,
    input wire INST_SLTU,
    input wire INST_XOR,
    input wire INST_SRL,
    input wire INST_SRA,
    input wire INST_OR,
    input wire INST_AND,

    input wire INST_BEQ,
    input wire INST_BNE,
    input wire INST_BLT,
    input wire INST_BGE,
    input wire INST_BLTU,
    input wire INST_BGEU,

    input wire INST_LB,
    input wire INST_LH,
    input wire INST_LW,
    input wire INST_LBU,
    input wire INST_LHU,
    input wire INST_SB,
    input wire INST_SH,
    input wire INST_SW,

    input wire [31:0] RS1,
    input wire [31:0] RS2,
    input wire [31:0] IMM,

    output reg        RSLT_VALID,
    output reg [31:0] RSLT

);

  /*
  下記の命令でrs1+IMMを行うのはLOAD, STORE命令のアドレス値を  算出するためです。
  INST_LB, INST_LH, INST_LW, INST_LBU, INST_LHU,
  INST_SB, INST_SH, INST_SW
*/
  reg [31:0] reg_op2;
  always @(*) begin
    reg_op2 = (INST_ADDI | INST_SLTI | INST_SLTIU |
              INST_XORI | INST_ANDI | INST_ORI |
              INST_SLLI | INST_SRLI | INST_SRAI |
              INST_LB | INST_LH | INST_LW | INST_LBU | INST_LHU |
              INST_SB | INST_SH | INST_SW)?IMM:RS2;
  end

  reg [31:0] alu_add_sub, alu_shl, alu_shr;
  reg [31:0] alu_xor, alu_or, alu_and;
  reg alu_eq, alu_ltu, alu_lts;

  always @(*) begin
    alu_add_sub = (INST_SUB) ? (RS1 - reg_op2) : (RS1 + reg_op2);
    alu_shl     = RS1 << reg_op2[4:0];
    alu_shr     = $signed({(INST_SRA | INST_SRAI) ? RS1[31] : 1'b0, RS1}) >>> reg_op2[4:0];
    alu_eq      = (RS1 == reg_op2);
    alu_lts     = ($signed(RS1) < $signed(reg_op2));
    alu_ltu     = (RS1 < reg_op2);
    alu_xor     = RS1 ^ reg_op2;
    alu_or      = RS1 | reg_op2;
    alu_and     = RS1 & reg_op2;
  end

  always @(posedge CLK) begin
    if (!RST_N) begin
      RSLT       <= 0;
      RSLT_VALID <= 0;
    end else begin
      RSLT <=       (INST_ADDI | INST_ADD | INST_SUB | INST_LB | INST_LH | INST_LW | INST_LBU | INST_LHU | INST_SB | INST_SH | INST_SW)?alu_add_sub:
                  (INST_SLTI | INST_SLT)?{31'd0, alu_lts}:
                  (INST_SLTIU | INST_SLTU)?{31'd0, alu_ltu}:
                  (INST_SLLI | INST_SLL)?alu_shl:
                  (INST_SRLI | INST_SRAI | INST_SRL | INST_SRA)?alu_shr:
                  (INST_XORI | INST_XOR)?alu_xor:
                  (INST_ORI | INST_OR)?alu_or:
                  (INST_ANDI | INST_AND)?alu_and:
                  (INST_BEQ)?{31'd0, alu_eq}:
                  (INST_BNE)?{31'd0, !alu_eq}:
                  (INST_BGE)?{31'd0, !alu_lts}:
                  (INST_BGEU)?{31'd0, !alu_ltu}:
                  (INST_BLT)?{31'd0, alu_lts}:
                  (INST_BLTU)?{31'd0, alu_ltu}:
                  32'd0;
      RSLT_VALID <= INST_ADDI | INST_ADD | INST_SUB | INST_LB | INST_LH | INST_LW | INST_LBU | INST_LHU | INST_SB | INST_SH | INST_SW |
                  INST_SLTI | INST_SLT | INST_SLTIU | INST_SLTU |
                  INST_SLLI | INST_SLL |
                  INST_SRLI | INST_SRAI | INST_SRL | INST_SRA |
                  INST_XORI | INST_XOR |
                  INST_ORI | INST_OR |
                  INST_ANDI | INST_AND |
                  INST_BEQ | INST_BNE | INST_BGE | INST_BGEU |
                  INST_BLT | INST_BLTU;
    end
  end

endmodule

`default_nettype wire
