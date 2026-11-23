module alu_decoder(
    input      [31:0] instruction,
    input      [6:0]  opcode,
    input      [2:0]  funct3,
    input      [6:0]  funct7,
    input             op5,
    input      [1:0]  ALU_OP,
    output reg [3:0]  ALU_CONTROL,
    output reg        Illegal_Instruction
);

    wire [4:0] shamt = instruction[24:20];

    always @(*) begin
        ALU_CONTROL = 4'b0000;
        Illegal_Instruction = 1'b0;

        case (ALU_OP)
            2'b00: begin
                // Loads, stores, LUI and AUIPC use ADD or top-level
                // datapath operand selection; neither decoder field is illegal.
                ALU_CONTROL = 4'b0000;
            end

            2'b01: begin
                // Branch instructions use the branch comparison in the
                // top-level datapath. The ALU decoder only validates funct3.
                if (opcode != 7'b1100011)
                    Illegal_Instruction = 1'b1;
                else begin
                    case (funct3)
                        3'b000, 3'b001,
                        3'b100, 3'b101,
                        3'b110, 3'b111:
                            Illegal_Instruction = 1'b0;
                        default:
                            Illegal_Instruction = 1'b1;
                    endcase
                end

                ALU_CONTROL = 4'b0001;
                if (Illegal_Instruction)
                    ALU_CONTROL = 4'b0000;
            end

            2'b10: begin
                if (opcode == 7'b0110011) begin
                    case (funct3)
                        3'b000: begin // ADD/SUB
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0000;
                            else if (funct7 == 7'b0100000)
                                ALU_CONTROL = 4'b0001;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b001: begin // SLL
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0101;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b010: begin // SLT
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b1000;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b011: begin // SLTU
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b1001;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b100: begin // XOR
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0100;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b101: begin // SRL/SRA
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0110;
                            else if (funct7 == 7'b0100000)
                                ALU_CONTROL = 4'b0111;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b110: begin // OR
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0011;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b111: begin // AND
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0010;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        default:
                            Illegal_Instruction = 1'b1;
                    endcase

                end else if (opcode == 7'b0010011) begin
                    case (funct3)
                        3'b000: ALU_CONTROL = 4'b0000; // ADDI
                        3'b010: ALU_CONTROL = 4'b1000; // SLTI
                        3'b011: ALU_CONTROL = 4'b1001; // SLTIU
                        3'b100: ALU_CONTROL = 4'b0100; // XORI
                        3'b110: ALU_CONTROL = 4'b0011; // ORI
                        3'b111: ALU_CONTROL = 4'b0010; // ANDI

                        3'b001: begin // SLLI
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0101;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        3'b101: begin // SRLI/SRAI
                            if (funct7 == 7'b0000000)
                                ALU_CONTROL = 4'b0110;
                            else if (funct7 == 7'b0100000)
                                ALU_CONTROL = 4'b0111;
                            else
                                Illegal_Instruction = 1'b1;
                        end

                        default:
                            Illegal_Instruction = 1'b1;
                    endcase

                    // RV32I I-type shifts have a five-bit shamt field.
                    if ((funct3 == 3'b001 || funct3 == 3'b101) &&
                        shamt > 5'd31)
                        Illegal_Instruction = 1'b1;

                end else begin
                    Illegal_Instruction = 1'b1;
                end

                if (Illegal_Instruction)
                    ALU_CONTROL = 4'b0000;
            end

            default: begin
                Illegal_Instruction = 1'b1;
                ALU_CONTROL = 4'b0000;
            end
        endcase

        // op5 is preserved as a legacy input for compatibility with existing
        // decoder integrations. Exact validation uses opcode/funct7.
    end
endmodule