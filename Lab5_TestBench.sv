module testbench();


timeunit 10ns; //Half clock cycle @ 50 MHz

timeprecision 1ns; 

//These signals are internal beause the processor
//will be instantiated as a submodule in Test Bench


//DECLARE ALL VARIABLES
logic Clk = 0;
logic Reset, Run, ClearA_LoadB, X;
logic [7:0] S, Aval, Bval;
logic [6:0] AhexL,
				AhexU,
				BhexL,
				BhexU;
				
//Store Answers For Comparison
logic [7:0] ans_A1, ans_B1, ans_A2, ans_B2, ans_A3, ans_B3;
logic			ans_X1, ans_X2, ans_X3;

// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
Multiplier multiplier0(.*);	

//Toggle clock
//#1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

//Testing begins here
//Initial block is not synthesizable

initial begin: TEST_VECTORS

//Declare the solutions for comparison 
ans_A1 = 8'hFE; // -b * s ~ -59 * 7
ans_B1 = 8'h63; 
ans_X1 = 1'b1;
ans_A2 = 8'h00; // b * s ~ 4 * 3
ans_B2 = 8'h0C; 
ans_X2 = 1'b0;
ans_A3 = 8'hFE; // b * -s ~ 7 * -59
ans_B3 = 8'h63; 
ans_X3 = 1'b1;
Reset = 0;		// Toggle Rest
ClearA_LoadB = 1;
Run = 1;
S = 8'h000;
Aval = 8'h000;
Bval = 8'h000;

//Actual Simulation Test
#2 Reset 			= 1;
#2 ClearA_LoadB 	= 0;    	 // Set to 0, before toggling
#2 S 					= 8'hC5;	 // Hex -59 = 1100 0101 -< Check
#2 ClearA_LoadB 	= 1;	    //Toggle ClrA_LdB      
#3 S 					= 8'h07;  //Hex 07 = 0000 0111 -< check 
#3 Run 				= 0;

#3 Run 				= 1;

//Store Results to check if computation worked. 
//This chunk can be moved around!
//Aval = blah
//Bval = blah 

#35 Reset 			= 0;
#2 Reset 			= 1;
#5 ClearA_LoadB 	= 0;    	 // Set to 0, before toggling
#2 S 				= 8'h04;	 // Hex -59 = 1100 0101 -< Check
#2 ClearA_LoadB 	= 1;	    //Toggle ClrA_LdB      
#2 S 				= 8'h03;  //Hex 07 = 0000 0111 -< check 
#2 Run 				= 0;

#2 Run 				= 1;

#5 Reset 			= 0;
#2 Reset 			= 1;
#5 ClearA_LoadB 	= 0;    	 // Set to 0, before toggling
#2 S 				= 8'h07;	 // Hex -59 = 1100 0101 -< Check
#2 ClearA_LoadB 	= 1;	    //Toggle ClrA_LdB      
#2 S 				= 8'hC5;  //Hex 07 = 0000 0111 -< check 
#2 Run 				= 0;

#2 Run 				= 1;

//Repeat Calculation Check
//#5 S 				= 9'h02;
//#5 Run 			= 1;
//#6	Run			= 0;

//Flipped operands Czech
//#22 Reset 	= 0;
//#7	Reset 	= 1;
//#7	S 			= 8'hC5;
//#7	ClearA_LoadB = 0;
//#7	ClearA_LoadB = 1;
//#7	S 			= 8'h07;
//#8 Run 		= 0;
//#8 Run 		= 1;


//Check if the compuation units worked as expected

//#22 if(Aval != ans_A)
//			ErrorCnt++;
//	 if(Bval != ans_B)
//			ErrorCnt++;
//	 if(X != ans_X)
//			ErrorCnt++;
//	 
//if(ErrorCnt == 0)
//	$display("Success!"); 
//else
//	$display("%d error(s) detected.", ErrorCnt);

end
endmodule