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
    input   wire[`RegBus]       mem_wdata
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

    `define SET_INST(_alusel, _aluop, _instvalid, _re1, _raddr1, _re2, _raddr2, _imm1, _imm2, _we, _waddr) \
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
        waddr = _waddr;

    always @ (*) begin
        if (rst) begin
            `SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, 1, 0, 0, 0, 0, 0, 0, 0, 0)
        end else begin
            `SET_INST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            case (opcode)
                `OP_OP_IMM : begin
                    case (funct3)
                        `FUNCT3_ADDI : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
                        end
                        `FUNCT3_SLLI : begin
                            `SET_INST(`EXE_RES_SHIFT, `EXE_SLL_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd)
                        end
                        `FUNCT3_SLTI : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
                        end
                        `FUNCT3_SLTIU : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
                        end
                        `FUNCT3_XORI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
                        end
                        `FUNCT3_SRLI_SRAI : begin
                            case (funct7)
                                `FUNCT7_SRLI : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd)
                                end
                                `FUNCT7_SRAI : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs, 0, 0, 0, rt, 1, rd)
                                end
                            endcase
                        end
                        `FUNCT3_ORI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
                        end
                        `FUNCT3_ANDI : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs, 0, 0, 0, {{20{I_imm[11]}}, I_imm}, 1, rd)
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
                                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                                end
                                `FUNCT7_SUB : begin
                                    `SET_INST(`EXE_RES_ARITH, `EXE_SUB_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                                end
                                default : begin
                                end
                            endcase
                        end
                        `FUNCT3_SLT : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLT_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                        end
                        `FUNCT3_SLTU : begin
                            `SET_INST(`EXE_RES_ARITH, `EXE_SLTU_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                        end
                        `FUNCT3_XOR : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_XOR_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                        end
                        `FUNCT3_SRL_SRA : begin
                            case (funct7)
                                `FUNCT7_SRL : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRL_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                                end
                                `FUNCT7_SRA : begin
                                    `SET_INST(`EXE_RES_SHIFT, `EXE_SRA_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                                end
                            endcase
                        end
                        `FUNCT3_OR : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_OR_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                        end
                        `FUNCT3_AND : begin
                            `SET_INST(`EXE_RES_LOGIC, `EXE_AND_OP, 1, 1, rs, 1, rt, 0, 0, 1, rd)
                        end
                        default : begin
                        end
                    endcase
                end
                `OP_LUI : begin
                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, 0, 0, 0, 0, {U_imm, 12'b0}, 1, rd)
                end 
                `OP_AUIPC : begin
                    `SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, 0, 0, 0, pc, {U_imm, 12'b0}, 1, rd)
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