//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_CE,
									Mem_UB,
									Mem_LB,
									Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  Halted, 
						PauseIR1, 
						PauseIR2, 
						S_18, 
						S_33_1, 
						S_33_2, 
						S_35, 
						S_32, 
						S_01,
						S_05,
						S_09,
						S_06,
						S_25_1,
						S_25_2,
						S_27,
						S_07,
						S_23,
						S_16_1,
						S_16_2,
						S_00,
						S_22,
						S_12,
						S_04,
						S_21}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b1;
		Mem_WE = 1'b1;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_2;
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001 : 
						Next_state = S_01;	//ADD
					4'b0101 : 
						Next_state = S_05;	//AND
					4'b1001 : 
						Next_state = S_09;	//NOT
					4'b0110 : 
						Next_state = S_06;	//LDR	
					4'b0111 : 
						Next_state = S_07;	//STR
					4'b0100 : 
						Next_state = S_04;	//JSR
					4'b1100 : 
						Next_state = S_12;	//JMP
					4'b0000 : 
						Next_state = S_00;	//BR
					4'b1101 :
						Next_state = PauseIR1;
					// You need to finish the rest of opcodes.....

					default : 
						Next_state = S_18;
				endcase
			S_01 : 			//ADD
				Next_state = S_18; 		

			// ADDED STATES : TODO FIX BRANCH (S_00, S_22), next states depends on some input idk
			S_05:				//AND
				Next_state = S_18;
				
			S_09:				//NOT
				Next_state = S_18;
			
			S_06:				//LDR
				Next_state = S_25_1;
			
			S_25_1:
				Next_state = S_25_2;
			
			S_25_2:
				Next_state = S_27;
			
			S_27:
				Next_state = S_18;
				
			S_07:				//STR 
				Next_state = S_23;
				
			S_23:
				Next_state = S_16_1;
				
			S_16_1:
				Next_state = S_16_2;
			
			S_16_2:
				Next_state = S_18;
			
			S_00:				//BR
				case (BEN)
					1'b0 : 
						Next_state = S_18;
					1'b1 : 
						Next_state = S_22;
				endcase
			
			S_22:
				Next_state = S_18;

			S_12:				//JMP
				Next_state = S_18;	
				
			S_04:				//JSR
				Next_state = S_21;
			
			S_21:
				Next_state = S_18;
			
			default : ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1 : 
				Mem_OE = 1'b0;
			S_33_2 : 
				begin 
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1:
				LD_LED = 1'b1;
			PauseIR2: ;
			S_32 : 
				LD_BEN = 1'b1;
			S_01 : 
				begin 
					SR2MUX = IR_5;
					SR1MUX = 1'b1;
					ALUK = 2'b00;
					GateALU = 1'b1;
					DRMUX = 1'b0;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
					// incomplete...complete??
				end

			// NEW STATES
			S_05:				//AND
				begin 
					SR2MUX = IR_5;
					SR1MUX = 1'b1;
					ALUK = 2'b01;
					DRMUX = 1'b0;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_09:				//NOT
				begin 
					SR1MUX = 1'b1;
					ALUK = 2'b10;
					DRMUX = 1'b0;
					GateALU = 1'b1;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
			
			S_06:				//LDR
				begin 
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
			
			S_25_1:
				Mem_OE = 1'b0;
			
			S_25_2:  begin
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			
			S_27: 
				begin
					GateMDR = 1'b1;
					DRMUX = 1'b0;
					LD_REG = 1'b1;
					LD_CC = 1'b1;
				end
				
			S_07:				//STR 
				begin 
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b01;
					GateMARMUX = 1'b1;
					LD_MAR = 1'b1;
				end
				
			S_23:
				begin
					SR1MUX = 1'b0;
					ALUK = 2'b11;
					GateALU = 1'b1;
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
				
			S_16_1:
				Mem_WE = 1'b0;
			
			S_16_2:
				Mem_WE = 1'b0;
				
			S_00:	;			//BR
			
			S_22:
				begin
					ADDR2MUX = 2'b01;
					ADDR1MUX = 1'b0;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
			
			S_12:				//JMP
				begin
					SR1MUX = 1'b1;
					ADDR1MUX = 1'b1;
					ADDR2MUX = 2'b00;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
			S_04:				//JSR
				begin 
					GatePC = 1'b1;
					DRMUX = 1'b1;
					LD_REG = 1'b1;
				end
			
			S_21:
				begin
					ADDR1MUX = 1'b0;
					ADDR2MUX = 2'b11;
					PCMUX = 2'b10;
					LD_PC = 1'b1;
				end
				
			default : ;
		endcase
	end 

	 // These should always be active
	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule
