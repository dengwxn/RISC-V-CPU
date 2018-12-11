`include "defines.v"

module pc_reg (
    input   wire                clk,
    input   wire                rst,
    input   wire[4 : 0]         stall,
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce,

    input   wire                br,
    input   wire[`InstAddrBus]  br_addr
);

    always @ (posedge clk) begin
        if (rst) begin
            ce <= 0;
        end else begin
            ce <= 1;
		end
    end

    always @ (posedge clk) begin
        if (rst) begin
            pc <= 0;
        end if (!stall[0]) begin
            if (br) begin
                pc <= br_addr;
            end else begin
                pc <= pc + 4;
            end
        end
    end

endmodule