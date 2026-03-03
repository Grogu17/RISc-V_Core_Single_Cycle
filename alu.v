module ALU(input [31:0]A, input [31:0]B, input [3:0]ALU_CONTROL, output[31:0]ALU_OUT,output zero,output carry,output overflow,output negative);
wire [31:0]a_and_b;
wire [31:0]a_or_b;
wire [31:0]not_a;
wire [31:0]not_b;
wire [31:0]a_add_b;
wire [31:0]a_subtract_b;
wire [31:0]a_xor_b;
wire [31:0]sll;
wire [31:0]srl;
wire [31:0]sra;
wire [31:0]slt;
wire [31:0]sltu;
reg [31:0] result;
wire cout;
assign not_b=~B;
assign {cout,a_add_b}=A+B;
assign a_subtract_b=A+not_b+1;
assign a_and_b=A&B;
assign a_or_b=A|B;
assign a_xor_b =A ^B;
assign sll=A<<B[4:0];
assign srl = A >> B[4:0];
assign sra = $signed(A) >>> B[4:0];
assign slt = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
assign sltu = (A < B) ? 32'd1 : 32'd0;
always @(*)
begin
    case(ALU_CONTROL)
        4'b0000: result = a_add_b;
        4'b0001: result = a_subtract_b;
        4'b0010: result = a_and_b;
        4'b0011: result = a_or_b;
        4'b0100: result = a_xor_b;
        4'b0101: result = sll;
        4'b0110: result = srl;
        4'b0111: result = sra;
        4'b1000: result = slt;
        4'b1001: result = sltu;
        default: result = 32'b0;
    endcase
end 

assign ALU_OUT=result;

// flags 
assign carry=cout;
assign zero=&(~ALU_OUT);
assign negative=ALU_OUT[31];
assign overflow=(ALU_CONTROL == 4'b0000) ?
        ((A[31] & B[31] & ~result[31]) |
         (~A[31] & ~B[31] & result[31])) :
         (ALU_CONTROL == 4'b0001) ?
        ((A[31] & ~B[31] & ~result[31]) |
         (~A[31] & B[31] & result[31])) : 1'b0;
endmodule