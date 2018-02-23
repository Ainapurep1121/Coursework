module PC (input logic [15:0] PC_Mux_out,
			  input logic [15:0] PC_curr,
			  input logic Clk, Reset, Continue, 
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
					input logic [15:0] PC_offset,
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
					PC_Mux_out <= PC_offset;
			 end
			 
			 else if(PCMUX == 2) begin
					PC_Mux_out <= Bus;
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

module Address_ALU (input offset, //ALU near PC that computes the next PC value based on current instruction
						  input offset_flag,
						  output address); //flag whether should comput using offet or just be PC + 1
						  
						  
endmodule 

