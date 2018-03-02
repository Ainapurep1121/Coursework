module datapath (input logic Clk,
					  input logic Reset,
					  input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
					  input logic GatePC, GateMDR, GateALU, GateMARMUX,
					  input logic [1:0] PCMUX, ADDR2MUX, ALUK,
					  input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
					  input logic CE, UB, LB, OE, WE, 
					  input logic MIO_EN,
					  input logic [15:0] MDR_In,
					  output logic [15:0] MDR, IR, PC,
					  output logic [15:0] MAR,
					  output logic BEN);

	logic [15:0] PC_Mux_out; 		// TODO: set PC_curr to PC_Mux_out
	logic [15:0] Bus, SR2_Mux_out, SR1_out, SR2_out,ADDR1_mux_out, ADDR2_mux_out, ADDR_out;
	logic [15:0] PC_inc;
	logic [15:0] PC_curr;			// temp storage for PC
	logic [15:0] MAR_addr;			// temp storage for MAR
	logic [15:0] MDR_out;
	logic [15:0] MDR_val;			// temp storage for MDR
	logic [15:0] IR_mem;				// temp storage for IR
	logic [15:0] MARMUX_out;
	logic [15:0] ALU_out;
	logic [2:0] SR1_Mux_out, DR_Mux_out;	
	logic BEN_temp;
	
	assign PC_inc = PC_curr + 1'b1;
	assign PC = PC_curr;
	assign IR = IR_mem;
	assign MDR = MDR_val;
	assign MAR = MAR_addr;
	assign BEN = BEN_temp;
	
 

//Todo:
/* -instantiate PC, Address ALU, BUS, MAR, MDR, IR, Reg_file, ALU, CC, testbench lol */
	


	PC 			 	PC_unit (.PC_Mux_out,	//implicit
									.PC_curr,		//implicit
									.Clk, 			//implicit
									.Reset,			//implicit
									.LD_PC,			//implicit
									.PC_addr(PC_curr));
	
	PC_Mux			PC_Mux_unit (.PC_curr,	//implicit
										 .PC_inc,	//implicit
										 .ADDR_out,//implicit
										 .Bus,		//implicit
										 .PCMUX,		//implicit ?
										 .PC_Mux_out);//implicit
	
	MAR				MAR_unit (.Bus,			//implicit
									 .Clk, 			//implicit
									 .Reset, 		//implicit
									 .LD_MAR,		//implicit
									 .MAR_addr);	//implicit
	
	MDR				MDR_unit (.MDR_out,		//implicit
									 .Clk, 			//implicit
									 .Reset, 		//implicit
									 .LD_MDR,		//implicit
									 .MDR_val);		//implicit
	
	MDR_mux			MDR_mux_unit (.Bus,				//implicit
										  .Data_to_CPU(MDR_In),
										  .OE,			//implicit
										  .MDR_out);		//implicit
	
	IR					IR_unit (.Bus,		//implicit
									.Clk, 	//implicit
									.Reset, 	//implicit
									.LD_IR,	//implicit
									.IR_mem);//implicit
	
	Bus_Mux			Bus_unit (.GatePC, 		//implicit
									 .PC_curr,		//implicit
									 .GateMARMUX,	//implicit
									 .MARMUX_out(ADDR_out),	//TODO
									 .GateMDR,		//implicit
									 .MDR_out,		//implicit
									 .GateALU,		//implicit
									 .ALU_out,		//TODO
									 .Bus);			//implicit
									 
	Address_ALU		ALU_unit (.SR2_Mux_out, //ALU near PC that computes the next PC value based on current instruction
									 .SR1_out,
									 .ALUK,
									 .ALU_out);
	
	Reg_File 		Reg_unit (.SR2(IR[2:0]),
									 .Clk,
									 .Reset,
									 .LD_REG,
									 .BUS_val(Bus),
									 .SR1_Mux_out,
									 .DR_Mux_out,
									 .SR1_out,
									 .SR2_out);
	
	SR1_mux 			SR1_mux_unit (.SR1MUX,
										  .IR11_9(IR[11:9]),
										  .IR8_6(IR[8:6]),
										  .SR1_Mux_out);
										 
	SR2_mux 			SR2_mux_unit (.SR2MUX,
										  .IR,
										  .SR2_out,
										  .SR2_Mux_out);
								  
	DR_mux 			DR_mux_unit (.DRMUX,
										 .IR11_9(IR[11:9]),
										 .DR_Mux_out);
										
	ADDR1_mux 		ADDR1_mux_unit (.ADDR1MUX,
											 .PC_curr,
											 .SR1_out,
											 .ADDR1_mux_out);
											
	ADDR2_mux 		ADDR2_mux_unit (.ADDR2MUX,
											 .IR,
											 .ADDR2_mux_out);
											 
	ADDR_ADDER		ADDR_ADDER_unit (.ADDR1_mux_out,
											  .ADDR2_mux_out,
											  .ADDR_out);
	
	CC 				CC_unit(.Bus_Mux(Bus), 
								  .IR,
								  .LD_BEN,
								  .Clk,
								  .CONTROL_IN(BEN_temp));
	

endmodule 

