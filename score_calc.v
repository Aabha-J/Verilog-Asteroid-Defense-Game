module score_calc(
input reset, input clock, input laserhits, output reg [8:0] score


);

always@(posedge clock) begin

if (reset) begin score <= 0; end

else begin

score <= laserhits ? score+1: score;

	end
	
	
end



endmodule
