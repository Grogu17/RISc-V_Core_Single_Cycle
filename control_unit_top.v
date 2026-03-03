`include "alu_decoder.v"
`include "main_decoder.v"

module control_unit_top(zero,opcode,Result_Src,Mem_write,ALU_Src,ImmSrc,Reg_Write,branch,func_7,func_3,ALU_CONTROL);

input [6:0] opcode,func_7;
input [2:0] func_3;
output Reg_Write,ALU_Src,Mem_write,Result_Src,branch;
output [1:0] ImmSrc;
output [3:0] ALU_CONTROL;

wire [1:0] ALU_OP;

main_decoder md(.zero(zero),
                .opcode(opcode),
                .PC_Src(PC_Src),
                .branch(branch),
                .Result_Src(Result_Src),
                .Mem_write(Mem_write),
                .ALU_Src(ALU_Src),
                .ImmSrc(ImmSrc),
                .Reg_Write(Reg_Write),
                .ALU_OP(ALU_OP));

alu_decoder ald(.func_3(func_3),
                .func_7(func_7),
                .op5(op5),
                .ALU_OP(),
                .ALU_CONTROL());
endmodule
