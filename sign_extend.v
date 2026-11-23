module sign_extend(In, ImmSrc, Immext);

input  [31:0] In;
input  [2:0]  ImmSrc;
output reg [31:0] Immext;

always @(*) begin
    case (ImmSrc)
        3'b000: Immext = {{20{In[31]}}, In[31:20]};                         // I
        3'b001: Immext = {{20{In[31]}}, In[31:25], In[11:7]};             // S
        3'b010: Immext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0}; // B
        3'b011: Immext = {In[31:12], 12'b0};                               // U
        3'b100: Immext = {{11{In[31]}}, In[31], In[19:12], In[20], In[30:21], 1'b0}; // J
        default: Immext = 32'd0;
    endcase
end
endmodule