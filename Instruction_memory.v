module instruction_memory(A,rst,RD);
input [31:0] A;
input rst;
reg [31:0] memory [1023:0];
output [31:0] RD;

assign RD = (rst==1'b0) ? 32'h00000000 : memory[A[31:2]] ;

endmodule