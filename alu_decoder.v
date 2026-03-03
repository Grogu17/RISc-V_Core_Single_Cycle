module alu_decoder(func_3,func_7,op5,ALU_OP,ALU_CONTROL);
input [2:0] func_3;
input func_7,op5;
output [3:0]ALU_CONTROL;

wire [1:0] concatenation;

assign concatenation={op5,func_7};
assign ALU_CONTROL=(ALU_OP==2'b00)? 4'b0000:
                   (ALU_OP==2'b01)? 4'b0001:
                   (ALU_OP == 2'b10 && func_3 == 3'b000 && concatenation == 2'b11) ? 4'b0001 :
                   (ALU_OP == 2'b10 && func_3 == 3'b000) ? 4'b0000 : // ADD / ADDI
                   (ALU_OP == 2'b10 && func_3 == 3'b111) ? 4'b0010 : // AND
                   (ALU_OP == 2'b10 && func_3 == 3'b110) ? 4'b0011 : // OR
                   (ALU_OP == 2'b10 && func_3 == 3'b100) ? 4'b0100 : // XO
                   (ALU_OP == 2'b10 && func_3 == 3'b010) ? 4'b0101 : // SLT
                   (ALU_OP == 2'b10 && func_3 == 3'b001) ? 4'b0110 : // SLL
                   (ALU_OP == 2'b10 && func_3 == 3'b101 && func_7 == 1'b0) ? 4'b0111 : // SRL
                   (ALU_OP == 2'b10 && func_3 == 3'b101 && func_7 == 1'b1) ? 4'b1000 : 4'b0000;
endmodule