module send_start(
output reg start,
input reset,
input enter,
input clock

);

reg [1:0] state ;
localparam s_nothing=2'd0, s_play=2'd1;


always @(posedge clock) begin
start <= 0;
	if (reset) begin state <= s_nothing; end
	
	else begin
		case(state)
		s_nothing: begin
		state <= enter ? s_play:s_nothing;
		if (enter) begin start<= 1'b1; end
		
		end
		
		s_play: begin end
		
		
		endcase
	
	
	
	
	end
	




end



endmodule
