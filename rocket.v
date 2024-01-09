


module rocket#(parameter CLOCK_FREQUENCY = 50000000, fps = 24)(
input clock,
input reset,
input start,
input left, 
input right,

//for draw, later animation
  	output wire draw, 
	input wire draw_done,
	output wire [7:0] draw_x,
	output wire [6:0]  draw_y,
	output [2:0] iColor,
	output wire moving_rocket,
	//for collision detector 
	output [7:0] current_x,
	output [6:0] current_y,
	output wire done //done meving or drawing
  	
);  
assign current_y = 7'd109;
wire go;
wire [7:0] start_x, end_x;
wire [6:0] start_y;
assign current_x = start_x;

wire signed [2:0] delta_x;

assign start_y = 7'd109;

// wrong assign current_x = draw_x;

wire move_done;
assign done = move_done;

	control_rocket cr (
		.clock(clock),
		.start(start),
		.reset(reset),
		.go(go),
		.start_x(start_x),
		.end_x(end_x),
		.left(left),
		.right(right),
		.delta_x(delta_x),
		.move_done(move_done),
		.moving_rocket(moving_rocket)


		);

	move_dp #(CLOCK_FREQUENCY,fps) dr (
		.clock(clock),
		.go(go),
		.reset(reset),
		.draw_done(draw_done), //from draw_box
		.draw(draw), //for draw_box or animation
		.start_x(start_x), //start, end, deltas from control
		.start_y(start_y),
		.end_x(end_x),
		.end_y(start_y),
		.color(3'd4), //given color of rocket
		.delta_x(delta_x), .delta_y(0),
		.draw_x(draw_x), //draw_x, draw_y, for draw box
		.draw_y(draw_y), 
		.oColor(iColor), //ocolor here is icolor to draw_box
		.move_done(move_done)
	);
endmodule

module control_rocket(
		input clock,
		input start,
	input reset,

		output reg go,
		output reg [7:0] start_x, 
		output reg [7:0] end_x,
		output reg [7:0] current_x,
		input left,
		input right,
		output reg signed [2:0] delta_x,
		input move_done, output reg moving_rocket
);



	localparam s_nothing = 3'd0, s_lw = 3'd1, s_rw = 3'd2, s_r = 3'd3, s_l = 3'd4, s_idle = 3'd5, s_wait = 3'd6;

	reg [2:0] state;

	wire signed [7:0] distance;
	assign distance = 8'd16;
	
reg [7:0] p;
	always@(posedge clock) begin
	go <= 0;
	moving_rocket<=0;
	if (reset) begin
		go <= 0;
		delta_x <= 0;
		start_x <= 8'd3;
		current_x <= 8'd3; 
		state <= s_nothing; end


	else begin
	case(state)

	s_nothing: begin 

		if (start) begin
			go <= 1'b1;
			state <= s_wait;
			end_x <= current_x;
			end 
	end

	s_idle: begin
	
	if (left) begin
		state <= s_lw;
		delta_x <= -3'd1; 
		

			
		
		
		
		end

	
	if (right) begin
		state <= s_rw;
		delta_x <= 3'd1; 
		
	
		
		
		
		
		end

	end


	s_rw: begin
	if (!right) begin
			
	
			
				if (start_x + distance >= 8'd158) begin
			state <= s_idle; end
			
			else begin go <= 1'b1;
			state <= s_wait; 
			end_x <= start_x + distance; end

	end 
	end


	s_lw: begin

	if (!left) begin
		

			
					if (start_x - distance < 8'd3|| start_x - distance >start_x) begin
			state <= s_idle; end
			
			else begin go <= 1'b1;
			state <= s_wait; 
			end_x <= start_x - distance; end

	end end

	s_wait: begin
	moving_rocket <= 1'b1;
	if (move_done) begin
		moving_rocket <=0;
		state <= s_idle;
		start_x <= end_x; current_x <= end_x;  end	

	end

	endcase


	end //for else
		
	end //for always


endmodule





			
