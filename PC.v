module PC(PC_Next,clk,reset,PC);
input [31:0] PC_Next;
input clk,reset;
output reg [31:0] PC;
always @(posedge clk)
begin
    if(reset==1'b0)
    PC<=32'h00000000;
    else
    PC<= PC_Next;
end

endmodule