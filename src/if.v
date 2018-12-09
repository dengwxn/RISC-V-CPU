`include "defines.v"

module if (
    input   wire                clk,
    input   wire                rst,

    input   wire[`InstAddrBus]  pc_i,
    input   wire                ce,
    input   wire[4 : 0]         stall,

    output  reg                 pc_o,
    output  reg                 inst,
    output  reg                 if_stallreq,

    output  reg                 raddr,
    input   wire                if_mem_ctrl_done,
    input   wire[`InstBus]      rdata
);

    // need modification for competing with LOAD/STORE
    always @ (*) begin
        raddr = pc_i;
    end

    always @ (*) begin
        if (rst) begin
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

endmodule