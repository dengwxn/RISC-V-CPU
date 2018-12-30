`include "defines.v"

module id (
    input   wire                rst,
    input   wire[`InstAddrBus]  pc,
    input   wire[`InstBus]      inst,

    input   wire[`RegBus]       rdata1,
    input   wire[`RegBus]       rdata2,

    output  reg                 re1,
    output  reg[`RegAddrBus]    raddr1,
    output  reg                 re2,
    output  reg[`RegAddrBus]    raddr2,

    output  reg[`AluSelBus]     alusel,
    output  reg[`AluOpBus]      aluop,
    output  reg                 we,
    output  reg[`RegAddrBus]    waddr,
    output  reg[`RegBus]        opv1,
    output  reg[`RegBus]        opv2,

    input   wire                ex_we,
    input   wire[`RegAddrBus]   ex_waddr,
    input   wire[`RegBus]       ex_wdata,

    input   wire                mem_we,
    input   wire[`RegAddrBus]   mem_waddr,
    input   wire[`RegBus]       mem_wdata,

    output  reg                 br,
    output  reg[`InstAddrBus]   br_addr,
    output  reg[`InstAddrBus]   link_addr,
    output  reg[`RegBus]        mem_offset
);

    wire[6 : 0] opcode;
    wire[2 : 0] funct3;
    wire[6 : 0] funct7;
    wire[11 : 0] I_imm;
    wire[19 : 0] U_imm;
    wire[11 : 0] S_imm;
    wire[`RegBus] rd;
    wire[`RegBus] rs;
    wire[`RegBus] rt;

    assign opcode = inst[6 : 0];
    assign funct3 = inst[14 : 12];
    assign funct7 = inst[31 : 25];
    assign I_imm = inst[31 : 20];
    assign U_imm = inst[31 : 12];
    assign S_imm = {inst[31 : 25], inst[11 : 7]};
    assign rd = inst[11 : 7];
    assign rs = inst[19 : 15];
    assign rt = inst[24 : 20];

    reg[31 : 0] imm1, imm2;
    reg instvalid;

    wire[31 : 0] pc_plus_J_imm;
    wire[31 : 0] pc_plus_B_imm;
    wire[31 : 0] rdata1_plus_I_imm;
    wire[31 : 0] pc_plus_4;

    assign pc_plus_J_imm = pc + {{12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0};
    assign pc_plus_B_imm = pc + {{20{inst[31]}}, inst[7], inst[30 : 25], inst[11 : 8], 1'b0};
    assign rdata1_plus_I_imm = rdata1 + {{20{I_imm[11]}}, I_imm};
    assign pc_plus_4 = pc + 4;

    wire br_eq;
    wire br_ne;
    wire br_lt;
    wire br_ltu;
    wire br_ge;
    wire br_geu;
    assign br_eq = (opv1 == opv2);
    assign br_ne = (opv1 != opv2);
    assign br_lt = ($signed(opv1) < $signed(opv2));
    assign br_ltu = (opv1 < opv2);
    assign br_ge = ($signed(opv1) >= $signed(opv2));
    assign br_geu = (opv1 >= opv2);

    `define SET_INST(_alusel, _aluop, _instvalid, _re1, _raddr1, _re2, _raddr2, _imm1, _imm2, _we, _waddr, _mem_offset) \
        alusel = _alusel; \
        aluop = _aluop; \
        instvalid = _instvalid; \
        re1 = _re1; \
        raddr1 = _raddr1; \
        re2 = _re2; \
        raddr2 = _raddr2; \
        imm1 = _imm1; \
        imm2 = _imm2; \
        we = _we; \
        waddr = _waddr; \
        mem_offset = _mem_offset;

    `define SET_BRANCH(_br, _br_addr, _link_addr) \
        br = _br; \
        br_addr = _br_addr; \
        link_addr = _link_addr;

    always @ (*) begin
        if (rst) begin
            `SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            `SET_BRANCH(0, 0, 0)
        end else begin
            `SET_INST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            `SET_BRANCH(0, 0, 0)
            case (opcode)
                `OP_JAL: begin
                    `SET_INST(`EXE_RES_BRANCH, `EXE_JAL_OP, 1, 0, 0, 0, 0, 0, 0, 1, rd, 0)
                    `SET_BRANCH(1, pc_plus_J_imm, pc_plus_4)
                end
                `OP_JALR : begin
                    `SET_INST(`EXE_RES_BRANCH, `EXE_JALR_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, 0)
                    `SET_BRANCH(1, rdata1_plus_I_imm, pc_plus_4)
                end
                `OP_BRANCH : begin
                    case (funct3) 
                        `FUNCT3_BEQ : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BEQ_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_eq) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        `FUNCT3_BNE : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BNE_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_ne) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        `FUNCT3_BLT : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BLT_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_lt) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        `FUNCT3_BLTU : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BLTU_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_ltu) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        `FUNCT3_BGE : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BGE_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_ge) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        `FUNCT3_BGEU : begin
                            `SET_INST(`EXE_RES_BRANCH, `EXE_BGEU_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, 0)
                            if (br_geu) `SET_BRANCH(1, pc_plus_B_imm, pc_plus_4)
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_LOAD : begin
                    case (funct3)
                        `FUNCT3_LB : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_LB_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, {{20{I_imm[11]}}, I_imm})
                        end
                        `FUNCT3_LH : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_LH_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, {{20{I_imm[11]}}, I_imm})
                        end
                        `FUNCT3_LW : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_LW_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, {{20{I_imm[11]}}, I_imm})
                        end
                        `FUNCT3_LBU : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_LBU_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, {{20{I_imm[11]}}, I_imm})
                        end
                        `FUNCT3_LHU : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_LHU_OP, 1, 1, rs, 0, 0, 0, 0, 1, rd, {{20{I_imm[11]}}, I_imm})
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_STORE : begin
                    case (funct3)
                        `FUNCT3_SB : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_SB_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, {{20{S_imm[11]}}, S_imm})
                        end
                        `FUNCT3_SH : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_SH_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, {{20{S_imm[11]}}, S_imm})
                        end
                        `FUNCT3_SW : begin
                            `SET_INST(`EXE_RES_LOAD_STORE, `EXE_SW_OP, 1, 1, rs, 1, rt, 0, 0, 0, 0, {{20{S_imm[11]}}, S_imm})
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_OP_IMM : begin
                    case (funct3)
                        `FUNCT3_ADDI : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        `FUNCT3_SLLI : begin
                            `SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd, 0)
                        end
                        `FUNCT3_SLTI : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        `FUNCT3_SLTIU : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        `FUNCT3_XORI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        `FUNCT3_SRLI_SRAI : begin
                            case (funct7)
                                `FUNCT7_SRLI : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd, 0)
                                end
                                `FUNCT7_SRAI : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd, 0)
                                end
                            endcase
                        end
                        `FUNCT3_ORI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        `FUNCT3_ANDI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd, 0)
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_OP : begin
                    case (funct3) 
                        `FUNCT3_ADD_SUB : begin
                            case (funct7) 
                                `FUNCT7_ADD : begin
                                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                                end
                                `FUNCT7_SUB : begin
                                    `SET_INST(`EXE_RES_ARITH, `EXE_SUB_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                                end
                                default : begin
                                end
                            endcase
                        end
                        `FUNCT3_SLL : begin
                            `SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        `FUNCT3_SLT : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        `FUNCT3_SLTU : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        `FUNCT3_XOR : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        `FUNCT3_SRL_SRA : begin
                            case (funct7)
                                `FUNCT7_SRL : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                                end
                                `FUNCT7_SRA : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                                end
                            endcase
                        end
                        `FUNCT3_OR : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        `FUNCT3_AND : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd, 0)
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_LUI : begin
                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, 0, 0, 0, 0, {U_imm, 12'b0}, 1, rd, 0)
                end 
                `OP_AUIPC : begin
                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, 0, 0, 0, pc, {U_imm, 12'b0}, 1, rd, 0)
                end
                default : begin
                end
            endcase
        end
    end

    `define SET_OPV(opv, re, raddr, rdata, imm) \
        if (rst) begin \
            opv = 0; \
        end else if (re && ex_we && ex_waddr == raddr) begin \
            opv = ex_wdata; \
        end else if (re && mem_we && mem_waddr == raddr) begin \
            opv = mem_wdata; \
        end else if (re) begin \
            opv = rdata; \
        end else if (!re) begin \
            opv = imm; \
        end else begin \
            opv = 0; \
        end

    always @ (*) begin
        `SET_OPV(opv1, re1, raddr1, rdata1, imm1)
    end

    always @ (*) begin
        `SET_OPV(opv2, re2, raddr2, rdata2, imm2)
    end

endmodule