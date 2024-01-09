module laser#(parameter CLOCK_FREQUENCY=50000000, fps=24)(
	input clock, 
	input reset,
	input start,
	input wire [7:0] rocket_x,
	input wire [6:0] rocket_y,
	output wire draw,	
	input wire fire, 
	input wire hit, 
	output wire destroyed,
	output wire [7:0] draw_x, //should be shifyed
	output wire [6:0] draw_y,
	output wire [2:0] iColor,
	output wire [7:0] current_x,
	output wire [6:0] current_y,
	input wire draw_done,
	output wire reset_draw,
	output wire done //move done
);

wire [7:0] start_x;
wire move_done;
assign done = move_done;
wire go;
wire [6:0] size;
assign size = 7'd10;


laser_control lc(
.clock(clock),
.reset(reset),
.start(start),
.fire(fire),
.go(go),

.destroyed(destroyed),

.rocket_y(rocket_y),
.rocket_x(rocket_x),
.start_x(start_x),

.draw_x(draw_x),
.draw_y(draw_y),
.current_x(current_x),
.current_y(current_y), 
.move_done(move_done)
);


move_dp2#(CLOCK_FREQUENCY, fps) dp3 (
.clock(clock),
.go(go),
.reset(reset),
.draw_done(draw_done),
.draw(draw),
.start_x(start_x),
.start_y(7'd109-size),
.end_x(start_x),
.end_y(7'd0),
.color(3'b110),
.destroy(hit),
.destroyed(destroyed),
.delta_x(0),
.delta_y(-3'd1),
.draw_x(draw_x),
.draw_y(draw_y),
.oColor(iColor),
.move_done(move_done),
.reset_draw(reset_draw)
);



endmodule


module laser_control (
input clock,
input reset,
input start,
input wire fire,
input wire destroyed,
input wire [7:0] rocket_x,
input wire [6:0] rocket_y,
input wire [7:0] draw_x,
input wire [6:0] draw_y,
output reg go,

output reg [7:0] start_x,
output reg [7:0] current_x,//can't always be same as rocket
output reg [6:0] current_y, 
input wire move_done
);

reg [1:0] state;

localparam s_nothing = 2'b00, s_wait = 2'b10, s_play = 2'b01, s_w_f = 2'b11;

always @(posedge clock) begin
	go <= 0;
	if (reset) begin
		current_x <= 7'd8;
		current_y <= 7'd109;
		start_x <= 7'd8;
		state <= s_nothing;
	end

	else begin
	case(state)
			s_nothing: state <= start ? s_play: s_nothing;


		s_play: state <= (fire) ? s_w_f : s_play;

		

		s_w_f: begin
			if (!fire) begin
			start_x <= rocket_x;
			current_x <= rocket_x;
			current_y <= rocket_y;
			go <= 1'b1;
			state <= s_wait; end

		end
		


		s_wait: begin
			current_x <= draw_x;
			current_y <= draw_y;
			if (destroyed||move_done) begin
				state <= s_play; 
						end
		end
		


		endcase
	
	
		end
	



end

endmodule





