module sign_extend(In,Immext);

input [31:0] In;
output [31:0] Immext;

assign Immext= In[31] ? {{20{1'b1}},In[31:20]} :
                        {{20{1'b0}},In[31:20]} ;

endmodule