module single_cycle_top(input clk, input rst);
    wire [31:0] PC, PC_Next, PC_Plus4, PC_Target;
    wire [31:0] instruction;
    wire [31:0] RD1, RD2, ImmExt, ALU_InA, ALU_InB, ALU_Result, MemRead, LoadData;
    wire [31:0] WriteBack;
    wire [1:0] Result_Src;
    wire [2:0] ImmSrc;
    wire [3:0] ALU_Control;
    wire ALU_Src, Mem_Write, Reg_Write, Branch, Jump, PC_Src;
    wire zero, Illegal_Instruction;
    reg branch_taken;

    assign PC_Plus4 = PC + 32'd4;

    PC pc(.PC_Next(PC_Next), .clk(clk), .reset(rst), .PC(PC));

    instruction_memory imem(.A(PC), .rst(rst), .RD(instruction));

    register_file rf(
        .A1(instruction[19:15]), .A2(instruction[24:20]),
        .A3(instruction[11:7]), .WD3(WriteBack),
        .WE3(Reg_Write), .clk(clk), .rst(rst),
        .RD1(RD1), .RD2(RD2)
    );

    sign_extend sext(.In(instruction), .ImmSrc(ImmSrc), .Immext(ImmExt));

    control_unit_top control(
        .instruction(instruction),
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .Branch_Taken(branch_taken),
        .PC_Src(PC_Src),
        .Result_Src(Result_Src),
        .Mem_Write(Mem_Write),
        .ALU_Src(ALU_Src),
        .ImmSrc(ImmSrc),
        .Reg_Write(Reg_Write),
        .Branch(Branch),
        .Jump(Jump),
        .ALU_CONTROL(ALU_Control),
        .Illegal_Instruction(Illegal_Instruction)
    );

    assign ALU_InA = (instruction[6:0] == 7'b0110111) ? 32'd0 :
                     (instruction[6:0] == 7'b0010111) ? PC : RD1;
    assign ALU_InB = ALU_Src ? ImmExt : RD2;

    ALU alu(.A(ALU_InA), .B(ALU_InB), .ALU_CONTROL(ALU_Control),
            .ALU_OUT(ALU_Result), .zero(zero), .carry(),
            .overflow(), .negative());

    data_memory dmem(
        .WE(Mem_Write), .A(ALU_Result), .WD(RD2),
        .funct3(instruction[14:12]), .clk(clk), .rst(rst),
        .RD(MemRead)
    );

    assign LoadData = (instruction[14:12] == 3'b000) ?
                      {{24{MemRead[7]}}, MemRead[7:0]} :
                      (instruction[14:12] == 3'b001) ?
                      {{16{MemRead[15]}}, MemRead[15:0]} :
                      (instruction[14:12] == 3'b100) ? {24'd0, MemRead[7:0]} :
                      (instruction[14:12] == 3'b101) ? {16'd0, MemRead[15:0]} : MemRead;

    assign WriteBack = (Result_Src == 2'b01) ? LoadData :
                       (Result_Src == 2'b10) ? PC_Plus4 : ALU_Result;

    always @(*) begin
        branch_taken = 1'b0;
        if (Branch) begin
            case (instruction[14:12])
                3'b000: branch_taken = (RD1 == RD2);
                3'b001: branch_taken = (RD1 != RD2);
                3'b100: branch_taken = ($signed(RD1) < $signed(RD2));
                3'b101: branch_taken = ($signed(RD1) >= $signed(RD2));
                3'b110: branch_taken = (RD1 < RD2);
                3'b111: branch_taken = (RD1 >= RD2);
                default: branch_taken = 1'b0;
            endcase
        end
    end

    assign PC_Target = ((instruction[6:0] == 7'b1100111) ? RD1 : PC) + ImmExt;

    assign PC_Next = Illegal_Instruction ? PC_Plus4 :
                     PC_Src ? ((instruction[6:0] == 7'b1100111) ?
                                {PC_Target[31:1], 1'b0} :
                                PC_Target) :
                     PC_Plus4;
endmodule
