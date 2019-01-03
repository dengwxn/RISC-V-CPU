`include "defines.v"

module mem_ctrl (
    input   wire                clk,
    input   wire                rst,

    input   wire[`MemAddrBus]   if_raddr,
    output  reg[`InstBus]       if_rdata_o, 
    output  reg                 if_mem_ctrl_done,

    output  reg                 mem_ctrl_wr,
    output  reg[`MemAddrBus]    addr,
    output  reg[`MemBus]        wdata,
    input   wire[`MemBus]       rdata,

    input   wire                if_cancel,

    input   wire[`MemAddrBus]   mem_addr,
    input   wire[`AluOpBus]     mem_aluop,
    input   wire[`RegBus]       rt_data,
    output  reg                 load_store_mem_ctrl_done,
    output  reg[`DataBus]       load_store_rdata_o,

    input   wire                if_request,
    input   wire                load_store_request
);

    reg[5 : 0] status;
    reg[1 : 0] if_cancel_ever;

    `define START(_status, _addr, _mem_ctrl_wr, _wdata) \
        status <= _status; \
        addr <= _addr; \
        mem_ctrl_wr <= _mem_ctrl_wr; \
        wdata <= _wdata;

    `define CLEAR \
        if_mem_ctrl_done <= 0; \
        load_store_mem_ctrl_done <= 0; \
        if_cancel_ever[0] <= if_cancel_ever[1] ^ if_cancel;

    `define REDIRECT(_redirect_status) \
        if (_redirect_status == `IF_DONE_REDIRECT) begin \
            status <= `RELEASE_STATUS; \
            if_mem_ctrl_done <= 1; \
        end else if (_redirect_status == `LOAD_STORE_DONE_REDIRECT) begin \
            status <= `RELEASE_STATUS; \
            load_store_mem_ctrl_done <= 1; \
        end else if (_redirect_status == `START_REDIRECT) begin \
            if (load_store_request && load_store_request) begin \
                case (mem_aluop) \
                    `EXE_LB_OP, `EXE_LH_OP, `EXE_LW_OP, `EXE_LBU_OP, `EXE_LHU_OP : begin \
                        `START(`LOAD_INIT_STATUS, mem_addr, 0, 0) \
                    end \
                    `EXE_SB_OP, `EXE_SH_OP, `EXE_SW_OP : begin \
                        `START(`STORE_INIT_STATUS, mem_addr, 1, rt_data[7 : 0]) \
                    end \
                endcase \
            end else if (if_request && if_request) begin \
                `START(`IF_INIT_STATUS, if_raddr, 0, 0) \
            end \
        end else begin \
            status <= `INIT_STATUS; \
            `CLEAR \
        end

    `define UPDATE(_sel, _rdata) \
        if (status[5] == 0) begin \
            if_rdata_o[_sel] <= _rdata; \
        end else begin \
            load_store_rdata_o[_sel] <= _rdata; \
        end

    always @ (posedge clk) begin
        if (rst) begin
            status <= `INIT_STATUS;
            addr <= 0; 
            mem_ctrl_wr <= 0;
            wdata <= 0;
            if_mem_ctrl_done <= 0; 
            load_store_mem_ctrl_done <= 0; 
            if_cancel_ever <= 0;
        end else begin
            if_cancel_ever[1] <= if_cancel_ever[1] ^ if_cancel;
            if (status == `INIT_STATUS) begin
                `REDIRECT(`START_REDIRECT)
            end else if (status == `RELEASE_STATUS) begin
                if (!if_request && !load_store_request) begin
                    `REDIRECT(`BOTH_DONE_REDIRECT)
                end else begin
                    `REDIRECT(`START_REDIRECT)
                end
            end else if (status[4] == 0) begin // READ
                case (status[3 : 0])
                    `READ_STATUS_2: begin
                        `UPDATE(7 : 0, rdata)
                        if (status[5] && (mem_aluop == `EXE_LB_OP || mem_aluop == `EXE_LBU_OP)) begin
                            `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                        end else begin
                            status <= status + 1;
                            addr <= addr + 1;
                        end
                    end
                    `READ_STATUS_4: begin
                        `UPDATE(15 : 8, rdata)
                        if (status[5] && (mem_aluop == `EXE_LH_OP || mem_aluop == `EXE_LHU_OP)) begin
                            `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                        end else begin
                            status <= status + 1;
                            addr <= addr + 1;
                        end
                    end
                    `READ_STATUS_6 : begin
                        `UPDATE(23 : 16, rdata)
                        status <= status + 1;
                        addr <= addr + 1;
                    end
                    `READ_STATUS_8 : begin
                        `UPDATE(31 : 24, rdata)
                        if (!status[5]) begin
                            `REDIRECT(`IF_DONE_REDIRECT)
                        end else begin
                            `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                        end
                    end
                    default : begin
                        status <= status + 1;
                    end
                endcase
            end else begin // WRITE
                case (status[3 : 0])
                    `WRITE_STATUS_2: begin
                        if (mem_aluop == `EXE_SB_OP) begin
                            `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                        end else begin
                            status <= status + 1;
                            addr <= addr + 1;
                            wdata <= rt_data[15 : 8];
                        end
                    end
                    `READ_STATUS_4: begin
                        if (status[5] && mem_aluop == `EXE_SH_OP) begin
                            `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                        end else begin
                            status <= status + 1;
                            addr <= addr + 1;
                            wdata <= rt_data[23 : 16];
                        end
                    end
                    `READ_STATUS_6 : begin
                        status <= status + 1;
                        addr <= addr + 1;
                        wdata <= rt_data[31 : 24];
                    end
                    `READ_STATUS_8 : begin
                        `REDIRECT(`LOAD_STORE_DONE_REDIRECT)
                    end
                    default : begin
                        status <= status + 1;
                    end
                endcase
            end
        end
    end

endmodule