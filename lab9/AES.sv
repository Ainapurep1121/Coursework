/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AES (
	input	 logic CLK,
	input  logic RESET,
	input  logic AES_START,
	output logic AES_DONE,
	input  logic [127:0] AES_KEY,
	input  logic [127:0] AES_MSG_ENC,
	output logic [127:0] AES_MSG_DEC,
	output logic [1:0] DataMuxSelect,
	output logic [1:0] MixColNum,
	output logic LD_REG,
	output logic [3:0] LoopCount
);

enum logic [3:0] {  Wait, 
						KeyExpansion, 
						AddRoundKey, 
						InvShiftRowsLoop, 
						InvSubBytesLoop1,
						InvSubBytesLoop2,	
						AddRoundKeyLoop, 
						InvMixColLoop1,
						InvMixColLoop2,
						InvMixColLoop3,
						InvMixColLoop4,
						InvShiftRowsLast,
						InvSubBytesLast,
						AddRoundKeyLast
						Halt } State, Next_State;
	
	logic [4:0] KeyWait;
						
	always_ff @ (posedge CLK)
	begin
		if (RESET) 
			State <= Wait;
		else 
			State <= Next_State;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		AES_DONE = 1'b0;
		AES_MSG_DEC = AES_MSG_ENC;
		LoopCount = 4'h0;
		KeyWait = 5'b0;
		LD_REG = 1'b0;
		MixColNum = 2'b0;
		DataMuxSelect = 2'b0;
		LoopCount = 4'b0;
		
		unique case (State)				
			Wait : 
				if (AES_START)
					Next_State = KeyExpansion;
			
			KeyExpansion: begin 
				if (KeyWait < 20)
					Next_State = KeyExpansion;
				else 
					Next_State = AddRoundKey;
			end 
			
			AddRoundKey:
				Next_State = InvShiftRowsLoop;
			
			InvShiftRowsLoop:
				Next_State = InvSubBytesLoop1;
				
			InvSubBytesLoop1:
				Next_State = InvSubBytesLoop2;
				
			InvSubBytesLoop2:	
				Next_State = AddRoundKeyLoop;
				
			AddRoundKeyLoop:
				Next_State = InvMixColLoop1;
				
			InvMixColLoop1:
				Next_State = InvMixColLoop2;
				
			InvMixColLoop2:
				Next_State = InvMixColLoop3;
				
			InvMixColLoop3:
				Next_State = InvMixColLoop4;
				
			InvMixColLoop4: begin 
				if (LoopCount < 9)
					Next_State = InvShiftRowsLoop;
				else
					Next_State = InvShiftRowsLast;
			end
				
			InvShiftRowsLast:
				Next_State = InvSubBytesLast;
			
			InvSubBytesLast:
				Next_State = AddRoundKeyLast;
				
			AddRoundKeyLast:
				Next_State = Halt;
				
			Halt:
				Next_State = Wait;
				
			default : 
				Next_State = Wait;
				
		endcase
		
		case (State)
			Wait: begin 
				LoopCount = 0;
				KeyWait = 0;
			end
			
			KeyExpansion: begin
				if (KeyWait < 20)
					KeyWait++;
				else 
					KeyWait = 5'b0;
			end
			
			AddRoundKey:
				DataMuxSelect = 2'b10;
		
			InvShiftRowsLoop:
				DataMuxSelect = 2'b0;
			
			InvSubBytesLoop1: begin
				LoopCount++;
				DataMuxSelect = 2'b01;
			end 
			
			InvSubBytesLoop2: ;
			
			AddRoundKeyLoop:
				DataMuxSelect = 2'b10;
			
			InvMixColLoop1: begin
				MixColNum = 2'b00;
				DataMuxSelect = 2'b11;
			end
			
			InvMixColLoop2: begin
				MixColNum = 2'b01;
				DataMuxSelect = 2'b11;
			end
			
			InvMixColLoop3: begin
				MixColNum = 2'b10;
				DataMuxSelect = 2'b11;
			end
			
			InvMixColLoop4: begin
				MixColNum = 2'b11;
				DataMuxSelect = 2'b11;
			end
			
			InvShiftRowsLast: begin
				DataMuxSelect = 2'b0;
				LoopCount++;
			end
			
			InvSubBytesLast:
				DataMuxSelect = 2'b01;
				
			AddRoundKeyLast:
				DataMuxSelect = 2'b10;
				
			Halt: 
				AES_DONE = 1;
				
			default: ;
			
		endcase
		
endmodule
