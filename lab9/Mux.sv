module mux(
input logic [127:0]InvShiftRows,
input logic [127:0]InvSubBytes,
input logic [127:0]AddRoundKey,
input logic [127:0]InvMixCol,
input logic[1:0]Select,
output logic [127:0] MuxOut
);

always_comb begin

if(Select == 2'b00)      begin

MuxOut = InvShiftRows;

		end
else if (Select == 2'b01) begin

MuxOut = InvSubBytes;
		end

else if (Select == 2'b10) begin

MuxOut = AddRoundKey;
		end

else  begin

MuxOut = InvMixCol;

		end

end

endmodule
