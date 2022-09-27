module PSM(
input Clock, Reset, 
input[7:0] Din1, Din2,
input Start,
output reg Ready,
output reg Op1,
output reg Op2,
output reg Op3,
output reg[7:0] Dout);

// states of the statemachine
localparam ready_state = 0;
localparam op1_state = 1;
localparam op2_state = 2;
localparam op3_state = 3;


// states of the statemachine
localparam op1_length = 2;
localparam op2_length = 5;
localparam op3_length = 3;

// local variables
integer present_state, next_state;
integer present_counter, next_counter;

reg[7:0] A;
reg[7:0] B;
reg[7:0] notA;
reg[7:0] notAandB;

always @ (posedge Reset or posedge Clock)
begin
	if (Reset) begin
		present_state <= ready_state;
		present_counter <= 0;
	end
	else begin
		present_state <= next_state;
		present_counter <= next_counter;
	end
end

// state machine mode changing
always
begin
	next_state = present_state;
	next_counter = present_counter + 1;
	
	case (present_state)
		ready_state: begin
			if (Start) begin
				next_counter <= 0;
				next_state <= op1_state;
			end
		end
		op1_state: begin
			if (next_counter >= op1_length) begin
				next_counter <= 0;
				next_state <= op2_state;
			end
		end
		op2_state: begin
			if (next_counter >= op2_length) begin
				next_counter <= 0;
				next_state <= op3_state;
			end
		end
		op3_state: begin
			if (next_counter >= op3_length) begin
				next_counter <= 0;
				next_state <= ready_state;
			end
		end
	endcase
end

// output control in state machine mode	
always
begin
	Op1 <= 0;
	Op2 <= 0;
	Op3 <= 0;
	Ready <= 0;
	Dout[7:0] <= 0;
	
	case (present_state)
		ready_state: begin
			Ready <= 1;
			A[7:0] <= Din1[7:0];
			B[7:0] <= Din2[7:0];
		end
		op1_state: begin
			Op1 <= 1;
			Dout <= A|B;
		end
		op2_state: begin
			Op2 <= 1;
			Dout <= A^B;
		end
		op3_state: begin
			Op3 <= 1;
			notA <= ~A;
			notAandB <= notA & B;
			Dout <= ~notAandB;
		end
	endcase
end

endmodule