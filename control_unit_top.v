module control_unit_top(
    input      [31:0] instruction,
    input      [6:0]  opcode,
    input      [2:0]  funct3,
    input      [6:0]  funct7,
    input             Branch_Taken,
    output            PC_Src,
    output     [1:0]  Result_Src,
    output            Mem_Write,
    output            ALU_Src,
    output     [2:0]  ImmSrc,
    output            Reg_Write,
    output            Branch,
    output            Jump,
    output            Illegal_Instruction,
    output     [3:0]  ALU_CONTROL
);

    wire [1:0] ALU_OP;
    wire [1:0] main_result_src;
    wire [2:0] main_imm_src;
    wire [3:0] raw_alu_control;
    wire main_mem_write;
    wire main_alu_src;
    wire main_reg_write;
    wire main_branch;
    wire main_jump;
    wire main_illegal;
    wire alu_illegal;

    main_decoder md(
        .instruction(instruction),
        .opcode(opcode),
        .Result_Src(main_result_src),
        .Mem_Write(main_mem_write),
        .ALU_Src(main_alu_src),
        .ImmSrc(main_imm_src),
        .Reg_Write(main_reg_write),
        .ALU_OP(ALU_OP),
        .Branch(main_branch),
        .Jump(main_jump),
        .Illegal_Instruction(main_illegal)
    );

    alu_decoder ad(
        .instruction(instruction),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .op5(funct7[5]),
        .ALU_OP(ALU_OP),
        .ALU_CONTROL(raw_alu_control),
        .Illegal_Instruction(alu_illegal)
    );

    assign Illegal_Instruction = main_illegal | alu_illegal;

    assign Result_Src = Illegal_Instruction ? 2'b00 : main_result_src;
    assign ImmSrc = Illegal_Instruction ? 3'b000 : main_imm_src;
    assign ALU_CONTROL = Illegal_Instruction ? 4'b0000 : raw_alu_control;

    assign Reg_Write = Illegal_Instruction ? 1'b0 : main_reg_write;
    assign Mem_Write = Illegal_Instruction ? 1'b0 : main_mem_write;
    assign ALU_Src = Illegal_Instruction ? 1'b0 : main_alu_src;
    assign Branch = Illegal_Instruction ? 1'b0 : main_branch;
    assign Jump = Illegal_Instruction ? 1'b0 : main_jump;

    assign PC_Src = Illegal_Instruction ? 1'b0 :
                    (main_jump | (main_branch && Branch_Taken));
endmodule
