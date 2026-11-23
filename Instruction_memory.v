
module instruction_memory(
    input  [31:0] A,
    input         rst,
    output [31:0] RD
);

    reg [31:0] memory [0:1023];
    integer i;

    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'h00000013;

        $readmemh("program.hex", memory);
    end

    // Active-low reset
    assign RD = (rst == 1'b0) ? 32'h00000013 :
                (A[31:12] == 20'd0) ? memory[A[11:2]] :
                32'h00000013;

endmodule
