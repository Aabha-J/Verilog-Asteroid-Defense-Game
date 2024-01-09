
//the vga adapter used was given by ece241 team

module draw_screen #(parameter CLOCK_FREQUENCY=50000000)(
input clock, 
input reset, 

input wire start,
input wire game_over,

input draw_asteroid,
input draw_laser,
input draw_rocket,

input wire [7:0] draw_x_laser, 
input wire [6:0] draw_y_laser, 
input wire [2:0] iColor_laser,
input wire [7:0] draw_x_asteroid, 
input wire [6:0] draw_y_asteroid, 
input wire [2:0] iColor_asteroid,
input wire [7:0] draw_x_rocket, 
input wire [6:0] draw_y_rocket, 
input wire [2:0] iColor_rocket,



output wire draw_done_asteroid,
output wire draw_done_laser,
output wire draw_done_rocket,

//done clearing screen
output wire draw_done_clear,

output wire [7:0] oX,
output wire [6:0] oY,
output wire [2:0] oColor,
output wire writeEn
 );

wire go_rocket, go_asteroid, go_laser;
wire go_clear;
wire [7:0] roX, aoX, loX, coX;
wire [6:0] roY, aoY, loY, coY; 
wire rE, aE, lE, cE;
wire [2:0] roColor, aoColor,loColor, coColor; 





		animation_control ac(.clock(clock), 
			.start(start),
			.reset(reset), 
			.game_over(game_over),
			.draw_asteroid(draw_asteroid),
			.draw_laser(draw_laser),
			.draw_rocket(draw_rocket),

			.go_rocket(go_rocket), 
			.go_asteroid(go_asteroid), 
			.go_laser(go_laser),
			.go_clear(go_clear),
			
			.rE(rE),
			.aE(aE),
			.lE(lE),
			.cE(cE),



  			.roX(roX),
  			.aoX(aoX),
  			.loX(loX),
			.coX(coX),

  			.roY(roY),
  			.aoY(aoY),
  			.loY(loY),
			.coY(coY),

  			.roColor(roColor),
  			.aoColor(aoColor),
  			.loColor(loColor),
			.coColor(coColor),

  			.draw_done_laser(draw_done_laser),
  			.draw_done_rocket(draw_done_rocket),
  			.draw_done_asteroid(draw_done_asteroid),
			.draw_done_clear(draw_done_clear),
  			
  			.oX(oX),
  			.oY(oY),
  			.oColor(oColor),
			.writeEn(writeEn)
			);



		//draw triangle once added shoudl recieve 
	draw_triangle dbr (
  		.clock(clock), .reset(reset || game_over),
  		.draw(go_rocket),
  		.start_x(draw_x_rocket),
  		.start_y(draw_y_rocket),
  		.x_size(7'd12),
  		.y_size(7'd10),
  		.iColor(iColor_rocket),
  		.oColor(roColor),
  		.cur_x(roX),
  		.cur_y(roY),
  		.plot(rE),
  		.done(draw_done_rocket));
	
	wire [7:0] radius;
	assign radius = 8'd5;
	draw_circle dc (
		.clock(clock), .reset(reset||game_over),
 		.draw(go_asteroid),
		.start_x(draw_x_asteroid),
		.start_y(draw_y_asteroid),
		.radius(radius),
  		.iColor(iColor_asteroid),
  		.oColor(aoColor),
  		.cur_x(aoX),
  		.cur_y(aoY),
  		.plot(aE),
  		.done(draw_done_asteroid)
	);

	draw_box dbl (
  		.clock(clock), .reset(reset|| game_over),
 		.draw(go_laser),
 		 .start_x(draw_x_laser),
  		.start_y(draw_y_laser),
  		.x_size(8'd1), 
  		.y_size(7'd10), 
  		.iColor(iColor_laser),
  		.oColor(loColor),
  		.cur_x(loX),
  		.cur_y(loY),
  		.plot(lE),
  		.done(draw_done_laser)
		);

	draw_box clear (
  		.clock(clock), .reset(reset),
 		.draw(go_clear),
 		 .start_x(8'd0),
  		.start_y(7'd0),
  		.x_size(8'd160), 
  		.y_size(7'd120), 
  		.iColor(3'b000),
  		.oColor(coColor),
  		.cur_x(coX),
  		.cur_y(coY),
  		.plot(cE),
  		.done(draw_done_clear)
		);



endmodule


module animation_control(
input clock, input reset, input start,

input wire game_over,
input wire draw_asteroid,
input wire draw_laser,
input wire draw_rocket,

output reg go_rocket, 
output reg go_asteroid, 
output reg go_laser,
output reg go_clear,

input wire aE,
input wire lE,
input wire rE,
input wire cE,


input wire [7:0] roX, 
input wire [7:0] aoX, 
input wire [7:0] loX, 
input wire [7:0] coX,

input wire [6:0] roY, 
input wire [6:0] aoY, 
input wire [6:0] loY, 
input wire [6:0] coY,


input wire [2:0] roColor, 
input wire [2:0] aoColor,
input wire [2:0] loColor,
input wire [2:0] coColor,


input draw_done_laser, 
input draw_done_rocket, 
input draw_done_asteroid, 
input draw_done_clear, 

output reg [7:0] oX,
output reg [6:0] oY,
output reg [2:0] oColor,
output reg writeEn

 
);



reg draw_r_recieved,draw_a_recieved, draw_l_recieved, draw_c_recieved;
localparam s_go_draw_a = 3'd1, s_go_draw_l = 3'd2, s_go_draw_r = 3'd3, s_idle = 3'b0, s_wait = 3'd4, s_nothing = 3'd5, s_go_clear = 3'd6;
reg drawing_r, drawing_a, drawing_l, drawing_clear;

reg [2:0] state;
always@(posedge clock) begin
writeEn<= 0;
	if (reset) begin
		draw_r_recieved <= 0;
		draw_a_recieved <= 0;
		draw_l_recieved <= 0;

		go_rocket <= 0;	
		go_asteroid <= 0; 
		go_laser <= 0;
		go_clear <= 0;
		oX <= 0;
		oY <= 0;
		oColor <= 0;
		go_rocket<= 0;
		go_asteroid<= 0;
		go_laser<= 0;
		drawing_l <= 0;
		drawing_a <= 0;
		state <= s_nothing;
		drawing_r <= 0;
		writeEn<= 0;
		drawing_clear <= 0;
		draw_c_recieved <= 0;
	end
	
	else if (game_over) begin 
		state<= s_go_clear; end




	else begin
	
	


		go_rocket <= 0;	
		go_asteroid <= 0; 
		go_laser <= 0;
		go_clear <= 0;
		oColor <= 0;
		writeEn<= 0;
		oX <= 0;
		oY <= 0;

	draw_r_recieved <= draw_rocket ? 1'b1: draw_r_recieved;
	draw_a_recieved <= draw_asteroid ? 1'b1: draw_a_recieved;
	draw_l_recieved <= draw_laser ? 1'b1: draw_l_recieved;
	


	case(state)

	s_nothing: begin state <= start ? s_idle: s_nothing;
		drawing_l <= 0;
		drawing_a <= 0;
		drawing_r <= 0; end

	s_idle: begin
		go_rocket <= 0;	
		go_asteroid <= 0; 
		go_laser <= 0;
		go_clear <= 0;
		oColor <= 0;
		writeEn<= 0;
		oX <= 0;
		oY <= 0;
		

	
		state <= s_go_draw_a;
	
		end

	s_go_draw_a: begin 

		if (draw_a_recieved) begin
			go_asteroid <= 1'b1;
	
			draw_a_recieved <= 0; 
			drawing_a <= 1'b1; 
			state <= s_wait;
			
			end

		else begin
			state <= s_go_draw_l; end 
		
		end


	s_go_draw_l: begin 

		if (draw_l_recieved) begin
			go_laser <= 1'b1;
		
			draw_l_recieved <= 0; 
			drawing_l <= 1'b1; 
			state <= s_wait;
			end

		else begin
			state <= s_go_draw_r; end 
		
		end

	s_go_draw_r: begin 
		if (draw_r_recieved) begin
			go_rocket <= 1'b1;
		
			draw_r_recieved <= 0; 
			drawing_r <= 1'b1; 
			state <= s_wait;
			end

		else begin
			state <= s_go_draw_a; end 
		
		end

	s_wait: begin
	go_clear <= 0;
	
	 if (drawing_clear) begin
			oX <= coX;
			oY <= coY;
			oColor <= coColor; writeEn<=cE;
			state <= draw_done_clear ? s_nothing: s_wait; end
			
	else if (drawing_r) begin
			oX <= roX;
			oY <= roY;
			oColor <= roColor; writeEn<= rE;
			if (draw_done_rocket) begin 
			state <=  s_go_draw_a; writeEn<= 0;
			drawing_r <= 0; end

		 end

	else if (drawing_l) begin
			oX <= loX;
			oY <= loY;
			oColor <= loColor; writeEn<= lE;
		
		if (draw_done_laser) begin 
			state <=  s_go_draw_r;writeEn<= 0;
			drawing_l <= 0; end
			
		end

	else if (drawing_a) begin
			oX <= aoX;
			oY <= aoY;
			oColor <= aoColor; writeEn<= aE;

		if (draw_done_asteroid) begin 
			state <=  s_go_draw_l;writeEn<= 0;
			drawing_a <= 0; end
	end



	end
	
	s_go_clear: begin 
	
	go_clear <= 1'b1;
		writeEn<= 0;
		drawing_l <= 0;
		drawing_a <= 0;
		drawing_r <= 0;

		drawing_clear<= 1'b1; 
		state <= s_wait;
		draw_r_recieved <=0; 
		draw_a_recieved <= 0;
		draw_l_recieved <=0;
	
	
	end

	endcase

end

end

endmodule

module draw_triangle(
  input clock, input reset,
  input wire draw,
  input wire [7:0] start_x,
  input wire [6:0] start_y,
  input wire [7:0] x_size, 
  input wire [6:0] y_size, 
  input wire [2:0] iColor,
  output reg [2:0] oColor,
  output wire [7:0] cur_x,
  output wire [6:0] cur_y,
  output reg plot,
  output reg done
);

   localparam s_idle = 2'b00, s_draw = 2'b01, s_done = 2'b10;

  reg [1:0] state;
  reg [7:0] current_x, x_dim, starting_x, cur_base, center_x;
  reg [6:0] current_y, y_dim, starting_y;




  always @(posedge clock) begin

      plot <= 1'b0;
      done <= 1'b0;


    if (reset) begin
      state <= s_idle;
      current_x <= 8'b0;
      current_y <= 7'b0;
      plot <= 1'b0;
      done <= 1'b0;
      x_dim <= 0;
      y_dim <= 0;
	cur_base<= 0;
center_x <= 0;
    end else begin
      case(state)
        s_idle: begin
		done <= 0;
          if (draw) begin
		
            state <= s_draw;
            current_x <= start_x;
		center_x <= start_x + (x_size)/2-1;
            starting_x <= start_x;
            current_y <= start_y;
            starting_y <= start_y;
            x_dim <= x_size;
            y_dim <= y_size;
            plot <= 1'b0;
		cur_base <= 0;
		oColor <= iColor;
          end
          done <= 1'b0;
        end
        s_draw:begin
           plot <= (current_x <= center_x + cur_base)&&(current_x >= center_x - cur_base)&&current_y <=113||current_x == center_x || (current_y >113&&current_x >=start_x +2&& current_x <= start_x +8);
	
          if (current_x < (starting_x + x_dim - 1)) begin
            current_x <= current_x + 1;
          end else if (current_y < (starting_y + y_dim - 1)) begin
            current_x <= starting_x;
            current_y <= current_y + 1;
			cur_base <= cur_base + 1;
          end else begin
            state <= s_idle;
            plot <= 1'b0;
		done <= 1'b1;
          end

         end
            
        s_done: begin
          
          plot <= 1'b0;
          done <= 1'b0;
		state<= s_idle;




           
        end
      endcase
    end
  end

  assign cur_x = current_x;
  assign cur_y = current_y;

endmodule


module draw_circle (
    input wire clock,
    input wire reset,
    input wire draw,
    input wire [7:0] start_x, //top left
    input wire [6:0] start_y, 
    input wire [7:0] radius,
    input wire [2:0] iColor,
    output reg [2:0] oColor,
    output wire [7:0] cur_x,
    output wire [6:0] cur_y,
    output reg plot,
    output reg done
);

   localparam s_idle = 2'b00, s_draw = 2'b01, s_done = 2'b10;

  reg [1:0] state;
  reg [7:0] current_x, x_dim, center_x, starting_x;
  reg [6:0] current_y, y_dim, center_y, starting_y;




  always @(posedge clock) begin

      plot <= 1'b0;
      done <= 1'b0;


    if (reset) begin
      state <= s_idle;
      current_x <= 8'b0;
      current_y <= 7'b0;
      plot <= 1'b0;
      done <= 1'b0;
      x_dim <= 0;
      y_dim <= 0;
    end else begin
      case(state)
        s_idle: begin
		done <= 0;
          if (draw) begin
		
            state <= s_draw;
		starting_x <= start_x;
		starting_y <= start_y;
            current_x <= start_x;
            center_x <= start_x+radius-1;
            current_y <= start_y;
            center_y <= start_y+radius-1;
            x_dim <= radius*2;
            y_dim <= radius*2;

		oColor <= iColor;
          end
          done <= 1'b0;
        end
        s_draw:begin

	
          if (current_x < (starting_x + x_dim - 1)) begin
            current_x <= current_x + 1;
          end else if (current_y < (starting_y + y_dim - 1)) begin
            current_x <= starting_x;
            current_y <= current_y + 1;
          end else begin
            state <= s_idle;
            plot <= 1'b0;
		done <= 1'b1;
          end
	plot <= ((current_x-center_x)*(current_x-center_x)) + ((current_y-center_y)*(current_y-center_y)) < radius*radius ? 1'b1:1'b0;

         end
            
        s_done: begin
          
          plot <= 1'b0;
          done <= 1'b0;
		state<= s_idle;




           
        end
      endcase
    end
  end

  assign cur_x = current_x;
  assign cur_y = current_y;

endmodule

module draw_box (
  input clock, input reset,
  input wire draw,
  input wire [7:0] start_x,
  input wire [6:0] start_y,
  input wire [7:0] x_size, 
  input wire [6:0] y_size, 
  input wire [2:0] iColor,
  output reg [2:0] oColor,
  output wire [7:0] cur_x,
  output wire [6:0] cur_y,
  output reg plot,
  output reg done
);

   localparam s_idle = 2'b00, s_draw = 2'b01, s_done = 2'b10;

  reg [1:0] state;
  reg [7:0] current_x, x_dim, starting_x;
  reg [6:0] current_y, y_dim, starting_y;




  always @(posedge clock) begin

      plot <= 1'b0;
      done <= 1'b0;


    if (reset) begin
      state <= s_idle;
      current_x <= 8'b0;
      current_y <= 7'b0;
      plot <= 1'b0;
      done <= 1'b0;
      x_dim <= 0;
      y_dim <= 0;
    end else begin
      case(state)
        s_idle: begin
		done <= 0;
          if (draw) begin
		
            state <= s_draw;
            current_x <= start_x;
            starting_x <= start_x;
            current_y <= start_y;
            starting_y <= start_y;
            x_dim <= x_size;
            y_dim <= y_size;
            plot <= 1'b1;
		oColor <= iColor;
          end
          done <= 1'b0;
        end
        s_draw:begin
           plot <= 1'b1;
	
          if (current_x < (starting_x + x_dim - 1)) begin
            current_x <= current_x + 1;
          end else if (current_y < (starting_y + y_dim - 1)) begin
            current_x <= starting_x;
            current_y <= current_y + 1;
          end else begin
            state <= s_idle;
            plot <= 1'b0;
		done <= 1'b1;
          end

         end
            
        s_done: begin
          
          plot <= 1'b0;
          done <= 1'b0;
		state<= s_idle;




           
        end
      endcase
    end
  end

  assign cur_x = current_x;
  assign cur_y = current_y;

endmodule


module move_dp2 #(parameter CLOCK_FREQUENCY = 50000000, fps = 24) ( //change this to 50 million later
input clock,
input go,
input reset,
input draw_done,  //draw_box says I'm don'e drawing
  output reg draw, //goes to draw_box
  input wire [7:0] start_x,
  input wire [6:0] start_y,
  input wire [7:0] end_x,
  input wire [6:0] end_y,
  input wire [2:0] color,


input destroy, 
output reg destroyed,

  input wire signed [2:0] delta_x, input wire signed [2:0] delta_y,
  output reg [7:0] draw_x, 
  output reg [6:0] draw_y, 
  output reg [2:0] oColor, output reg reset_draw,
  output reg move_done  //sends signal to main countrol, this resets, delay counter
);
//module gives the most up to date location

localparam s_idle = 3'b00, s_earase = 3'd1,s_e_wait = 3'd2, s_draw = 3'd3,s_d_wait = 3'd4, s_done = 3'd5;
reg [3:0] state;
reg destroying;

 wire pulse,Enable; //first time a pulse is sent draw, second time earase

	//move_donesends signal to main countrol, this resets, delay counter, add!!!!!!
 
DelayCounter #(CLOCK_FREQUENCY) d1(
.clock(clock),
.reset(reset),
.go(go),
.Enable(Enable)
);

frame_counter #(fps)fc(
.clock(clock),
.reset(reset),
.Enable(Enable),
.pulse(pulse)
);

  reg [7:0] ending_x;
  reg [6:0] ending_y;
  reg signed [2:0] change_x, change_y;
  reg [2:0] obj_color;
	reg done_moving;
//reset draw_box when move is done
	
	always@(posedge clock) begin
		reset_draw<= 0;
		if (reset) begin
		   state <= s_idle;
                   draw_x<=0;
                   draw_y<=0;
                   oColor<=0;
                   move_done<=0;
		   change_x <= 0;
		   change_y <= 0;
			obj_color <= color;
			destroying <= 0;
			destroyed <= 0;
			done_moving<= 0;
 		end
		else if (destroy) begin destroying <= 1'b1; end
		
		else begin 
			
		

		
		    case(state)
			s_idle: begin
               			draw_x<=0;
                   		draw_y<=0;
                   		oColor<=obj_color;
                   		move_done<=0; 
				draw<=0;
				destroyed <= 0;
				destroying <= 0;
				done_moving<= 0;

			if (go && (end_x < 0 || end_x > 160|| end_y < 0 || end_y > 120)) begin 
				state<=s_idle;
				move_done <= 1'b1; end 
                                 

			if (go) begin
			//load in values
				draw_x <= start_x;
				draw_y <= start_y;
				ending_x <= end_x;
				ending_y <= end_y;
		   		change_x <= delta_x;
		   		change_y <= delta_y;
				oColor <= 0;
				state <= s_earase;
			end



			

			end

			s_earase: begin
			draw <= 0;

			//earase at pulse
			if (pulse) begin
               			oColor <= 0;
				state <= s_e_wait;
			   	draw <= 1'b1;   end
			end

 			s_e_wait: begin 
			draw <= 0;

			if (draw_done && destroying) begin 
				destroying<= 0; 
				state <= s_idle; 
				destroyed <= 1'b1; end
				
			else if (draw_done && done_moving) begin 
				done_moving<= 0; 
				state <= s_idle; 
				move_done <= 1'b1; end

			else if (draw_done) begin 
			   state <= s_draw;
			   draw_x <= draw_x + change_x;
			   draw_y <= draw_y + change_y;
				if (change_x != 1 && change_x != 0) begin
					draw_x<= draw_x -1; end

				if (change_y != 1 && change_y != 0) begin
					draw_y<= draw_y -1; end
  			   oColor <= obj_color; end

 			end

			s_draw: begin
			draw<= 0;
			if (pulse) begin
				draw <= 1'b1;
				state <= s_d_wait; 
				oColor <= obj_color; end
			end

			s_d_wait: begin
			draw<= 0;

			if (draw_done && draw_x == ending_x && draw_y == ending_y) begin
				done_moving <= 1'b1;
				state <= s_earase; end
			
			else if (draw_done) begin
				state <= s_earase; end

			end
				

 			endcase
			end
		
			 


                



	end
endmodule






module DelayCounter #(parameter CLOCK_FREQUENCY = 50000000) (
  input clock,
  input reset,
  input go,
  output Enable
);
  reg [$clog2(CLOCK_FREQUENCY)+1:0] downCount;
  localparam s_idle = 1'b0, s_c = 1'b1;
  reg state;

    always @(posedge clock) begin

       if (reset) begin
       	   state <= s_idle;
           downCount <= (CLOCK_FREQUENCY*(1/60)+1); end
           
      else begin
	case(state)
		s_idle: begin 
		    downCount <=(CLOCK_FREQUENCY*(1/60)+1); 
		    if (go) begin
			downCount <= downCount -1;
			state <= s_c; end
		end
		s_c: begin
		   if (downCount == 0) begin 
			downCount <=(CLOCK_FREQUENCY*(1/60));  end
		   else begin
			downCount <= downCount - 1; end
		end
	endcase
	end
           	
     end

     
     assign Enable = (downCount == 0);

endmodule

module frame_counter #(parameter fps = 4) (
input clock,
input reset,
input Enable,
output pulse
);

   reg [$clog2(fps)+1:0] downCount;

  always@(posedge clock) begin
	if (reset || downCount == 0) begin 
	   downCount <= fps-1; end
        else if (Enable) begin
	  downCount <= downCount - 1; end
  end

assign pulse = (downCount == 0);

endmodule


//draw screen movedp, movedp2 make up animation

module move_dp #(parameter CLOCK_FREQUENCY = 50000000, fps = 4) ( //change this to 50 million later
input clock,
input go,
input reset,
input draw_done,//draw_box says I'm don'e drawing
  output reg draw, //goes to draw_box
  input wire [7:0] start_x,
  input wire [6:0] start_y,
  input wire [7:0] end_x,
  input wire [6:0] end_y,
  input wire [2:0] color,
  input wire signed [2:0] delta_x, input wire signed [2:0] delta_y,
  output reg [7:0] draw_x, 
  output reg [6:0] draw_y, 
  output reg [2:0] oColor,
  output reg move_done  //sends signal to main countrol, this resets, delay counter
);
//module gives the most up to date location

localparam s_idle = 3'b00, s_earase = 3'd1,s_e_wait = 3'd2, s_draw = 3'd3,s_d_wait = 3'd4, s_done = 3'd5;
reg [3:0] state;


 wire pulse,Enable; //first time a pulse is sent draw, second time earase

	//move_donesends signal to main countrol, this resets, delay counter, add!!!!!!
 
DelayCounter #(CLOCK_FREQUENCY) d1(
.clock(clock),
.reset(reset),
.go(go),
.Enable(Enable)
);

frame_counter #(fps)fc(
.clock(clock),
.reset(reset),
.Enable(Enable),
.pulse(pulse)
);

  reg [7:0] ending_x;
  reg [6:0] ending_y;
  reg signed [2:0] change_x, change_y;
  reg [2:0] obj_color;

//reset draw_box when move is done
	always@(posedge clock) begin
		if (reset) begin
		   state <= s_idle;
                   draw_x<=0;
                   draw_y<=0;
                   oColor<=0;
                   move_done<=0;
		   change_x <= 0;
		   change_y <= 0;
			obj_color <= color;
 		end
		
		else begin 
		    case(state)
			s_idle: begin
               			draw_x<=0;
                   		draw_y<=0;
                   		oColor<=obj_color;
                   		move_done<=0; 
				draw<=0;

			if (go && (end_x < 0 || end_x > 160|| end_y < 0 || end_y > 120)) begin 
				state<=s_idle;
				move_done <= 1'b1; end 
                                 

			if (go) begin
			//load in values
				draw_x <= start_x;
				draw_y <= start_y;
				ending_x <= end_x;
				ending_y <= end_y;
		   		change_x <= delta_x;
		   		change_y <= delta_y;
				oColor <= 0;
				state <= s_earase;
			end



			

			end

			s_earase: begin
			draw <= 0;

			//earase at pulse
			if (pulse) begin
               			oColor <= 0;
				state <= s_e_wait;
			   	draw <= 1'b1;   end
			end

 			s_e_wait: begin 
			draw <= 0;

			if (draw_done) begin 
			   state <= s_draw;
			   draw_x <= draw_x + change_x;
			   draw_y <= draw_y + change_y;

				if (change_x != 1 && change_x != 0) begin
					draw_x<= draw_x -1; end

				if (change_y != 1 && change_y != 0) begin
					draw_y<= draw_y -1; end


  			   oColor <= obj_color; end

 			end

			s_draw: begin
			draw<= 0;
			if (pulse) begin
				draw <= 1'b1;
				state <= s_d_wait; 
				oColor <= obj_color; end
			end

			s_d_wait: begin
			draw<= 0;

			if (draw_done && draw_x == ending_x && draw_y == ending_y) begin
				move_done <= 1'b1;
				state <= s_idle; end
			
			else if (draw_done) begin
				state <= s_earase; end

			end
				

 			endcase
			end
		
			 


                



	end
endmodule





