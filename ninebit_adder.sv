module ninebit_adder
(
    input   logic[7:0]     A,
    input   logic[7:0]     S,
	 input   logic				M,
    output  logic[7:0]     AxS,
    output  logic          X
);

	logic C0, C1;
	logic [7:0] SubV;
	assign SubV[0] = S[0] ^ M;
	assign SubV[1] = S[1] ^ M;
	assign SubV[2] = S[2] ^ M;
	assign SubV[3] = S[3] ^ M;
	assign SubV[4] = S[4] ^ M;
	assign SubV[5] = S[5] ^ M;
	assign SubV[6] = S[6] ^ M;
	assign SubV[7] = S[7] ^ M;
	  
	four_bit_ra FRA0(.x(A[3 : 0]), .y(SubV[3 : 0]), .cin( M), .s(AxS[3 : 0]), .cout(C0));
	four_bit_ra FRA1(.x(A[7 : 4]), .y(SubV[7 : 4]), .cin(C0), .s(AxS[7 : 4]), .cout(C1));
	
	assign X = (C1 | AxS[7]);
	
	
endmodule

module four_bit_ra(
		input	logic[3:0] x,
		input	logic[3:0] y,
		input cin,
		output logic [3:0] s,
		output logic cout
		);
		
	logic c0, c1, c2;
	
	full_adder fa0(.x(x[0]), .y(y[0]), .cin(cin), .s(s[0]), .cout(c0));
	full_adder fa1(.x(x[1]), .y(y[1]), .cin(c0), .s(s[1]), .cout(c1));
	full_adder fa2(.x(x[2]), .y(y[2]), .cin(c1), .s(s[2]), .cout(c2));
	full_adder fa3(.x(x[3]), .y(y[3]), .cin(c2), .s(s[3]), .cout(cout));
	
endmodule

module full_adder (input x, y, cin,
 output s, cout);
assign s = x^y^cin;
assign cout = (x&y)|(y&cin)|(x&cin);
endmodule
