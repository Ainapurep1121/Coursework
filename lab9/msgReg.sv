module MsgReg (

input logic [127:0]Data_In,
input logic CLK,
input logic Reset,
input logic Load,
output logic [127:0]Data_Out
);

always_ff @ (posedge CLK) begin

if(Reset) begin
	Data_Out = 128'h0;
end

else if(Load) begin
	Data_Out = Data_In;
end
else begin
    Data_Out = Data_Out; 
end 

end

endmodule
