`include "defines.v"

module mem_ctrl (
    input   wire                clk,
    input   wire                rst,

    input   wire[`MemAddrBus]   if_raddr,
    output  reg[`MemBus]        rdata_o,
    output  reg                 if_mem_ctrl_done,

    output  reg                 mem_ctrl_wr,
    output  reg[`MemAddrBus]    addr,
    output  reg[`MemBus]        wdata,
    input   wire[`MemBus]       rdata,

    input   wire                if_cancel,

    input   wire[`MemAddrBus]   mem_addr,
    input   wire[`AluOpBus]     mem_aluop,
    input   wire[`RegBus]       rt_data,
    output  reg                 load_store_mem_ctrl_done
);

    reg[5 : 0] status;

    `define START(_status, _addr, _mem_ctrl_wr, _wdata) \
        status <= _status; \
        addr <= _addr; \
        mem_ctrl_wr <= _mem_ctrl_wr; \
        wdata <= _wdata;

    `define RESET() \
        status <= 0;
        if_mem_ctrl_done <= 0;
        load_store_mem_ctrl_done <= 0;

    `define REDIRECT(_redirect_status) \
        if (_redirect_status == `IF_DONE_STATUS) begin \
            if_mem_ctrl_done <= 1; \
        end else if (_redirect_status == `LOAD_STORE_DONE_STATUS) begin \
            load_store_mem_ctrl_done <= 1; \
        end \
        if (_redirect_status == `START_STATUS) begin \
            case (mem_aluop) \
                `EXE_LB_OP or `EXE_LH_OP or `EXE_LW_OP or `EXE_LBU_OP or `EXE_LHU_OP : begin \
                    `START(`LOAD_INIT_STATUS, mem_addr, 0, 0) \
                end \
                `EXE_SB_OP or `EXE_SH_OP or `EXE_SW_OP : begin \
                    `START(`STORE_INIT_STATUS, mem_addr, 1, rt_data) \
                end \
                default : begin \
                    `START(`IF_INIT_STATUS, if_addr, 0, 0) \
                end \
            endcase \
        end else if (_redirect_status == `LOAD_STORE_DONE_STATUS && !if_cancel) begin \
            `START(`IF_INIT_STATUS, if_addr, 0, 0) \
        end else begin \
            `RESET() \
        end

    always @ (posedge clk) begin
        if (rst) begin
            `RESET()
        end else begin
            if (status == `INIT_STATUS) begin
                `REDIRECT(`START_STATUS)
            end else if (status[5] == 0 && if_cancel) begin
                `REDIRECT(`IF_CANCEL_STATUS)
            end else if (status[4] == 0) begin // READ
                if (status[3 : 0] == `READ_STATUS_8) begin
                    rdata_o[31 : 24] <= rdata;
                    if (!status[5]) begin
                        `REDIRECT(`IF_DONE_STATUS)
                    end else begin
                        `REDIRECT(`LOAD_STORE_DONE_STATUS)
                    end
                end else begin
                    status <= status + 1;
                    case (status[3 : 0])
                        `READ_STATUS_2: begin
                            rdata_o[7 : 0] <= rdata;
                            if (status[5] && (mem_aluop == `EXE_LB_OP || mem_aluop == `EXE_LBU_OP)) begin
                                `REDIRECT(`LOAD_STORE_DONE_STATUS)
                            end else begin
                                addr <= addr + 1;
                            end
                        end
                        `READ_STATUS_4: begin
                            rdata_o[15 : 8] <= rdata;
                            if (status[5] && (mem_aluop == `EXE_LH_OP || mem_aluop == `EXE_LHU_OP)) begin
                                `REDIRECT(`LOAD_STORE_DONE_STATUS)
                            end else begin
                                addr <= addr + 1;
                            end
                        end
                        `READ_STATUS_6 : begin
                            rdata_o[23 : 16] <= rdata;
                            addr <= addr + 1;
                        end
                        default : begin
                        end
                    endcase
                end
            end else begin // WRITE
                `REDIRECT(`LOAD_STORE_DONE_STATUS)
            end
        end
    end

endmodule