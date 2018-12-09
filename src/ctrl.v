module ctrl (
    input   wire        rst,
    input   wire        if_stallreq,
    output  reg[4 : 0]  stall
);

    always @ (*) begin
        if (rst) begin
            stall <= 5'b00000;
        end else if (if_stallreq) begin
            stall <= 5'b00011;
        end else begin
            stall <= 5'b00000;
        end
    end

endmodule