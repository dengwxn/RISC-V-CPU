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
    output  reg                 wdata,
);

    reg[`RegBus] logic_out;

    always @ (*) begin
        if (rst || alusel != `EXE_RES_LOGIC) begin
            logic_out = 0;
        end else begin
            case (aluop)
                `EXE_OR_OP : begin
                    logic_out = opv1 | opv2;
                end
                default : begin
                    logic_out = 0;
                end
            endcase
        end
    end