`include "defines.v"

module mem_ctrl (
    input   wire                clk,
    input   wire                rst,

    input   wire[`MemAddrBus]   if_raddr,
    output  reg[`MemBus]        rdata_o,
    output  reg                 if_mem_ctrl_done,

    output  reg                 mem_ctrl_wr,
    output  reg[`MemAddrBus]    addr,
    input   wire[`MemBus]       rdata,

    input   wire                if_cancel,

    input   wire[`MemAddrBus]   mem_addr,
    input   wire[`AluOpBus]     mem_aluop,
    input   wire[`RegBus]       rt_data,
    output  wire                mem_mem_ctrl_done
);

    reg[5 : 0] status;

    `define INIT(_addr) \
        _addr <= _addr;
    
    `define PROCEED() \
        _addr <= _addr + 1;

    `define UPDATE(_status, _if_mem_ctrl_done, _mem_ctrl_wr) \
        status <= _status; \
        if_mem_ctrl_done <= _if_mem_ctrl_done; \
        mem_ctrl_wr <= _mem_ctrl_wr;

    `define DATA_EXTRACT(_sel, _rdata) \
        rdata_o[_sel] <= _rdata;

    `define REDIRECT(_redirect_status) \
        if (_redirect_status == `MEM_IF_CANCEL_STATUS) begin \
            case (mem_aluop) \
                `EXE_LB_OP or `EXE_LH_OP or `EXE_LW_OP or `EXE_LBU_OP or `EXE_LHU_OP : begin \
                    `INIT(mem_addr) \
                    `UPDATE({1'b0, `MEM_LOAD_INIT_STATUS}, 0, 0) \
                end \
                `EXE_SB_OP or `EXE_SH_OP or `EXE_SW_OP : begin \
                    `INIT(mem_addr) \
                    `UPDATE({1'b0, `MEM_STORE_INIT_STATUS}, 0, 1) \
                end \
                default : begin \
                    `UPDATE({1'b0, `MEM_READ_STATUS}, 0, 0) \
                end \
            endcase \
        end else if (_redirect_status == `MEM_IF_DONE_STATUS && !status[6])) begin \
            case (mem_aluop) \
                `EXE_LB_OP or `EXE_LH_OP or `EXE_LW_OP or `EXE_LBU_OP or `EXE_LHU_OP : begin \
                    `INIT(mem_addr) \
                    `UPDATE({1'b1, `MEM_LOAD_INIT_STATUS}, 0, 0) \
                end \
                `EXE_SB_OP or `EXE_SH_OP or `EXE_SW_OP : begin \
                    `INIT(mem_addr) \
                    `UPDATE({1'b1, `MEM_STORE_INIT_STATUS}, 0, 1) \
                end \
                default : begin \
                    `UPDATE({1'b0, `MEM_READ_STATUS}, 0, 0) \
                end \
            endcase \
        end

    always @ (posedge clk) begin
        if (rst) begin
            `UPDATE(0, 0, 0)
        end else begin
            if (status[4] == 0 && if_cancel) begin
                `REDIRECT(`MEM_IF_CANCEL_STATUS)
            end else begin
                case (status[3 : 0])
                    `MEM_READ_STATUS_0 : begin // 4'b0000
                        `INIT(if_raddr)
                        `UPDATE(status + 1, 0, 0)
                    end
                    `MEM_READ_STATUS_1 : begin
                        `UPDATE(status + 1, 0, 0)
                    end
                    `MEM_READ_STATUS_2: begin
                        `PROCEED()
                        `UPDATE(status + 1, 0, 0)
                        `DATA_EXTRACT([7 : 0], rdata)
                    end
                    `MEM_READ_STATUS_3 : begin
                        `UPDATE(status + 1, 0, 0)
                    end
                    `MEM_READ_STATUS_4: begin
                        `PROCEED()
                        `UPDATE(status + 1, 0, 0)
                        `DATA_EXTRACT([15 : 8], rdata)
                    end
                    `MEM_READ_STATUS_5 : begin
                        `UPDATE(status + 1, 0, 0)
                    end
                    `MEM_READ_STATUS_6 : begin
                        `PROCEED()
                        `UPDATE(status + 1, 0, 0)
                        `DATA_EXTRACT([23 : 16], rdata)
                    end
                    `MEM_READ_STATUS_7 : begin
                        `UPDATE(status + 1, 0, 0)
                    end
                    `MEM_READ_STATUS_8 : begin
                        `DATA_EXTRACT([31 : 24], rdata)
                        if (!status[4]) begin
                            `REDIRECT(`MEM_IF_DONE_STATUS)
                        end else begin
                            `REDIRECT(`MEM_LOAD_DONE_STATUS)
                        end
                    end
                    default : begin
                    end
                endcase
            end
        end
    end

endmodule