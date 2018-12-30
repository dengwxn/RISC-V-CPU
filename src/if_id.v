`include "defines.v"

module if_id (
    input   wire                clk,
    input   wire                rst,
    input   wire[`InstAddrBus]  if_pc,
    input   wire[`InstBus]      if_inst,
    output  reg[`InstAddrBus]   id_pc,
    output  reg[`InstBus]       id_inst,
    input   wire                br,

    input   wire[4 : 0]         stall
);

    always @ (posedge clk) begin
        if (rst) begin
            id_pc <= 0;
            id_inst <= 0;
        end else if (!stall[1]) begin
            if (!br) begin
                id_pc <= if_pc;
                id_inst <= if_inst;
            end else begin
                id_pc <= 0;
                id_inst <= 0;
            end
        end
    end

endmodule