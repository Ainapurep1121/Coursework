module Multiplier
(

    input   logic           Clk,        // 50MHz clock is only used to get timing estimate data
    input   logic           Reset,      // From push-button 0.  Remember the button is active low (0 when pressed)
    input   logic           Run,        // From push-button 3.
    input   logic           ClearA_LoadB,         // From slider switches
	 input 	logic	[7:0]		 S,
	 
	 output  logic [6:0]  	 AhexL,				// Hex drivers display both inputs to the adder.
									 AhexU,
									 BhexL,
									 BhexU,
	 output  logic [7:0] 	 Aval, 
	   							 Bval,
	 output  logic 			 X);

// Need module that describes control 
    logic          Clr_A;      // From push-button 1
	 logic          Shift;      // From push-button 1
	 logic          Add;      // From push-button 1
	 logic          Sub;      // From push-button 1
	 logic[7:0]     A;  // Shift register A
	 logic[7:0]     B;  // Shift register B
	 logic[8:0]     Aout;  // Shift register A
	 logic 			 Xout;  // Sign extension bit 
	 logic 			 LSB;
	 logic[6:0]      AhexU_comb;
    logic[6:0]      AhexL_comb;
    logic[6:0]      BhexU_comb;
    logic[6:0]      BhexL_comb;
	 
	 assign LSB = B[0];
	 
	 
	ninebit_adder 		addition_unit (
							.A(A),
							.S(S^Sub),
							.M(Sub),
							.AxS(Aout),
							.X(Xout));
							
	reg_8					register_unitA  ( 		// come back to these imputs
							.Clk(Clk), 
							.Reset(Reset), 
							.Shift_In(A[7]), 
							.Load(ClearA_LoadB), 
							.Shift_En(Shift),
							.D(S));
							
	reg_8					register_unitB  (
							.Clk(Clk), 
							.Reset(Reset), 
							.Shift_In(B[7]), 
							.Load(ClearA_LoadB), 
							.Shift_En(Shift),
							.D(S));
							
	control_logic		control_unit (
							.Clk(Clk),
							.Reset(Reset),
							.LoadB(LoadB),
							.LoadA(LoadA),
							.Run(Run),
							.Add(Add),
							.Sub(Sub),
							.Shift(Shift),
							.Clr_A(Clr_A)
							);
	 
	 always_ff @(posedge Clk) begin
        
        if (Clr_A) begin
            // if clear var is high, clear A
            A <= 8'h000;
            X <= 1'b0;
        end else if (!Reset) begin
            // if reset is pressed, clear the adder's input registers
				A <= 8'h000;
				B <= 8'h000;
            X <= 1'b0;
        end else if (!ClearA_LoadB) begin
            // if ClearA_LoadB is pressed, clear the adder's input registers
            A <= 8'h000;
            B <= S;
            X <= 1'b0;
        end else if (Add && LSB) begin
				A <= Aout[7:0]; 
				X <= Xout;
		  end else if (Shift) begin
				B = B	>> 1;	//Step 2?
				B[7] = A[0]; //Step 1? 
				A = A >>> 1;
				A[7] = X;
				Aval = A;
				Bval = B;
		  end 
	 end
	 
	 always_ff @(posedge Clk) begin
        
        AhexU <= AhexU_comb;
        AhexL <= AhexL_comb;
        BhexU <= BhexU_comb;
        BhexL <= BhexL_comb;
        
    end
	 
	 HexDriver        HexAL (
                        .In0(A[3:0]),
                        .Out0(AhexL_comb) );
	 HexDriver        HexBL (
                        .In0(B[3:0]),
                        .Out0(BhexL_comb) );
								
	 //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
	 HexDriver        HexAU (
                        .In0(A[7:4]),
                        .Out0(AhexU_comb) );	
	 HexDriver        HexBU (
                        .In0(B[7:4]),
                        .Out0(BhexU_comb) );

//	  sync button_sync[3:0] (Clk, {~Reset, ~Run, ClearA_LoadB}, {Reset_SH, Run_SH, LoadB_SH, Execute_SH});
//	  sync Din_sync[7:0] (Clk, Din, Din_S);
//	  sync F_sync[2:0] (Clk, F, F_S);
//	  sync R_sync[1:0] (Clk, R, R_S);
	

endmodule