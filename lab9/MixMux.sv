module MixMux (

input logic    [31:0]W1,
input logic   [63:32]W2,
input logic   [95:64]W3,
input logic  [127:96]W4,
input logic [1:0]MixColNum,
output logic [31:0]MixMuxOut
);

always_comb begin

if(MixColNum == 0) begin

MixMuxOut = W1;
	end
else if(MixColNum == 2'b01) begin

MixMuxOut = W2;
	end

else if (MixColNum == 2'b10) begin

MixMuxOut = W3;

	end

else begin

MixMuxOut = W4;

	end
end

endmodule 