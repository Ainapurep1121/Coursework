module PC (input logic [15:0] PC_Mux_out,
			  input logic [15:0] PC_curr,
			  input logic Clk, Reset,  
			  input logic LD_PC,
			  output logic [15:0] PC_addr); //Program Counter Register, stores address of next instruction
	
	always_ff @ (posedge Clk)
		begin 
			 if(Reset) begin
					PC_addr <= 16'b0;
			 end
		 
			 else if (LD_PC == 1) begin
					PC_addr <= PC_Mux_out;
			 end
			 
			 else begin
					PC_addr <= PC_curr;
			 end
		end

endmodule 

module PC_Mux (input logic [15:0] PC_curr,
					input logic [15:0] PC_inc,
					input logic [15:0] ADDR_out,
					input logic [15:0] Bus,
					input logic [1:0] PCMUX,
					output logic [15:0] PC_Mux_out);
	//Can we change this to a case statement 

	always_comb
		begin 
			 if(PCMUX == 0) begin
					PC_Mux_out <= (PC_curr + 1);
			 end
		 
			 else if(PCMUX == 1) begin
					PC_Mux_out <= Bus;
			 end
			 
			 else if(PCMUX == 2) begin
					PC_Mux_out <= ADDR_out;
			 end
			 
			 else begin
					PC_Mux_out <= PC_curr;
			 end 
		end
	

endmodule

module MAR (input logic [15:0] Bus,
				input logic Clk, Reset, 
				input logic LD_MAR,
				output logic [15:0] MAR_addr); //Program Counter Register, stores address of next instruction
	
	always_ff @ (posedge Clk)
		begin 
			 if(Reset) begin
					MAR_addr <= 16'b0;
			 end
		 
			 else if (LD_MAR) begin
					MAR_addr <= Bus;
			 end
			 
			 else begin
					MAR_addr <= MAR_addr;
			 end
		end

endmodule 

module MDR (input logic [15:0] MDR_out,
				input logic Clk, Reset, 
				input logic LD_MDR,
				output logic [15:0] MDR_val); //Program Counter Register, stores address of next instruction
	
	always_ff @ (posedge Clk)
		begin 
			 if(Reset) begin
					MDR_val <= 16'b0;
			 end
		 
			 else if (LD_MDR) begin
					MDR_val <= MDR_out;
			 end
			 
			 else begin
					MDR_val <= MDR_val;
			 end
		end

endmodule 

module MDR_mux (input logic [15:0] Bus,
					 input logic [15:0] Data_to_CPU,
					 input logic OE,
					 output logic [15:0] MDR_out);

	always_comb
		begin 
			 if(OE == 0) begin
					MDR_out <= Data_to_CPU;
			 end
		 
			 else if(OE == 1) begin
					MDR_out <= Bus;
			 end
			 
			 else begin
					MDR_out <= Data_to_CPU;
			 end 
		end


endmodule

module IR  (input logic [15:0] Bus,
				input logic Clk, Reset, 
				input logic LD_IR,
				output logic [15:0] IR_mem); //Program Counter Register, stores address of next instruction
	
	always_ff @ (posedge Clk)
		begin 
			 if(Reset) begin
					IR_mem <= 16'b0;
			 end
		 
			 else if (LD_IR) begin
					IR_mem <= Bus;
			 end
			 
			 else begin
					IR_mem <= IR_mem;
			 end
		end

endmodule 

module Bus_Mux (input logic  GatePC, 
					 input logic [15:0] PC_curr,
					 input logic  GateMARMUX,
					 input logic [15:0] MARMUX_out,
					 input logic  GateMDR,
					 input logic [15:0] MDR_out,
					 input logic  GateALU,
					 input logic [15:0] ALU_out,
					 output logic [15:0] Bus);

	always_comb begin
		if(GatePC) Bus =  PC_curr;
		else if (GateMARMUX) Bus = MARMUX_out;
		else if (GateMDR) Bus = MDR_out;
		else if (GateALU) Bus = ALU_out;
		else Bus = 16'bZZZZZZZZZZZZZZZZ;
	end 

endmodule 

module Address_ALU (input logic [15:0] SR2_Mux_out, //ALU near PC that computes the next PC value based on current instruction
						  input logic [15:0] SR1_out,
						  input logic [1:0] ALUK,
						  output logic [15:0] ALU_out); //flag whether should comput using offet or just be PC + 1
						  
						  
		always_comb
		begin 
			 if(ALUK == 0) begin
					ALU_out = SR1_out + SR2_Mux_out;
			 end
		 
			 else if(ALUK == 1) begin
					ALU_out = SR1_out & SR2_Mux_out;
			 end
			 
			 else if(ALUK == 2) begin
					ALU_out = !SR1_out;
			 end
			 
			 else if(ALUK == 3) begin
					ALU_out = SR1_out;
			 end
			 
			 else begin
					ALU_out <= SR1_out;
			 end 
		end
endmodule 

module Reg_File (input logic [2:0] SR2,
					  input logic Clk,
					  input logic Reset,
					  input logic LD_REG,
					  input logic [15:0] BUS_val,
					  input logic [2:0] SR1_Mux_out,
					  input logic [2:0] DR_Mux_out,
					  output logic [15:0] SR1_out,
					  output logic [15:0] SR2_out);

	logic [15:0] reg_array [8];
	//logic [15:0] BUS_hold;
   
	assign SR1_out = reg_array[SR1_Mux_out];
	assign SR2_out = reg_array[SR2];
	
	always_ff @ (posedge Clk)
	begin
		if(Reset) begin
			for(integer i = 0; i < 8; i = i + 1)
			begin
				reg_array[i] <= 16'b0;
			end
		end
	
		else if (LD_REG) begin
				reg_array[DR_Mux_out] <= BUS_val;
		end
		else begin
		end
	end
		
endmodule

module SR1_mux (input logic SR1MUX,
					 input logic [2:0] IR11_9,
					 input logic [2:0] IR8_6,
					 output logic [2:0] SR1_Mux_out);
	always_comb
		begin 
			 if(SR1MUX == 1) begin
					SR1_Mux_out = IR8_6;
			 end
		 
			 else begin
					SR1_Mux_out = IR11_9;
			 end
		end

endmodule

module SR2_mux (input logic SR2MUX,
					 input logic [15:0] IR,
					 input logic [15:0] SR2_out,
					 output logic [15:0] SR2_Mux_out);
					 
	logic [15:0] IR4;
	assign IR4 = {{11{IR[4]}},IR[4:0]};
	
	always_comb
		begin 
			 if(SR2MUX == 0) begin
					SR2_Mux_out = SR2_out;
			 end
		 
			 else if(SR2MUX == 1) begin
					SR2_Mux_out = IR4;
			 end
			 
			 else begin
					SR2_Mux_out = SR2_out;
			 end 
		end

endmodule

module DR_mux (input logic DRMUX,
					 input logic [2:0] IR11_9,
					 output logic [2:0] DR_Mux_out);
					 
	always_comb
		begin 
			 if(DRMUX == 0) begin
					DR_Mux_out = IR11_9;
			 end
		 
			 else if(DRMUX == 1) begin
					DR_Mux_out = 3'b111;
			 end
			 
			 else begin
					DR_Mux_out = IR11_9;
			 end 
		end

endmodule

module ADDR1_mux (input logic ADDR1MUX,
					   input logic [15:0] PC_curr,
						input logic [15:0] SR1_out,
					   output logic [15:0] ADDR1_mux_out);
					 
	always_comb
		begin 
			 if(ADDR1MUX == 0) begin
					ADDR1_mux_out = PC_curr;
			 end
		 
			 else if(ADDR1MUX == 1) begin
					ADDR1_mux_out = SR1_out;
			 end
			 
			 else begin
					ADDR1_mux_out = PC_curr;
			 end 
		end

endmodule

module ADDR2_mux (input logic [1:0] ADDR2MUX,
						input logic [15:0] IR,
					   output logic [15:0] ADDR2_mux_out);

	logic [15:0] IR5, IR8, IR10;
	assign IR5 = {{10{IR[5]}},IR[5:0]};
	assign IR8 = {{7{IR[8]}},IR[8:0]};
	assign IR10 = {{5{IR[10]}},IR[10:0]};
					 
	always_comb
		begin 
			 if(ADDR2MUX == 0) begin
					ADDR2_mux_out = 4'h0000;
			 end
		 
			 else if(ADDR2MUX == 1) begin
					ADDR2_mux_out = IR5;
			 end
			 
			 else if(ADDR2MUX == 2) begin
					ADDR2_mux_out = IR8;
			 end
			 
			 else if(ADDR2MUX == 3) begin
					ADDR2_mux_out = IR10;
			 end
			 
			 else begin
					ADDR2_mux_out = 4'h0000;
			 end 
		end

endmodule

module ADDR_ADDER(input logic [15:0] ADDR1_mux_out,
						input logic [15:0] ADDR2_mux_out,
						output logic [15:0] ADDR_out);
						
	always_comb begin
		ADDR_out = ADDR1_mux_out + ADDR2_mux_out;
	end 
endmodule

//MY WORK 
/*
3 Bit register that maintains or modifies CC
4 cases, neg, zero, pos, LD_CC is Low
*/
module nzp_REG(input logic [2:0] CC_Bus,
					input logic Clk, Reset,LD_CC,
					output logic [2:0]CC_nxt);

	always_ff @ (posedge Clk)
		begin
			if(Reset) begin 				 //Reset data
				CC_nxt <= 0;
		end
		else if(CC_Bus == 3'b100 & LD_CC == 1)    //100
			begin
				CC_nxt <= 3'b100;
		end
	
		else if(CC_Bus == 3'b010 & LD_CC == 1) 	//010
			begin
				CC_nxt <= 3'b010;
		end
		
		else if (CC_Bus == 3'b001 & LD_CC == 1)  //001
			begin
				CC_nxt <= 3'b001;
		end
	
		else //LD_CC is not High
			begin
			CC_nxt[0] <= CC_nxt[0];
			CC_nxt[1] <= CC_nxt[1];
			CC_nxt[2] <= CC_nxt[2];
		end
	end 

endmodule

/*
Reset -> clear BEN_OUT
is LD_BEN = 1 -> Out <= In
is LD_BEN = 0 -> Out <= Out 
*/ 
module BEN_REG (input logic BEN_IN,
					 input logic Clk, Reset,
					 input logic LD_BEN,
					 output logic BEN_OUT);

	always_ff @ (posedge Clk) begin
		if(Reset)
			begin
				BEN_OUT <= 0;
			end
		else if (LD_BEN)
			begin
			BEN_OUT <= BEN_IN;
			end
		else
			begin
			BEN_OUT <= BEN_OUT;
			end
	end
endmodule

module CC (input logic [15:0]Bus_Mux, 
			  input logic [15:0]IR,
			  input logic Clk,
			  input logic LD_BEN,
			  output logic CONTROL_IN);
	//Internal Logic			  
	logic[2:0] CC_Bus; 
	logic BEN_INT; // BEN Input Temp
	logic [2:0] CC_nxt;

	always_comb begin
		//Check and assign CC_calc
		if(Bus_Mux[15] == 1)
			begin
			CC_Bus <= 3'b100; 
			end
		else if(Bus_Mux[15:0] == 0)
			begin
			CC_Bus <= 3'b010;
			end
		else
			begin
			CC_Bus <= 3'b001;
			end
	end			   

nzp_REG arr(.Clk(),.Reset(),.LD_CC(),.CC_Bus(CC_Bus),.CC_nxt(CC_nxt));

//Use values from IR 11:9 to check if we have a match to BR
	always_ff @ (posedge Clk) begin
		if(IR[11] & CC_nxt[2] + IR[10] & CC_nxt[1] + IR[9] & CC_nxt[0]) begin 
			BEN_INT <= 1;
		end 
		
		else begin 
			BEN_INT <= 0;
		end
	end

//BEN_OUT is the value that we take into Control 
BEN_REG B(.Clk(),.Reset(),.BEN_IN(BEN_INT),.LD_BEN(), .BEN_OUT(CONTROL_IN));

endmodule 


