module data_memory(WE,A,WD,clk,rst,RD);
input clk,rst,WE;
input [31:0] A,WD;
output [31:0] RD;
reg [31:0] data_mem [1023:0];
 
assign RD= (WE==1'b0) ? 32'h00000000 : data_mem[A];

always @(posedge clk)
begin
    if(WE)
    begin
        data_mem[A]<=WD;
    end
end
endmodule