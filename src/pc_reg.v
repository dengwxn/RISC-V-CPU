module pc_reg (
    input   wire                clk,
    input   wire                rst,
    output  reg[`InstAddrBus]   pc,
    output  reg                 ce
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
        end else begin
            pc <= pc + 4;
        end
    end

endmodule