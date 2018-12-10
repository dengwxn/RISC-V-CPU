`include "defines.v"

module mem_ctrl (
    input   wire                clk,
    input   wire                rst,

    input   wire[`MemAddrBus]   if_raddr,
    output  reg[`MemBus]        rdata_o,
    output  reg                 if_mem_ctrl_done,

    output  reg                 mem_ctrl_wr,
    output  reg[`MemAddrBus]    addr,
    input   wire[`MemBus]       rdata
);

    reg[4 : 0] status;

    `define UPDATE(_status, _if_mem_ctrl_done, _addr, _mem_ctrl_wr) \
        status <= _status; \
        if_mem_ctrl_done <= _if_mem_ctrl_done; \
        addr <= _addr; \
        mem_ctrl_wr <= _mem_ctrl_wr;

    `define DATA_EXTRACT(_sel, _rdata) \
        rdata_o[_sel] <= _rdata;

    always @ (posedge clk) begin
        if (rst) begin
            `UPDATE(5'b00000, 0, {32{0}}, 0)
        end else begin
            case (status)
                // 5'b010001 need to change later
                5'b00000 or 5'b010001: begin
                    `UPDATE(5'b00001, 0, if_raddr, 0)
                end
                5'b00001 : begin
                    `UPDATE(5'b00010, 0, if_raddr, 0)
                end
                5'b00010: begin
                    `UPDATE(5'b00011, 0, if_raddr + 1, 0)
                    `DATA_EXTRACT([7 : 0], rdata)
                end
                5'b00011 : begin
                    `UPDATE(5'b00100, 0, if_raddr + 1, 0)
                end
                5'b00100: begin
                    `UPDATE(5'b00101, 0, if_raddr + 2, 0)
                    `DATA_EXTRACT([15 : 8], rdata)
                end
                5'b00101 : begin
                    `UPDATE(5'b00110, 0, if_raddr + 2, 0)
                end
                5'b00110 : begin
                    `UPDATE(5'b00111, 0, if_raddr + 3, 0)
                    `DATA_EXTRACT([23 : 16], rdata)
                end
                5'b00111 : begin
                    `UPDATE(5'b01000, 0, if_raddr + 3, 0)
                end
                5'b01000 : begin
                    `UPDATE(5'b01001, 1, 0, 0)
                    `DATA_EXTRACT([31 : 24], rdata)
                end
            endcase
        end
    end

endmodule