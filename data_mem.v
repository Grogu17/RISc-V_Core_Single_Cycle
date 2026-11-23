module data_memory(WE,A,WD,funct3,clk,rst,RD);
    input clk,rst,WE;
    input [31:0] A,WD;
    input [2:0] funct3;
    output reg [31:0] RD;

    reg [31:0] data_mem [0:1023];
    integer i;

    wire in_range = (A[31:12] == 20'd0);
    wire valid_alignment =
        ((funct3 == 3'b000) || (funct3 == 3'b100)) ||
        (((funct3 == 3'b001) || (funct3 == 3'b101)) && (A[0] == 1'b0)) ||
        ((funct3 == 3'b010) && (A[1:0] == 2'b00));

    always @(*) begin
        RD = 32'd0;

        if (rst && in_range && valid_alignment) begin
            case (funct3)
                3'b000: begin // LB
                    case (A[1:0])
                        2'b00: RD = {{24{data_mem[A[11:2]][7]}},
                                     data_mem[A[11:2]][7:0]};
                        2'b01: RD = {{24{data_mem[A[11:2]][15]}},
                                     data_mem[A[11:2]][15:8]};
                        2'b10: RD = {{24{data_mem[A[11:2]][23]}},
                                     data_mem[A[11:2]][23:16]};
                        2'b11: RD = {{24{data_mem[A[11:2]][31]}},
                                     data_mem[A[11:2]][31:24]};
                    endcase
                end

                3'b001: begin // LH
                    if (A[1])
                        RD = {{16{data_mem[A[11:2]][31]}},
                              data_mem[A[11:2]][31:16]};
                    else
                        RD = {{16{data_mem[A[11:2]][15]}},
                              data_mem[A[11:2]][15:0]};
                end

                3'b100: begin // LBU
                    case (A[1:0])
                        2'b00: RD = {24'd0, data_mem[A[11:2]][7:0]};
                        2'b01: RD = {24'd0, data_mem[A[11:2]][15:8]};
                        2'b10: RD = {24'd0, data_mem[A[11:2]][23:16]};
                        2'b11: RD = {24'd0, data_mem[A[11:2]][31:24]};
                    endcase
                end

                3'b101: begin // LHU
                    if (A[1])
                        RD = {16'd0, data_mem[A[11:2]][31:16]};
                    else
                        RD = {16'd0, data_mem[A[11:2]][15:0]};
                end

                3'b010: begin // LW
                    RD = data_mem[A[11:2]];
                end

                default: RD = 32'd0;
            endcase
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 1024; i = i + 1)
                data_mem[i] <= 32'd0;
        end else if (WE && in_range && valid_alignment) begin
            case (funct3)
                3'b000: begin // SB
                    case (A[1:0])
                        2'b00: data_mem[A[11:2]][7:0]   <= WD[7:0];
                        2'b01: data_mem[A[11:2]][15:8]  <= WD[7:0];
                        2'b10: data_mem[A[11:2]][23:16] <= WD[7:0];
                        2'b11: data_mem[A[11:2]][31:24] <= WD[7:0];
                    endcase
                end

                3'b001: begin // SH
                    if (A[1])
                        data_mem[A[11:2]][31:16] <= WD[15:0];
                    else
                        data_mem[A[11:2]][15:0] <= WD[15:0];
                end

                3'b010: begin // SW
                    data_mem[A[11:2]] <= WD;
                end

                default: begin
                    // Invalid store funct3: no memory modification.
                end
            endcase
        end
    end
endmodule