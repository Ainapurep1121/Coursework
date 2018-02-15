module control_logic (input  logic Clk, Reset, LoadA, LoadB, Run, //change
                output logic Add, Sub, Shift, Clr_A );

					 //make current state an output
					 
    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 8 states, so you will need to bump this up for 8-bits
    enum logic [4:0] {Start, ClearA, Add1, Shift1, Add2, Shift2,
							 Add3, Shift3, Add4, Shift4, Add5, Shift5, 
							 Add6, Shift6, Add7, Shift7, Sub8, Shift8, Done}   curr_state, next_state; 
	
	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= Start;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
		  Add = 0;
        Sub = 0;
		  Clr_A = 0;
		  Shift = 0;
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

				Start: if (Run)
                       next_state = ClearA;
				ClearA: begin  
							  next_state = Add1;
							  Clr_A = 1;
						  end
				Add1: begin 
							  next_state = Shift1;
							  Clr_A = 0;
							  Add = 1;
						end
				Shift1: begin    
							  next_state = Add2;
							  Shift = 1;
							  Add = 0;
						  end  
				Add2: begin
							  next_state = Shift2;
							  Shift = 0;
							  Add = 1;
						end
				Shift2: begin    
							  next_state = Add3;
							  Shift = 1;
							  Add = 0;
						  end  
				Add3: begin
							  next_state = Shift3;
							  Shift = 0;
							  Add = 1;
						end
				Shift3: begin    
							  next_state = Add4;
							  Shift = 1;
							  Add = 0;
						  end  
				Add4: begin
							  next_state = Shift4;
							  Shift = 0;
							  Add = 1;
						end
				Shift4: begin    
							  next_state = Add5;
							  Shift = 1;
							  Add = 0;
						  end  
				Add5: begin
							  next_state = Shift5;
							  Shift = 0;
							  Add = 1;
						end
				Shift5: begin    
							  next_state = Add6;
							  Shift = 1;
							  Add = 0;
						  end  
				Add6: begin
							  next_state = Shift6;
							  Shift = 0;
							  Add = 1;
						end
				Shift6: begin    
							  next_state = Add7;
							  Shift = 1;
							  Add = 0;
						  end  
				Add7: begin
							  next_state = Shift7;
							  Shift = 0;
							  Add = 1;
						end
				Shift7: begin    
							  next_state = Sub8;
							  Shift = 1;
							  Sub = 0;
							  Add = 0;
						  end  
				Sub8: begin
							  next_state = Shift8;
							  Shift = 0;
							  Sub = 1;
							  Add = 1;
						end
				Shift8: begin    
							  next_state = Done;
							  Shift = 1;
							  Sub = 0;
							  Add = 0;
						  end  
				Done:      if (~Run) 
                       next_state = Start;
							  
        endcase
    end

//	 assign Add = (curr_state == Add1);
//	 assign Shift = (curr_state == Shift1);
//	 assign Clr_A	= (curr_state == ClearA);
endmodule
