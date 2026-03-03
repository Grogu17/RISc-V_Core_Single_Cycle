module main_decoder(zero,opcode,PC_Src,Result_Src,Mem_write,ALU_Src,ImmSrc,Reg_Write,ALU_OP);
input zero;
input [6:0] opcode;
output PC_Src,Result_Src,Mem_write,ALU_Src,Reg_Write;
output [1:0] ImmSrc,ALU_OP;
wire branch;
assign branch=(opcode==7'b1100011) ? 1'b1 : 1'b0;
assign Result_Src=(opcode==7'b0000011) ? 1'b1 : 1'b0;
assign Mem_write= (opcode==7'b0100011) ? 1'b1 : 1'b0;
assign ALU_Src= (opcode==7'b0000011 || opcode==7'b0100011) ? 1'b1:1'b0;
assign ImmSrc= (opcode==7'b1100011)? 2'b10 : ((opcode==7'b0100011) ? 2'b01 : 2'b00);
assign Reg_Write=(opcode==7'b0000011 || opcode==7'b0110011)? 1'b1 : 1'b0;
assign PC_Src= zero & branch;
assign ALU_OP=(opcode==7'b0110011)? 2'b10 : ((opcode==7'b1100011) ? 2'b01 : 2'b00);
endmodule