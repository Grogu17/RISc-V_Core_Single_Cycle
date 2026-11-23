module ALU(
    input  [31:0] A,
    input  [31:0] B,
    input  [3:0]  ALU_CONTROL,
    output reg [31:0] ALU_OUT,
    output zero,
    output carry,
    output overflow,
    output negative
);

    wire [32:0] add_ext = {1'b0, A} + {1'b0, B};
    wire [32:0] sub_ext = {1'b0, A} - {1'b0, B};

    always @(*) begin
        case (ALU_CONTROL)
            4'b0000: ALU_OUT = A + B;
            4'b0001: ALU_OUT = A - B;
            4'b0010: ALU_OUT = A & B;
            4'b0011: ALU_OUT = A | B;
            4'b0100: ALU_OUT = A ^ B;
            4'b0101: ALU_OUT = A << B[4:0];
            4'b0110: ALU_OUT = A >> B[4:0];
            4'b0111: ALU_OUT = $signed(A) >>> B[4:0];
            4'b1000: ALU_OUT = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            4'b1001: ALU_OUT = (A < B) ? 32'd1 : 32'd0;
            default: ALU_OUT = 32'd0;
        endcase
    end

    assign zero = (ALU_OUT == 32'd0);
    assign carry = (ALU_CONTROL == 4'b0000) ? add_ext[32] :
                   (ALU_CONTROL == 4'b0001) ? ~sub_ext[32] : 1'b0;
    assign negative = ALU_OUT[31];
    assign overflow = (ALU_CONTROL == 4'b0000) ?
                      ((~A[31] & ~B[31] & ALU_OUT[31]) | (A[31] & B[31] & ~ALU_OUT[31])) :
                      (ALU_CONTROL == 4'b0001) ?
                      ((A[31] & ~B[31] & ~ALU_OUT[31]) | (~A[31] & B[31] & ALU_OUT[31])) : 1'b0;
endmodule