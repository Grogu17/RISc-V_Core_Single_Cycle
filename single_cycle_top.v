`include "PC.v"
`include "alu.v"
`include "alu_decoder.v"
`include "data_mem.v"
`include "Instruction_memory.v"
`include "register_file.v"
`include "sign_extend.v"

module single_cycle_top(rst,clk);

input clk, rst;
wire [31:0] PC_Top, RD_Instr,RD1_Top,Imm_ext_top;

PC pc(.PC_Next(),
      .clk(clk),
      .reset(rst),
      .PC(PC_Top));

Instruction_memory Instmem(.A(PC_Top),
                           .rst(rst),
                           .RD(RD_Instr));

register_file rf(.A1(RD_Instr[19:15]),
                 .A2(),
                 .A3(),
                 .WD3(),
                 .WE3(),
                 .clk(clk),
                 .rst(rst),
                 .RD1(RD1_Top),
                 .RD2());

sign_extend se(.In(RD_Instr),
               .Immext(Imm_ext_top));

alu ALU(.A(RD1_Top),
        .B(Imm_ext_top),
        .ALU_CONTROL(),
        .ALU_OUT(),
        .zero(),
        .carry(),
        .overflow(),
        .negative());

main_decoder md(zero,opcode,PC_Src,Result_Src,Mem_write,ALU_Src,ImmSrc,Reg_Write,ALU_OP);

endmodule