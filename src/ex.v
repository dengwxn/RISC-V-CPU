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
    output  reg[`RegBus]        wdata
);

    reg[`RegBus] logic_out;
    reg[`RegBus] arith_out;
    reg[`RegBus] shift_out;

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
                `EXE_SLI_OP : begin
                    shift_out = opv1 << opv2[4 : 0];
                end
                `EXE_SRL_OP : begin
                    shift_out = opv1 >> opv2[4 : 0];
                end
                `EXE_SRA_OP : begin
                    shift_out = {(opv2){opv1[31]}, (opv1 >> opv2)[(31 - opv2) : 0]};
                end
                default : begin
                    shift_out = 0;
                end
            endcase
        end
    end

    always @ (*) begin
        waddr_o = waddr_i;
        we_o = we_i;
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
            default : begin
                wdata = 0;
            end
        endcase
    end

endmodule