`include "defines.v"

module pc_reg (
    input   wire                clk,
    input   wire                rst,
    input   wire[4 : 0]         stall,
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce,

    input   wire                br,
    input   wire[`InstAddrBus]  br_addr,

    input   wire                rdy
);

    reg[`InstAddrBus]   pc_tmp;

    always @ (posedge clk) begin
        if (rst || !rdy) begin
            ce <= 0;
            pc <= 0;
            pc_tmp <= 0;
        end else if (!stall[0]) begin
            ce <= 1;
            if (br) begin
                pc <= br_addr;
                pc_tmp <= br_addr + 4;
            end else begin
                pc <= pc_tmp;
                pc_tmp <= pc_tmp + 4;
            end
        end
    end

endmodule