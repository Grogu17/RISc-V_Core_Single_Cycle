module main_decoder(
    input  [31:0] instruction,
    input  [6:0]  opcode,
    output reg [1:0] Result_Src,
    output reg    Mem_Write,
    output reg    ALU_Src,
    output reg [2:0] ImmSrc,
    output reg    Reg_Write,
    output reg [1:0] ALU_OP,
    output reg    Branch,
    output reg    Jump,
    output reg    Illegal_Instruction
);

    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];

    always @(*) begin
        Result_Src = 2'b00;
        Mem_Write = 1'b0;
        ALU_Src = 1'b0;
        ImmSrc = 3'b000;
        Reg_Write = 1'b0;
        ALU_OP = 2'b00;
        Branch = 1'b0;
        Jump = 1'b0;
        Illegal_Instruction = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                Reg_Write = 1'b1;
                ALU_OP = 2'b10;

                case (funct3)
                    3'b000:
                        Illegal_Instruction =
                            !(funct7 == 7'b0000000 || funct7 == 7'b0100000);
                    3'b001:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    3'b010:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    3'b011:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    3'b100:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    3'b101:
                        Illegal_Instruction =
                            !(funct7 == 7'b0000000 || funct7 == 7'b0100000);
                    3'b110:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    3'b111:
                        Illegal_Instruction = (funct7 != 7'b0000000);
                    default:
                        Illegal_Instruction = 1'b1;
                endcase

                if (Illegal_Instruction) begin
                    Reg_Write = 1'b0;
                    ALU_OP = 2'b00;
                end
            end

            7'b0010011: begin // I-type arithmetic and logic
                ALU_Src = 1'b1;
                ImmSrc = 3'b000;
                ALU_OP = 2'b10;

                case (funct3)
                    3'b000, 3'b010, 3'b011,
                    3'b100, 3'b110, 3'b111:
                        Reg_Write = 1'b1;

                    3'b001: begin // SLLI
                        Illegal_Instruction =
                            (funct7 != 7'b0000000);
                        if (!Illegal_Instruction)
                            Reg_Write = 1'b1;
                    end

                    3'b101: begin // SRLI/SRAI
                        Illegal_Instruction =
                            !(funct7 == 7'b0000000 ||
                              funct7 == 7'b0100000);
                        if (!Illegal_Instruction)
                            Reg_Write = 1'b1;
                    end

                    default:
                        Illegal_Instruction = 1'b1;
                endcase

                if (Illegal_Instruction) begin
                    ALU_Src = 1'b0;
                    ALU_OP = 2'b00;
                end
            end

            7'b0000011: begin // Loads
                ALU_Src = 1'b1;
                ImmSrc = 3'b000;
                Result_Src = 2'b01;

                case (funct3)
                    3'b000, 3'b001, 3'b010,
                    3'b100, 3'b101:
                        Reg_Write = 1'b1;
                    default:
                        Illegal_Instruction = 1'b1;
                endcase

                if (Illegal_Instruction)
                    Result_Src = 2'b00;
            end

            7'b0100011: begin // Stores
                ALU_Src = 1'b1;
                ImmSrc = 3'b001;

                case (funct3)
                    3'b000, 3'b001, 3'b010:
                        Mem_Write = 1'b1;
                    default:
                        Illegal_Instruction = 1'b1;
                endcase

                if (Illegal_Instruction)
                    ALU_Src = 1'b0;
            end

            7'b1100011: begin // Branches
                ImmSrc = 3'b010;
                ALU_OP = 2'b01;

                case (funct3)
                    3'b000, 3'b001, 3'b100,
                    3'b101, 3'b110, 3'b111:
                        Branch = 1'b1;
                    default:
                        Illegal_Instruction = 1'b1;
                endcase

                if (Illegal_Instruction) begin
                    Branch = 1'b0;
                    ALU_OP = 2'b00;
                    ImmSrc = 3'b000;
                end
            end

            7'b1101111: begin // JAL
                Reg_Write = 1'b1;
                Result_Src = 2'b10;
                ImmSrc = 3'b100;
                Jump = 1'b1;
            end

            7'b1100111: begin // JALR
                if (funct3 == 3'b000) begin
                    Reg_Write = 1'b1;
                    ALU_Src = 1'b1;
                    ImmSrc = 3'b000;
                    Result_Src = 2'b10;
                    Jump = 1'b1;
                end else begin
                    Illegal_Instruction = 1'b1;
                end
            end

            7'b0110111: begin // LUI
                ALU_Src = 1'b1;
                ImmSrc = 3'b011;
                Reg_Write = 1'b1;
            end

            7'b0010111: begin // AUIPC
                ALU_Src = 1'b1;
                ImmSrc = 3'b011;
                ALU_OP = 2'b00;
                Reg_Write = 1'b1;
            end

            7'b0001111: begin // FENCE only
                // FENCE.I uses funct3=001 and is reserved for this base core.
                // Valid FENCE requires funct3=000, rd=0, rs1=0, and fm=0000.
                if (funct3 == 3'b000 &&
                    instruction[11:7] == 5'b00000 &&
                    instruction[19:15] == 5'b00000 &&
                    instruction[31:28] == 4'b0000)
                    Illegal_Instruction = 1'b0;
                else
                    Illegal_Instruction = 1'b1;

                // FENCE causes no architectural state change.
                Result_Src = 2'b00;
                Mem_Write = 1'b0;
                ALU_Src = 1'b0;
                ImmSrc = 3'b000;
                Reg_Write = 1'b0;
                ALU_OP = 2'b00;
                Branch = 1'b0;
                Jump = 1'b0;
            end

            7'b1110011: begin // ECALL/EBREAK and other SYSTEM encodings
                Illegal_Instruction = 1'b1;
            end

            default:
                Illegal_Instruction = 1'b1;
        endcase

        // Illegal instructions cannot change architectural state or take a jump.
        if (Illegal_Instruction) begin
            Result_Src = 2'b00;
            Mem_Write = 1'b0;
            ALU_Src = 1'b0;
            ImmSrc = 3'b000;
            Reg_Write = 1'b0;
            ALU_OP = 2'b00;
            Branch = 1'b0;
            Jump = 1'b0;
        end
    end
endmodule