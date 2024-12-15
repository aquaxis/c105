`default_nettype none

module rv32i (
    input wire RST_N,
    input wire CLK,

    input  wire        I_MEM_READY,
    output wire        I_MEM_VALID,
    output wire [31:0] I_MEM_ADDR,
    input  wire [31:0] I_MEM_RDATA,
    input  wire        I_MEM_EXCPT,

    input  wire        D_MEM_READY,
    output wire        D_MEM_VALID,
    output wire [ 3:0] D_MEM_WSTB,
    output wire [31:0] D_MEM_ADDR,
    output wire [31:0] D_MEM_WDATA,
    input  wire [31:0] D_MEM_RDATA,
    input  wire        D_MEM_EXCPT,

    input wire EXT_INTERRUPT,
    input wire SOFT_INTERRUPT,
    input wire TIMER_EXPIRED,

    input  wire HALTREQ,
    input  wire RESUMEREQ,
    output wire HALT,
    output wire RESUME,
    output wire RUNNING,

    input  wire        AR_EN,
    input  wire        AR_WR,
    input  wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO
);

  reg        st1_task_exec;
  reg        st2_task_exec;
  reg        st3_task_exec;
  reg        st4_task_exec;
  reg        st5_task_exec;

  reg [31:0] st1_task_pc;
  reg [31:0] st2_task_pc;
  reg [31:0] st3_task_pc;
  reg [31:0] st4_task_pc;
  reg [31:0] st5_task_pc;

  // Program Counter
  reg [31:0] pc;
  reg [31:0] current_pc;

  wire [4:0] id_rd_num, id_rs1_num, id_rs2_num;
  wire [31:0] id_rs1, id_rs2, id_imm;

  wire   id_inst_lui, id_inst_auipc,
         id_inst_jal, id_inst_jalr,
         id_inst_beq, id_inst_bne,
         id_inst_blt, id_inst_bge,
         id_inst_bltu, id_inst_bgeu,
         id_inst_lb, id_inst_lh, id_inst_lw,
         id_inst_lbu, id_inst_lhu,
         id_inst_sb, id_inst_sh, id_inst_sw,
         id_inst_addi, id_inst_slti, id_inst_sltiu,
         id_inst_xori, id_inst_ori, id_inst_andi,
         id_inst_slli, id_inst_srli, id_inst_srai,
         id_inst_add, id_inst_sub,
         id_inst_sll, id_inst_slt, id_inst_sltu,
         id_inst_xor, id_inst_srl, id_inst_sra,
         id_inst_or, id_inst_and,
         id_inst_ecall, id_inst_ebreak, id_inst_mret,
         id_inst_csrrw, id_inst_csrrs, id_inst_csrrc,
         id_inst_csrrwi, id_inst_csrrsi, id_inst_csrrci,
         id_inst_mul, id_inst_mulh,
         id_inst_mulhsu, id_inst_mulhu,
         id_inst_div, id_inst_divu,
         id_inst_rem, id_inst_remu,
         id_ill_inst;

  wire retire;
  assign retire = 1'b0;

  //////////////////////////////////////////////////////////////////////
  // CPU State
  //////////////////////////////////////////////////////////////////////
  reg [1:0] cpu_state;
  localparam S_RESET = 2'd0;
  localparam S_EXEC = 2'd1;
  localparam S_HALT = 2'd2;
  localparam S_RESUME = 2'd3;

  wire ex_wait, ex_cwait, ex_cansel;
  reg ex_inst_ebreak;
  wire [31:0] exception_pc;
  reg haltreq_d, resumereq_d;
  reg cpu_exec, cpu_halt, cpu_resume;
  wire ex_halt;
  wire wb_pc_we;
  wire [31:0] wb_pc;

  assign HALT    = cpu_halt;
  assign RESUME  = cpu_resume;
  assign RUNNING = (cpu_state == S_RESET) | cpu_exec;

  always @(posedge CLK) begin
    if (!RST_N) begin
      haltreq_d   <= 1'b0;
      resumereq_d <= 1'b0;
    end else begin
      haltreq_d   <= HALTREQ;
      resumereq_d <= RESUMEREQ;
    end
  end
  assign ex_halt = cpu_exec & haltreq_d & !(ex_wait | ex_cwait);

  always @(posedge CLK) begin
    if (!RST_N) begin
      cpu_state  <= S_RESET;
      cpu_exec   <= 1'b0;
      cpu_halt   <= 1'b0;
      cpu_resume <= 1'b0;
    end else begin
      case (cpu_state)
        S_RESET: begin
          if (I_MEM_READY) begin
            cpu_state  <= S_EXEC;
            cpu_exec   <= 1'b1;
            cpu_halt   <= 1'b0;
            cpu_resume <= 1'b0;
          end
        end
        S_EXEC: begin
          if (haltreq_d || ex_inst_ebreak) begin
            cpu_state <= S_HALT;
            cpu_halt  <= 1'b1;
            cpu_exec  <= 1'b0;
          end else if (ex_cansel) begin
            cpu_state <= S_RESET;
            cpu_exec  <= 1'b0;
          end
        end
        S_HALT: begin
          if (resumereq_d) begin
            cpu_state  <= S_RESUME;
            cpu_halt   <= 1'b0;
            cpu_resume <= 1'b1;
          end
        end
        S_RESUME: begin
          if (!resumereq_d) begin
            cpu_state  <= S_RESET;
            cpu_resume <= 1'b0;
            cpu_exec   <= 1'b1;
          end
        end
        default: cpu_state <= S_RESET;
      endcase
    end
  end

  // wire w_ar_en;
  // assign w_ar_en = (AR_EN & AR_WR & (AR_AD == 16'h07b1)) ? 1'b1 : 1'b0;
  always @(posedge CLK) begin
    if (!RST_N) begin
      pc <= 32'd0;
    end else begin
      // if (w_ar_en) pc <= AR_DI;
      if (wb_pc_we) pc <= wb_pc;
    end
  end

  // current PC
  always @(posedge CLK) begin
    if (!RST_N) begin
      current_pc <= 32'd0;
    end else begin
      if (ex_cansel) begin
        current_pc <= exception_pc;
      end else if (!ex_wait | ex_cwait) begin
        current_pc <= pc;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Stage.1(IF:Instruction Fetch)
  //////////////////////////////////////////////////////////////////////
  wire [31:0] inst;

  // Thread Number Register
  always @(posedge CLK) begin
    if (!RST_N) begin
      st1_task_exec <= 1'b0;
      st1_task_pc[31:0] <= 32'd0;
    end else begin
      st1_task_exec <= I_MEM_READY & ((cpu_state == S_RESET) || (cpu_exec && st5_task_exec));
      st1_task_pc[31:0] <= current_pc;
    end
  end
  assign I_MEM_VALID = 1'b1;
  assign I_MEM_ADDR = current_pc;
  assign inst = (I_MEM_READY) ? I_MEM_RDATA : 32'h0000_0013;  // insert with nop

  //////////////////////////////////////////////////////////////////////
  // Stage.2(ID:Instruction Decode)
  //////////////////////////////////////////////////////////////////////
  always @(posedge CLK) begin
    if (!RST_N) begin
      st2_task_exec <= 1'b0;
      st2_task_pc[31:0] <= 32'd0;
    end else begin
      st2_task_exec <= st1_task_exec;
      st2_task_pc[31:0] <= st1_task_pc[31:0];
    end
  end

  rv32i_decode u_rv32i_decode (
      .RST_N(RST_N),
      .CLK  (CLK),

      // インストラクションコード
      .INST_CODE(inst),

      // レジスタ番号
      .RD_NUM (id_rd_num),
      .RS1_NUM(id_rs1_num),
      .RS2_NUM(id_rs2_num),

      // イミデート
      .IMM(id_imm),

      // 命令
      .INST_LUI   (id_inst_lui),
      .INST_AUIPC (id_inst_auipc),
      .INST_JAL   (id_inst_jal),
      .INST_JALR  (id_inst_jalr),
      .INST_BEQ   (id_inst_beq),
      .INST_BNE   (id_inst_bne),
      .INST_BLT   (id_inst_blt),
      .INST_BGE   (id_inst_bge),
      .INST_BLTU  (id_inst_bltu),
      .INST_BGEU  (id_inst_bgeu),
      .INST_LB    (id_inst_lb),
      .INST_LH    (id_inst_lh),
      .INST_LW    (id_inst_lw),
      .INST_LBU   (id_inst_lbu),
      .INST_LHU   (id_inst_lhu),
      .INST_SB    (id_inst_sb),
      .INST_SH    (id_inst_sh),
      .INST_SW    (id_inst_sw),
      .INST_ADDI  (id_inst_addi),
      .INST_SLTI  (id_inst_slti),
      .INST_SLTIU (id_inst_sltiu),
      .INST_XORI  (id_inst_xori),
      .INST_ORI   (id_inst_ori),
      .INST_ANDI  (id_inst_andi),
      .INST_SLLI  (id_inst_slli),
      .INST_SRLI  (id_inst_srli),
      .INST_SRAI  (id_inst_srai),
      .INST_ADD   (id_inst_add),
      .INST_SUB   (id_inst_sub),
      .INST_SLL   (id_inst_sll),
      .INST_SLT   (id_inst_slt),
      .INST_SLTU  (id_inst_sltu),
      .INST_XOR   (id_inst_xor),
      .INST_SRL   (id_inst_srl),
      .INST_SRA   (id_inst_sra),
      .INST_OR    (id_inst_or),
      .INST_AND   (id_inst_and),
      .INST_FENCE (),
      .INST_FENCEI(),
      .INST_ECALL (id_inst_ecall),
      .INST_EBREAK(id_inst_ebreak),
      .INST_MRET  (id_inst_mret),
      .INST_CSRRW (id_inst_csrrw),
      .INST_CSRRS (id_inst_csrrs),
      .INST_CSRRC (id_inst_csrrc),
      .INST_CSRRWI(id_inst_csrrwi),
      .INST_CSRRSI(id_inst_csrrsi),
      .INST_CSRRCI(id_inst_csrrci),
      .INST_MUL   (id_inst_mul),
      .INST_MULH  (id_inst_mulh),
      .INST_MULHSU(id_inst_mulhsu),
      .INST_MULHU (id_inst_mulhu),
      .INST_DIV   (id_inst_div),
      .INST_DIVU  (id_inst_divu),
      .INST_REM   (id_inst_rem),
      .INST_REMU  (id_inst_remu),

      .ILL_INST(id_ill_inst)

  );

  //////////////////////////////////////////////////////////////////////
  // Stage.3(EX:Excute)
  //////////////////////////////////////////////////////////////////////
  wire [31:0] ex_alu_rslt;
  wire        is_ex_alu_rslt;

  always @(posedge CLK) begin
    if (!RST_N) begin
      st3_task_exec <= 1'b0;
      st3_task_pc[31:0] <= 32'd0;
    end else begin
      st3_task_exec <= st2_task_exec;
      st3_task_pc[31:0] <= st2_task_pc[31:0];
    end
  end

  rv32i_alu u_rv32i_alu (
      .RST_N(RST_N),
      .CLK  (CLK),

      .INST_ADDI (id_inst_addi),
      .INST_SLTI (id_inst_slti),
      .INST_SLTIU(id_inst_sltiu),
      .INST_XORI (id_inst_xori),
      .INST_ORI  (id_inst_ori),
      .INST_ANDI (id_inst_andi),
      .INST_SLLI (id_inst_slli),
      .INST_SRLI (id_inst_srli),
      .INST_SRAI (id_inst_srai),
      .INST_ADD  (id_inst_add),
      .INST_SUB  (id_inst_sub),
      .INST_SLL  (id_inst_sll),
      .INST_SLT  (id_inst_slt),
      .INST_SLTU (id_inst_sltu),
      .INST_XOR  (id_inst_xor),
      .INST_SRL  (id_inst_srl),
      .INST_SRA  (id_inst_sra),
      .INST_OR   (id_inst_or),
      .INST_AND  (id_inst_and),

      .INST_BEQ (id_inst_beq),
      .INST_BNE (id_inst_bne),
      .INST_BLT (id_inst_blt),
      .INST_BGE (id_inst_bge),
      .INST_BLTU(id_inst_bltu),
      .INST_BGEU(id_inst_bgeu),

      .INST_LB (id_inst_lb),
      .INST_LH (id_inst_lh),
      .INST_LW (id_inst_lw),
      .INST_LBU(id_inst_lbu),
      .INST_LHU(id_inst_lhu),
      .INST_SB (id_inst_sb),
      .INST_SH (id_inst_sh),
      .INST_SW (id_inst_sw),

      .RS1(id_rs1),
      .RS2(id_rs2),
      .IMM(id_imm),

      .RSLT_VALID(is_ex_alu_rslt),
      .RSLT      (ex_alu_rslt)
  );

  assign ex_wait = (id_inst_div | id_inst_divu | id_inst_rem | id_inst_remu);

  // add PC
  reg [31:0] ex_pc_add_imm, ex_pc_add_4, ex_pc_jalr;
  always @(posedge CLK) begin
    ex_pc_add_imm <= st2_task_pc[31:0] + id_imm;  // AUIPC for rd, BRANCH, JAL for pc
    ex_pc_jalr    <= id_rs1 + id_imm;  // for JALR
    ex_pc_add_4   <= st2_task_pc[31:0] + 4;  // Normal
  end

  reg [11:0] ex_csr_addr;
  reg        ex_csr_we;
  reg [31:0] ex_csr_wdata;
  reg [31:0] ex_csr_wmask;
  always @(posedge CLK) begin
    if (!RST_N) begin
      ex_csr_addr  <= 0;
      ex_csr_we    <= 0;
      ex_csr_wdata <= 0;
      ex_csr_wmask <= 0;
    end else begin
      ex_csr_addr <= id_imm[11:0];
      ex_csr_we    <= (id_inst_csrrw | id_inst_csrrc) | ((id_inst_csrrwi | id_inst_csrrci) & (id_rs1_num == 5'd0));
      ex_csr_wdata <= (id_inst_csrrw)?id_rs1:
                    (id_inst_csrrs)?~id_rs1:
                    (id_inst_csrrc)?32'd0:
                    (id_inst_csrrwi)?(32'b1 << id_rs1_num):
                    (id_inst_csrrsi)?(32'b1 << id_rs1_num):
                    (id_inst_csrrci)?32'd0:
                    32'd0;
      ex_csr_wmask <= (id_inst_csrrw)?32'hffff_ffff:
                    (id_inst_csrrs)?id_rs1:
                    (id_inst_csrrc)?id_rs1:
                    (id_inst_csrrwi)?~(32'b1 << id_rs1_num):
                    (id_inst_csrrsi)?~(32'b1 << id_rs1_num):
                    (id_inst_csrrci)?~(32'b1 << id_rs1_num):
                    32'd0;
    end
  end

  reg [31:0] ex_rs2, ex_imm;
  reg [4:0] ex_rd_num;
  reg ex_inst_sb, ex_inst_sh, ex_inst_sw;
  reg ex_inst_lbu, ex_inst_lhu, ex_inst_lb, ex_inst_lh, ex_inst_lw;
  reg ex_inst_lui, is_ex_load, ex_inst_auipc, ex_inst_jal, ex_inst_jalr;
  reg is_ex_csr;
  reg ex_inst_beq, ex_inst_bne, ex_inst_blt, ex_inst_bge, ex_inst_bltu, ex_inst_bgeu;
  reg ex_inst_mret;
  reg ex_inst_ecall;
  reg is_ex_mul, is_ex_div;
  always @(posedge CLK) begin
    if (!RST_N) begin
      ex_rs2         <= 0;
      ex_imm         <= 0;
      ex_rd_num      <= 0;
      ex_inst_sb     <= 0;
      ex_inst_sh     <= 0;
      ex_inst_sw     <= 0;
      ex_inst_lbu    <= 0;
      ex_inst_lhu    <= 0;
      ex_inst_lb     <= 0;
      ex_inst_lh     <= 0;
      ex_inst_lw     <= 0;
      is_ex_load     <= 0;
      ex_inst_lui    <= 0;
      ex_inst_auipc  <= 0;
      ex_inst_jal    <= 0;
      ex_inst_jalr   <= 0;
      is_ex_csr      <= 0;
      ex_inst_beq    <= 0;
      ex_inst_bne    <= 0;
      ex_inst_blt    <= 0;
      ex_inst_bge    <= 0;
      ex_inst_bltu   <= 0;
      ex_inst_bgeu   <= 0;
      ex_inst_mret   <= 0;
      ex_inst_ecall  <= 0;
      ex_inst_ebreak <= 0;
      is_ex_mul      <= 0;
      is_ex_div      <= 0;
    end else begin
      ex_rs2 <= id_rs2;
      ex_imm <= id_imm;
      ex_rd_num <= id_rd_num;
      ex_inst_sb <= id_inst_sb;
      ex_inst_sh <= id_inst_sh;
      ex_inst_sw <= id_inst_sw;
      ex_inst_lbu <= id_inst_lbu;
      ex_inst_lhu <= id_inst_lhu;
      ex_inst_lb <= id_inst_lb;
      ex_inst_lh <= id_inst_lh;
      ex_inst_lw <= id_inst_lw;
      is_ex_load <= id_inst_lb | id_inst_lh | id_inst_lw | id_inst_lbu | id_inst_lhu;
      ex_inst_lui <= id_inst_lui;
      ex_inst_auipc <= id_inst_auipc;
      ex_inst_jal <= id_inst_jal;
      ex_inst_jalr <= id_inst_jalr;
      is_ex_csr     <= id_inst_csrrw | id_inst_csrrs | id_inst_csrrc | id_inst_csrrwi | id_inst_csrrsi | id_inst_csrrci;
      ex_inst_beq <= id_inst_beq;
      ex_inst_bne <= id_inst_bne;
      ex_inst_blt <= id_inst_blt;
      ex_inst_bge <= id_inst_bge;
      ex_inst_bltu <= id_inst_bltu;
      ex_inst_bgeu <= id_inst_bgeu;
      ex_inst_mret <= id_inst_mret;
      ex_inst_ecall <= id_inst_ecall;
      ex_inst_ebreak <= id_inst_ebreak;
      is_ex_mul <= id_inst_mul | id_inst_mulh | id_inst_mulhsu | id_inst_mulhu;
      is_ex_div <= id_inst_div | id_inst_divu | id_inst_rem | id_inst_remu;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Stage.4(MA:Memory Access)
  //////////////////////////////////////////////////////////////////////
  // Thread Number Register
  always @(posedge CLK) begin
    if (!RST_N) begin
      st4_task_exec <= 1'b0;
      st4_task_pc[31:0] <= 32'd0;
    end else begin
      st4_task_exec <= st3_task_exec;
      st4_task_pc[31:0] <= st3_task_pc[31:0];
    end
  end
  assign D_MEM_ADDR = ex_alu_rslt;
  // for Store instruction
  assign D_MEM_WDATA = (ex_inst_sb)?{4{ex_rs2[7:0]}}:
                    (ex_inst_sh)?{2{ex_rs2[15:0]}}:
                    (ex_inst_sw)?{ex_rs2}:
                    32'd0;
  wire [3:0] w_dmem_wstb;

  assign w_dmem_wstb[0] = (ex_inst_sb & (ex_alu_rslt[1:0] == 2'b00)) |
                        (ex_inst_sh & (ex_alu_rslt[1] == 1'b0)) |
                        (ex_inst_sw);
  assign w_dmem_wstb[1] = (ex_inst_sb & (ex_alu_rslt[1:0] == 2'b01)) |
                        (ex_inst_sh & (ex_alu_rslt[1] == 1'b0)) |
                        (ex_inst_sw);
  assign w_dmem_wstb[2] = (ex_inst_sb & (ex_alu_rslt[1:0] == 2'b10)) |
                        (ex_inst_sh & (ex_alu_rslt[1] == 1'b1)) |
                        (ex_inst_sw);
  assign w_dmem_wstb[3] = (ex_inst_sb & (ex_alu_rslt[1:0] == 2'b11)) |
                        (ex_inst_sh & (ex_alu_rslt[1] == 1'b1)) |
                        (ex_inst_sw);
  assign D_MEM_WSTB = w_dmem_wstb;
  assign D_MEM_VALID = ex_inst_sb | ex_inst_sh | ex_inst_sw |
                  ex_inst_lbu | ex_inst_lb |
                  ex_inst_lb | ex_inst_lh | ex_inst_lhu | ex_inst_lw;

  // Delay Buffer
  reg [4:0] ma_rd_num;
  reg [31:0] ma_alu_rslt, ma_imm;
  reg ma_inst_lbu, ma_inst_lhu, ma_inst_lb, ma_inst_lh, ma_inst_lw;
  reg ma_inst_lui, is_ma_load, ma_inst_auipc;
  reg ma_inst_jal, ma_inst_jalr;
  reg is_ma_csr, is_ma_alu_rslt;
  reg [31:0] ma_pc_jalr, ma_pc_add_imm, ma_pc_add_4;
  reg ma_inst_ecall, ma_inst_ebreak;
  reg        ma_inst_branch;
  reg        ma_inst_mret;
  reg [31:0] ma_dmem_addr;
  always @(posedge CLK) begin
    if (!RST_N) begin
      ma_rd_num      <= 0;
      is_ma_alu_rslt <= 0;
      ma_alu_rslt    <= 0;
      ma_imm         <= 0;
      ma_inst_lbu    <= 0;
      ma_inst_lhu    <= 0;
      ma_inst_lb     <= 0;
      ma_inst_lh     <= 0;
      ma_inst_lw     <= 0;
      is_ma_load     <= 0;
      ma_inst_lui    <= 0;
      ma_inst_auipc  <= 0;
      ma_inst_jal    <= 0;
      ma_inst_jalr   <= 0;
      is_ma_csr      <= 0;
      ma_pc_add_imm  <= 0;
      ma_pc_add_4    <= 0;
      ma_pc_jalr     <= 0;
      ma_inst_ecall  <= 0;
      ma_inst_ebreak <= 0;
      ma_inst_branch <= 0;
      ma_inst_mret   <= 0;
      ma_dmem_addr   <= 0;
    end else begin
      ma_rd_num <= ex_rd_num;
      is_ma_alu_rslt <= is_ex_alu_rslt | is_ex_mul | is_ex_div;
      ma_alu_rslt <= (is_ex_alu_rslt) ? ex_alu_rslt : 32'd0;
      ma_imm <= ex_imm;
      ma_inst_lbu <= ex_inst_lbu;
      ma_inst_lhu <= ex_inst_lhu;
      ma_inst_lb <= ex_inst_lb;
      ma_inst_lh <= ex_inst_lh;
      ma_inst_lw <= ex_inst_lw;
      is_ma_load <= is_ex_load;
      ma_inst_lui <= ex_inst_lui;
      ma_inst_auipc <= ex_inst_auipc;
      ma_inst_jal <= ex_inst_jal;
      ma_inst_jalr <= ex_inst_jalr;
      is_ma_csr <= is_ex_csr;
      ma_pc_add_imm <= ex_pc_add_imm;
      ma_pc_add_4 <= ex_pc_add_4;
      ma_pc_jalr <= ex_pc_jalr;
      ma_inst_ecall <= ex_inst_ecall;
      ma_inst_ebreak <= ex_inst_ebreak;
      ma_inst_branch <= (ex_inst_beq | ex_inst_bne | ex_inst_blt | ex_inst_bge | ex_inst_bltu | ex_inst_bgeu);
      ma_inst_mret <= ex_inst_mret;
      ma_dmem_addr <= ex_alu_rslt;
    end
  end

  reg [11:0] ma_csr_addr;
  reg        ma_csr_we;
  reg [31:0] ma_csr_wdata;
  reg [31:0] ma_csr_wmask;
  always @(posedge CLK) begin
    if (!RST_N) begin
      ma_csr_addr  <= 0;
      ma_csr_we    <= 0;
      ma_csr_wdata <= 0;
      ma_csr_wmask <= 0;
    end else begin
      ma_csr_addr  <= ex_csr_addr;
      ma_csr_we    <= ex_csr_we;
      ma_csr_wdata <= ex_csr_wdata;
      ma_csr_wmask <= ex_csr_wmask;
    end
  end

  //////////////////////////////////////////////////////////////////////
  // Stage.5(WB:Write Back)
  //////////////////////////////////////////////////////////////////////
  // Thread Number Register
  always @(posedge CLK) begin
    if (!RST_N) begin
      st5_task_exec <= 1'b0;
      st5_task_pc[31:0] <= 32'd0;
    end else begin
      st5_task_exec <= st4_task_exec;
      st5_task_pc[31:0] <= st4_task_pc[31:0];
    end
  end
  // for Load instruction
  wire [31:0] ma_load;
  assign ma_load[7:0]   = (((ma_inst_lb | ma_inst_lbu) & (ma_alu_rslt[1:0] == 2'b00))?D_MEM_RDATA[7:0]:8'd0) |
                        (((ma_inst_lb | ma_inst_lbu) & (ma_alu_rslt[1:0] == 2'b01))?D_MEM_RDATA[15:8]:8'd0) |
                        (((ma_inst_lb | ma_inst_lbu) & (ma_alu_rslt[1:0] == 2'b10))?D_MEM_RDATA[23:16]:8'd0) |
                        (((ma_inst_lb | ma_inst_lbu) & (ma_alu_rslt[1:0] == 2'b11))?D_MEM_RDATA[31:24]:8'd0) |
                        (((ma_inst_lh | ma_inst_lhu) & (ma_alu_rslt[1]   == 1'b0 ))?D_MEM_RDATA[7:0]:8'd0) |
                        (((ma_inst_lh | ma_inst_lhu) & (ma_alu_rslt[1]   == 1'b1 ))?D_MEM_RDATA[23:16]:8'd0) |
                        ((ma_inst_lw)?D_MEM_RDATA[7:0]:8'd0) |
                        8'd0;
  assign ma_load[15:8]  = ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b00))?{8{D_MEM_RDATA[7]}}:8'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b01))?{8{D_MEM_RDATA[15]}}:8'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b10))?{8{D_MEM_RDATA[23]}}:8'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b11))?{8{D_MEM_RDATA[31]}}:8'd0) |
                        (((ma_inst_lh | ma_inst_lhu) & (ma_alu_rslt[1] == 1'b0))?D_MEM_RDATA[15:8]:8'd0) |
                        (((ma_inst_lh | ma_inst_lhu) & (ma_alu_rslt[1] == 1'b1))?D_MEM_RDATA[31:24]:8'd0) |
                        ((ma_inst_lw)?D_MEM_RDATA[15:8]:8'd0) |
                        8'd0;
  assign ma_load[31:16] = ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b00))?{16{D_MEM_RDATA[7]}}:16'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b01))?{16{D_MEM_RDATA[15]}}:16'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b10))?{16{D_MEM_RDATA[23]}}:16'd0) |
                        ((ma_inst_lb & (ma_alu_rslt[1:0] == 2'b11))?{16{D_MEM_RDATA[31]}}:16'd0) |
                        ((ma_inst_lh & (ma_alu_rslt[1]   == 1'b0 ))?{16{D_MEM_RDATA[15]}}:16'd0) |
                        ((ma_inst_lh & (ma_alu_rslt[1]   == 1'b1 ))?{16{D_MEM_RDATA[31]}}:16'd0) |
                        ((ma_inst_lw)?D_MEM_RDATA[31:16]:16'd0) |
                        16'd0;

  wire [ 4:0] wb_rd_num;
  wire        wb_we;
  wire [31:0] wb_rd;
  wire [31:0] ma_csr_rdata;

  assign wb_rd_num = ma_rd_num;
  assign wb_we = 1'b1;
  assign wb_rd =  (is_ma_load)?ma_load:
                (is_ma_alu_rslt)?ma_alu_rslt:
                (ma_inst_lui)?ma_imm:
                (ma_inst_auipc)?ma_pc_add_imm:
                (ma_inst_jal | ma_inst_jalr)?ma_pc_add_4:
                (is_ma_csr)?ma_csr_rdata:
                32'd0;

  // PCのWrite BackはInstruction Memoryのタイミング調整のため
  // Executeの結果でMemory Accessで書き込みを実施する
  wire        interrupt;
  wire [31:0] epc;
  wire [31:0] handler_pc;
  wire        exception;
  wire        exception_break;
  wire [11:0] exception_code;
  wire [31:0] exception_addr;
  wire        sw_interrupt;
  wire [31:0] sw_interrupt_pc;

  wire detect_exception, detect_ebreak, detect_branch;
  assign detect_exception = exception | sw_interrupt;
  assign detect_ebreak = ex_inst_ebreak | haltreq_d;
  assign detect_branch = ((ex_inst_beq | ex_inst_bne | ex_inst_blt | ex_inst_bge | ex_inst_bltu | ex_inst_bgeu) & (ex_alu_rslt == 32'd1)) | ex_inst_jal;

  assign exception_break = ma_inst_ebreak & st5_task_exec;
  assign exception = (I_MEM_EXCPT | D_MEM_EXCPT | exception_break);
  assign exception_code = {7'd0, D_MEM_EXCPT, exception_break, id_ill_inst, 1'b0, I_MEM_EXCPT};
  assign exception_addr = I_MEM_ADDR;
  assign exception_pc     = (detect_exception | interrupt | (cpu_exec & detect_ebreak))?current_pc:
                            (cpu_exec & ex_inst_mret)?epc:
                            (cpu_exec & detect_branch)?ex_pc_add_imm:
                            (cpu_exec & ex_inst_jalr)?ex_pc_jalr:
                            (~(detect_exception | interrupt | (cpu_exec & (detect_ebreak | ex_inst_mret | detect_branch | ex_inst_jalr))))?current_pc:
                            32'd0;
  assign sw_interrupt = ma_inst_ecall;
  assign sw_interrupt_pc = current_pc;

  assign wb_pc_we = st5_task_exec & !(exception | interrupt | sw_interrupt);
  assign wb_pc    = ((ma_inst_branch & (is_ma_alu_rslt == 1'b1)) | ma_inst_jal)?ma_pc_add_imm:
                  ma_pc_add_4;

  assign wb_pc            = (detect_exception)?handler_pc:
                            (~ex_cwait & cpu_exec & detect_ebreak)?current_pc:
                            (~ex_cwait & cpu_exec & ex_inst_mret)?epc:
                            (~ex_cwait & cpu_exec & detect_branch)?ex_pc_add_imm:
                            (~ex_cwait & cpu_exec & ex_inst_jalr)?ex_pc_jalr:
                            ( ex_cwait | ~(detect_exception | (cpu_exec & (detect_ebreak | ex_inst_mret | detect_branch | ex_inst_jalr))))?ma_pc_add_4:
                            32'd0;

  //////////////////////////////////////////////////////////////////////
  // Register
  //////////////////////////////////////////////////////////////////////
  wire [31:0] AR_DO_reg;

  rv32i_reg u_rv32i_reg (
      .RST_N(RST_N),
      .CLK  (CLK),

      .WADDR(wb_rd_num),
      .WE   (st5_task_exec & wb_we),
      .WDATA(wb_rd),

      .RS1ADDR(id_rs1_num),
      .RS1    (id_rs1),
      .RS2ADDR(id_rs2_num),
      .RS2    (id_rs2),

      .AR_EN(AR_EN),
      .AR_WR(AR_WR),
      .AR_AD(AR_AD),
      .AR_DI(AR_DI),
      .AR_DO(AR_DO_reg)
  );

  //////////////////////////////////////////////////////////////////////
  // CSR
  //////////////////////////////////////////////////////////////////////
  wire [31:0] AR_DO_csr;
  rv32i_csr u_rv32i_csr (
      .RST_N(RST_N),
      .CLK  (CLK),

      .CSR_ADDR (ma_csr_addr),
      .CSR_WE   (ma_csr_we),
      .CSR_WDATA(ma_csr_wdata),
      .CSR_WMASK(ma_csr_wmask),
      .CSR_RDATA(ma_csr_rdata),

      .EXT_INTERRUPT  (EXT_INTERRUPT),
      .SW_INTERRUPT   (sw_interrupt | SOFT_INTERRUPT),
      .SW_INTERRUPT_PC(sw_interrupt_pc),
      .EXCEPTION      (exception),
      .EXCEPTION_CODE (exception_code),
      .EXCEPTION_ADDR (exception_addr),
      .EXCEPTION_PC   (exception_pc),
      .TIMER_EXPIRED  (TIMER_EXPIRED),
      .RETIRE         (retire),

      .HANDLER_PC       (handler_pc),
      .EPC              (epc),
      .INTERRUPT_PENDING(),
      .INTERRUPT        (interrupt),

      .ILLEGAL_ACCESS(),

      .DPC(current_pc),

      .RESUMEREQ(resumereq_d),
      .EBREAK   (ex_inst_ebreak),
      .HALTREQ  (haltreq_d),

      .AR_EN(AR_EN),
      .AR_WR(AR_WR),
      .AR_AD(AR_AD),
      .AR_DI(AR_DI),
      .AR_DO(AR_DO_csr)
  );

  assign AR_DO = AR_DO_reg | AR_DO_csr;

endmodule

`default_nettype wire
