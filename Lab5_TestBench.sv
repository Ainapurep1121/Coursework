module testbench();


timeunit 10ns; //Half clock cycle @ 50 MHz

timeprecision 1ns; 

//These signals are internal beause the processor
//will be instantiated as a submodule in Test Bench


//DECLARE ALL VARIABLES
logic Clk = 0;
logic Reset, Run, ClearA_LoadB;
logic [7:0] S, Aval, Bval;
logic [6:0] AhexL,
				AhexU,
				BhexL,
				BhexU;
				
//Store Answers For Comparison
logic [7:0] ans_A, ans_B;
logic			ans_X;


//Toggle clock
//#1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
	#1 Clk = ~Clk;
end

intitial begin: CLOCK_INITIALIZATION
	Clk = 0;
end

//Testing begins here
//Initial block is not synthesizable

intial begin: TEST_VECTORS

//Declare the solutions for comparison 
ans_A = 8'h63; 
ans_B = 8'hFE;
ans_X = 1'b1;

//Actual Simulation Test
ClrA_LdB 	= 0;    	 // Set to 0, before toggling
S 				= 8'hC5;	 // Hex -59 = 1100 0101 -< Check
ClrA_LdB 	= 1;	    //Toggle ClrA_LdB
ClrA_LdB 	= 0;       
S 				= 8'h07;  //Hex 07 = 0000 0111 -< check 
Run 			= 1;
Run 			= 0;

//Store Results to check if computation worked. 
//This chunk can be moved around!
Aval = blah
Bval = blah 

//Repeat Calculation Check
#2 S 				= 9'h02;
   Run 			= 1;
#2	Run			= 0;

//Flipped operands Czech
#5 Reset 	= 1;
	Reset 	= 0;
	S 			= 8'hC5;
	ClrA_LdB = 1;
	ClrA_LdB = 0;
	S 			= 8'h07;
#2 Run 		= 1;
#2 Run 		= 0;
end

//Check if the compuation units worked as expected

#22 if(Aval != ans_A)
			ErrorCnt++;
	 if(Bval != ans_B)
			ErrorCnt++;
	 if(Xval != ans_X)
			ErrorCnt++;
	 
if(ErrorCnt == 0)
	$display("Success!"); 
else
	$display("%d error(s) detected.", ErrorCnt);
end

endmodule
