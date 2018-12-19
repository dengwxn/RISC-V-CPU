`include "defines.v"

module ex (
    input   wire                rst,
    input   wire[`AluSelBus]    alusel,
    input   wire[`AluOpBus]     aluop,
    input   wire[`RegBus]       opv1,
    input   wire[`RegBus]       opv2,
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,

    output  reg[`RegAddrBus]    waddr_o,
    output  reg                 we_o,
    output  reg[`RegBus]        wdata,

    input   wire[`InstAddrBus]  link_addr,
    input   wire[`RegBus]       mem_offset,

    output  reg[`DataAddrBus]   mem_addr,
    output  wire[`AluOpBus]     mem_aluop,
    output  wire[`RegBus]       rt_data
);

    assign mem_aluop = aluop;
    assign rt_data = opv2;

    reg[`RegBus] logic_out;
    reg[`RegBus] arith_out;
    reg[`RegBus] shift_out;
    reg[`RegBus] mem_out;

    always @ (*) begin
        if (rst || alusel != `EXE_RES_LOGIC) begin
            logic_out = 0;
        end else begin
            case (aluop)
                `EXE_XOR_OP : begin
                    logic_out = opv1 ^ opv2;
                end
                `EXE_OR_OP : begin
                    logic_out = opv1 | opv2;
                end
                `EXE_AND_OP : begin
                    logic_out = opv1 & opv2;
                end
                default : begin
                    logic_out = 0;
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst || alusel != `EXE_RES_ARITH) begin
            arith_out = 0;
        end else begin
            case (aluop) 
                `EXE_ADD_OP : begin
                    arith_out = opv1 + opv2;
                end
                `EXE_SUB_OP : begin
                    arith_out = opv1 - opv2;
                end
                `EXE_SLT_OP : begin
                    arith_out = $signed(opv1) < $signed(opv2);
                end
                `EXE_SLTU_OP : begin
                    arith_out = opv1 < opv2;
                end
                default : begin
                    arith_out = 0;
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst || alusel != `EXE_RES_SHIFT) begin
            shift_out = 0;
        end else begin
            case (aluop) 
                `EXE_SLL_OP : begin
                    shift_out = opv1 << opv2[4 : 0];
                end
                `EXE_SRL_OP : begin
                    shift_out = opv1 >> opv2[4 : 0];
                end
                `EXE_SRA_OP : begin
                    shift_out = ({32{opv1[31]}} << (6'd32 - {1'b0, opv2[4 : 0]})) | (opv1 >> opv2[4 : 0]);
                end
                default : begin
                    shift_out = 0;
                end
            endcase
        end
    end

    always @ (*) begin
        if (rst || alusel != `EXE_RES_LOAD_STORE) begin
            mem_out = 0;
        end else begin
            mem_out = opv1 + mem_offset;
        end
    end

    always @ (*) begin
        waddr_o = waddr_i;
        we_o = we_i;
        mem_addr = 0;
        case (alusel)
            `EXE_RES_LOGIC : begin
                wdata = logic_out;
            end
            `EXE_RES_ARITH : begin
                wdata = arith_out;
            end
            `EXE_RES_SHIFT : begin
                wdata = shift_out;
            end
            `EXE_RES_BRANCH : begin
                wdata = link_addr;
            end
            `EXE_RES_LOAD_STORE : begin
                wdata = 0;
                mem_addr = mem_out;
            end
            default : begin
                wdata = 0;
            end
        endcase
    end

endmodule