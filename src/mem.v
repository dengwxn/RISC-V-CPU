`include "defines.v"

module mem (
    input   wire                rst,
    
    input   wire[`RegAddrBus]   waddr_i,
    input   wire                we_i,
    input   wire[`RegBus]       wdata_i,

    output  reg[`RegAddrBus]    waddr_o,
    output  reg                 we_o,
    output  reg[`RegBus]        wdata_o,

    input   wire[`DataAddrBus]  mem_addr_i,
    input   wire[`AluOpBus]     mem_aluop_i,
    input   wire[`RegBus]       rt_data_i,

    output  reg                 mem_stallreq,

    output  wire[`DataAddrBus]  mem_addr_o,
    output  wire[`AluOpBus]     mem_aluop_o,
    output  wire[`RegBus]       rt_data_o,
    input   wire                load_store_mem_ctrl_done,
    input   wire[`DataBus]      rdata
);

    assign mem_addr_o = mem_addr_i;
    assign mem_aluop_o = mem_aluop_i;
    assign rt_data_o = rt_data_i;

    `define UPDATE_LOAD(_wdata_o) \
        if (load_store_mem_ctrl_done) begin \
            wdata_o = _wdata_o; \
            mem_stallreq = 0; \
        end else begin \
            wdata_o = 0; \
            mem_stallreq = 1; \
        end

    `define UPDATE_STORE \
        if (load_store_mem_ctrl_done) begin \
            mem_stallreq = 0; \
        end else begin \
            mem_stallreq = 1; \
        end

    always @ (*) begin
        if (rst) begin
            waddr_o = 0;
            we_o = 0;
            wdata_o = 0;
        end else begin
            waddr_o = waddr_i;
            we_o = we_i;
            wdata_o = wdata_i;
            case (mem_aluop_i)
                `EXE_LB_OP : begin
                    `UPDATE_LOAD({{24{rdata[7]}}, rdata[7 : 0]})
                end
                `EXE_LH_OP : begin
                    `UPDATE_LOAD({{16{rdata[15]}}, rdata[15 : 0]})
                end
                `EXE_LW_OP : begin
                    `UPDATE_LOAD(rdata)
                end
                `EXE_LBU_OP : begin
                    `UPDATE_LOAD({{24{1'b0}}, rdata[7 : 0]})
                end
                `EXE_LHU_OP : begin
                    `UPDATE_LOAD({{16{1'b0}}, rdata[15 : 0]})
                end
                `EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP : begin
                    `UPDATE_STORE
                end
                default : begin
                end
            endcase
        end
    end

endmodule