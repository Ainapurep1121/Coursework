
module AddRoundkey (
input logic [127:0]key,
input logic [127:0] Rkey,
output logic [127:0] KeyNext
);

always_comb begin
KeyNext[7:0]     = key[7:0]     ^  Rkey[7:0]     ;
KeyNext[15:8]    = key[15:8]    ^  Rkey[15:8]    ;
KeyNext[23:16]   = key[23:16]   ^  Rkey[23:16]   ;
KeyNext[31:24]   = key[31:24]   ^  Rkey[31:24]   ;
KeyNext[39:32]   = key[39:32]   ^  Rkey[39:32]   ;
KeyNext[47:40]   = key[47:40]   ^  Rkey[47:40]   ;
KeyNext[55:48]   = key[55:48]   ^  Rkey[55:48]   ;
KeyNext[63:56]   = key[63:56]   ^  Rkey[63:56]   ;
KeyNext[71:64]   = key[71:64]   ^  Rkey[71:64]   ;
KeyNext[79:72]   = key[79:72]   ^  Rkey[79:72]   ;
KeyNext[87:80]   = key[87:80]   ^  Rkey[87:80]   ;
KeyNext[95:88]   = key[95:88]   ^  Rkey[95:88]   ;
KeyNext[103:96]  = key[103:96]  ^  Rkey[103:96]  ;
KeyNext[111:104] = key[111:104] ^  Rkey[111:104] ;
KeyNext[119:112] = key[119:112] ^  Rkey[119:112] ;
KeyNext[127:120] = key[127:120] ^  Rkey[127:120] ;

end


endmodule
