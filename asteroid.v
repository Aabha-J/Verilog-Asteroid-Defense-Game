module LFSR(
  output reg [7:0] Reg,
  input clk,
  input reset
);
  always @(posedge clk) begin
    if (reset) begin
      Reg <= 8'd33;  // seed
    end else begin
      
       Reg <= {Reg[5:0], Reg[4] ^ Reg[7] ^ Reg[5], Reg[0] ^ Reg[1] ^ Reg[6] ^ Reg[3]}; 
    end
  end

  

endmodule


module asteroid #(parameter CLOCK_FREQUENCY = 50000000, fps=24, max=10) (
	input clock, 
	input reset,
	input start,
	output wire draw,
	output wire [7:0] draw_x,
	output wire [6:0] draw_y,
	output wire [2:0] iColor,
	output wire [7:0] current_x,
	output wire [6:0] current_y,
	input wire draw_done,output wire reset_draw,
	input destroy, output wire destroyed,
	output wire done //move done
);


wire go, move_done;
wire [7:0] start_x;
wire [6:0] start_y,radius, end_y;
wire [2:0] color;
//can change if needed
assign done = move_done;
assign end_y = 7'd109;

assign radius = 7'd5;
assign start_y = radius; 

asteroid_control #(max)ac (
	.clock(clock),
	.start(start),
	.reset(reset),
	.go(go),
	.radius(radius),
	.start_x(start_x),
	.current_x(current_x),
	.current_y(current_y),
	.move_done(move_done),
	.draw_x(draw_x),
	.draw_y(draw_y),
	.destroyed(destroyed) //receves destroyed as input
);

move_dp2 #(CLOCK_FREQUENCY, fps) dp2 (
.clock(clock),
.go(go),
.reset(reset),
.draw_done(draw_done),
.draw(draw),
.start_x(start_x),
.start_y(start_y),
.end_x(start_x),
.end_y(end_y),
.color(3'b111),
.destroy(destroy),
.destroyed(destroyed),
.delta_x(0),
.delta_y(3'd1),
.draw_x(draw_x),
.draw_y(draw_y),
.oColor(iColor),
.move_done(move_done),
.reset_draw(reset_draw)
);


endmodule

module asteroid_control #(parameter max = 16) (
	input clock,
	input start,
	input reset,
	output reg go,
	input [7:0] radius,
	output reg [7:0] start_x,
input wire [7:0] draw_x,
input wire [6:0] draw_y,
	output reg [7:0] current_x,
	output reg [6:0] current_y,
	input move_done,
	input destroyed
);

wire [7:0] ran;
localparam s_nothing = 2'b00, s_play = 2'b01, s_wmove = 2'b10;

LFSR k(
  .Reg(ran),
  .clk(clock),
  .reset(reset)
  );

reg [1:0] state;
always @(posedge clock) begin
	go <= 0;

	if (reset) begin
		start_x <= 0;
		current_y <= radius;
		go <= 0;
		state <= s_nothing;
			

	end



	else begin
	case(state)
		s_nothing: state <= start ? s_play: s_nothing;


		s_play: begin
			start_x <= (ran%10)*16 + 3;
			go <= 1'b1;
			state <= s_wmove;
			current_y <= radius;
		end


		s_wmove: begin
			current_x <= draw_x;
			current_y <= draw_y;
			if (destroyed) begin
				state <= s_play; 
						end
				else if (move_done) begin state <= s_nothing; end
					
		end
		


		endcase


	end
	end



endmodule


