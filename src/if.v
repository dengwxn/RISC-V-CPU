`include "defines.v"

module stage_if (
    input   wire                clk,
    input   wire                rst,

    input   wire[`InstAddrBus]  pc_i,
    input   wire                ce,

    output  reg[`InstAddrBus]   pc_o,
    output  reg[`InstBus]       inst,
    output  reg                 if_stallreq,

    output  wire[`InstAddrBus]  raddr,
    input   wire                if_mem_ctrl_done,
    input   wire[`InstBus]      rdata,

    input   wire                br,
    output  reg                 cancel
);

    assign raddr = pc_i;

    always @ (*) begin
        cancel = 0;
        if (rst || !ce) begin
            pc_o = 0;
            inst = 0;
            if_stallreq = 0;
        end else if (br) begin
            cancel = 1;
            pc_o = 0;
            inst = 0;
            if_stallreq = 0;
        end else if (if_mem_ctrl_done) begin
            pc_o = pc_i;
            inst = rdata;
            if_stallreq = 0;
        end else begin
            pc_o = 0;
            inst = 0;
            if_stallreq = 1;    
        end
    end

endmodule